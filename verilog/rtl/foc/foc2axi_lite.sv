////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2023 , Alexandre Moriceau                       
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0
// SPDX-FileContributor: Created by Alexandre Moriceau <alexandremoriceau1@gmail.com>
//
////////////////////////////////////////////////////////////////////////////

module foc2axi_lite #(
  /// Define the parameter `RegNumBytes` of the DUT.
  parameter type byte_t = logic [7:0],
  parameter int unsigned REG_NUM_BYTES  = 32'd10
  ) (
  input wire clk, // Connect a 50MHz crystal oscillator
  input wire rst_n, // reset initially 0
  //------- 3-phase PWM signal, (including enable signal) -----------------------------------------------------------------------------------------------------
  output wire pwm_en, // 3 shared enable signal, when pwm_en=0, all 6 MOS tubes are turned off.
  output wire pwm_a, // A phase PWM signal. When =0. Lower bridge arm conduction; When =1, the upper bridge arm is on
  output wire pwm_b, // B phase PWM signal. When =0. Lower bridge arm conduction; When =1, the upper bridge arm is on
  output wire pwm_c, // C-phase PWM signal. When =0. Lower bridge arm conduction; When =1, the upper bridge arm is on
  //------- AD7928 (ADC chip) for phase current sensing (SPI interface) ---------------------------------------------------------------------------------------
  output wire spi_ss,
  output wire spi_sck,
  output wire spi_mosi,
  input  wire spi_miso,
  //------- AS5600 magnetic encoder for rotor mechanical angle (I2C interface) ------------------------------------------------------------------------------------
  output wire i2c_scl,
  inout       i2c_sda,
  //AXI lite register Interface
  input  reg    [REG_NUM_BYTES-1:0] wr_active_o,
  input  reg    [REG_NUM_BYTES-1:0] rd_active_o,
  output byte_t [REG_NUM_BYTES-1:0] reg_d_i,
  output reg    [REG_NUM_BYTES-1:0] reg_load_i,
  input  byte_t [REG_NUM_BYTES-1:0] reg_q_o
);

wire [11:0] phi; //The rotor mechanical angle read from the AS5600 magnetic encoder is φ, and the value range is 0~4095. 0 corresponds to 0°; 1024 corresponds to 90°; 2048 corresponds to 180°; 3072 corresponds to 270°.

wire sn_adc; //The 3-phase current ADC controls the signal at the moment of sampling, and when a sample is required, a clock cycle high level pulse is generated on the sn_adc signal, indicating that the ADC should be sampled.
wire en_adc; //After the 3-phase current ADC samples the valid signal, sn_adc generates a high-level pulse, the adc_ad7928 module starts sampling the 3-phase current, and after the conversion ends, generates a period of high-level pulse on the en_adc signal, and generates the ADC conversion result on the adc_value_a, adc_value_b, and adc_value_c signals.
wire [11:0] adc_value_a; //Phase A current-sense ADC raw value
wire [11:0] adc_value_b; //Phase B current-sense ADC raw value
wire [11:0] adc_value_c; //C-phase current sense ADC raw values

wire en_idq; //When a high pulse appears, a new value for ID and IQ appears, and a high pulse is generated for each control period en_idq
reg signed [15:0] id; //the actual current value of the rotor d-axis (straight shaft),
wire signed [15:0] iq; //The actual current value of the rotor q-axis (cross-axis), which can be positive or negative (if positive is counterclockwise, negative is clockwise and vice versa)
reg signed [15:0] id_aim; //The target current value of the rotor d-axis (straight axis), which can be positive or negative
reg signed [15:0] iq_aim; //Target current value for the rotor q-axis (cross-axis), which can be positive or negative (if positive is counterclockwise, negative is clockwise and vice versa)
reg signed [15:0] ctrl_reg;

//clock_divider
reg Q;
reg D;
wire clk_int;

////////////////////////////////////////////////////////////////////////////
// I2C simple Lire le contrôleur, réalisez la lecture du lecteur du codeur magnétique AS5600, lisez l'angle mécanique du rotor actuel φ
////////////////////////////////////////////////////////////////////////////

wire [3:0] i2c_trash;
i2c_register_read #(
    .CLK_DIV      ( 16'd10         ),  // Coefficient de division de la fréquence du signal d'horloge I2C_SCL, fréquence SCL = Fréquence Clk / (4 * CLK_DIV), par exemple, dans cet exemple, le CLK est 36.864MHz et Clk_Div = 10, alors la fréquence SCL est 36864 / (4 * 10) = 922KHz .Remarque, la puce AS5600 nécessite que la fréquence SCL ne dépasse pas 1 MHz
    .SLAVE_ADDR   ( 7'h36          ),  // AS5600's I2C slave address
    .REGISTER_ADDR( 8'h0E          )   // the register address to read
) as5600_read_i (
    .rstn         ( rst_n           ),
    .clk          ( clk_int            ),
    .scl          ( i2c_scl        ), // I2C： SCL
    .sda          ( i2c_sda        ), // I2C： SDA
    .start        ( 1'b1           ), 
    .ready        (                ),
    .done         (                ),
    .regout       ( {i2c_trash, phi} )
);

////////////////////////////////////////////////////////////////////////////
// AD7928 Le lecteur ADC est utilisé pour lire la valeur des échantillons d'électricité en phase en phase (lisez la valeur d'origine de l'ADC sans aucun traitement)
////////////////////////////////////////////////////////////////////////////

adc_ad7928 #(
    .CH_CNT       ( 3'd2           ), // Ce paramètre est 2, indiquant que nous voulons seulement la valeur ADC des trois canaux de CH0, CH1, CH2
    .CH0          ( 3'd1           ), // Instruction CH0 correspondant au canal AD7928 1.(Un courant de phase sur le matériel est connecté au canal de AD7928 1)
    .CH1          ( 3'd2           ), // Instruction CH1 Channel correspondant 2 de AD7928.(Le courant de phase B sur le matériel est connecté au canal de AD7928 2)
    .CH2          ( 3'd3           )  // Instruction CH2 Channel correspondant 3 de AD7928.(Le courant de phase C sur le matériel est connecté au canal de AD7928 3)
) adc_ad7928_i (
    .rstn         ( rst_n           ),
    .clk          ( clk_int            ),
    .spi_ss       ( spi_ss         ), // Interface SPI: SS
    .spi_sck      ( spi_sck        ), // Interface SPI: SCK
    .spi_mosi     ( spi_mosi       ), // Interface SPI: MOSI
    .spi_miso     ( spi_miso       ), // Interface SPI: MISO
    .i_sn_adc     ( sn_adc         ), // Entrée: lorsque SN_ADC apparaît d'impulsion élevée, le module démarre (3) Conversion ADC
    .o_en_adc     ( en_adc         ), // Sortie: Une fois la conversion terminée, EN_ADC génère un cycle d'impulsion plate à haute puissance
    .o_adc_value0 ( adc_value_a    ), // Lorsque EN_ADC génère une impulsion plate à haute puissance d'un cycle, la valeur d'origine de l'ADC d'un courant en phase sur ADC_Value_A apparaît
    .o_adc_value1 ( adc_value_b    ), // Lorsque EN_ADC génère une impulsion plate à haute puissance d'un cycle, la valeur d'origine de l'ADC du courant en phase B sur l'ADC_Value_B apparaît
    .o_adc_value2 ( adc_value_c    ), // Lorsque EN_ADC génère une impulsion plate à haute puissance d'un cycle, la valeur d'origine de l'ADC du courant C -Phase sur l'ADC_Value_C apparaît
    .o_adc_value3 (                ), // ignore les résultats des résultats de conversion ADC des 5 routes restantes
    .o_adc_value4 (                ), // ignore les résultats des résultats de conversion ADC des 5 routes restantes
    .o_adc_value5 (                ), // ignore les résultats des résultats de conversion ADC des 5 routes restantes
    .o_adc_value6 (                ), // ignore les résultats des résultats de conversion ADC des 5 routes restantes
    .o_adc_value7 (                )  // ignore les résultats des résultats de conversion ADC des 5 routes restantes
);

////////////////////////////////////////////////////////////////////////////
// module foc + svpwm (voir foc_top.svpour plus de détails et principes)
////////////////////////////////////////////////////////////////////////////

foc_top #(
    .INIT_CYCLES  ( 16777216       ), // Dans cet exemple, la fréquence de l'horloge (CLK) est de 36,864 MHz, init_cycles = 16777216, et le temps d'initialisation est 16777216/36864000 = 0,45 seconde
    .ANGLE_INV    ( 1'b0           ), // Dans cet exemple, le capteur d'angle n'est pas installé (A-> B-> C-> Arestation de rotation de A est le même que celui de φ augmentation), alors ce paramètre doit être réglé sur 0
    .POLE_PAIR    ( 8'd7           ), // La paire extrême de moteur utilisé dans cet exemple est 7
    .MAX_AMP      ( 9'd384         ), // 384/512 = 0,75.Expliquez que l'amplitude maximale de SVPWM représente 75% de la limite d'amplitude maximale
    .SAMPLE_DELAY ( 9'd120         ), // Le délai d'échantillonnage, la plage de la valeur est de 0 ~ 511. Étant donné que le tube de conduite MOS de la phase 3 du début à la stabilité actuelle, il faut un certain temps, donc des 3 bras de pont inférieurs àDC 采样时刻之间需要一定的延时。该参数决定了该延时是多少个时钟周期，当延时结束时，该模块在 sn_adc 信号上产生一个高电平脉冲，指示外部 ADC “可以采样了”
    .Kp           ( 24'd32768      ), // Le paramètre P de l'algorithme de contrôle du pid annulaire actuel
    .Ki           ( 24'd2          )  // Le paramètre I de l'algorithme de contrôle du pid annulaire actuel
) foc_top_i (
    .rstn         ( rst_n           ),
    .clk          ( clk_int            ),
    .phi          ( phi            ), // Entrée: Angle - Entrée du capteur d'angle (angle mécanique, briefing comme φ), la plage de valeur de 0 ~ 4095.0 correspond à 0 °; 1024 correspond à 90 °; 2048 correspond à 180 °; 3072 correspond à 270 ° correspondant à 270 °;。
    .sn_adc       ( sn_adc         ), // Sortie: Courant triphasé Un courant de contrôle du temps d'échantillonnage ADC Current. Lorsqu'un échantillonnage est nécessaire, une impulsion élevée de cycle d'horloge est générée sur le signal SN_ADC.应该进行采样了。
    .en_adc       ( en_adc         ), // Entrée: Résultats de l'échantillonnage ADC de courant 3 phases Signal valide. Une fois SN_ADC génère une impulsion élevée élevée, l'ADC externe commence à goûter le courant en 3 phases. Une fois la conversion terminée, elle devrait être à EN_A.dc 信号上产生一个周期的高电平脉冲，同时把ADC转换结果产生在 adc_a, adc_b, adc_c 信号上
    .adc_a        ( adc_value_a    ), // Entrée: un résultat d'échantillonnage ADC de phase
    .adc_b        ( adc_value_b    ), // Entrée: B phase ADC Résultat de l'échantillonnage
    .adc_c        ( adc_value_c    ), // Entrée: C Résultat de l'échantillonnage ADC de phase C
    .pwm_en       ( pwm_en         ),
    .pwm_a        ( pwm_a          ),
    .pwm_b        ( pwm_b          ),
    .pwm_c        ( pwm_c          ),
    .en_idq       ( en_idq         ), // Sortie: Lorsque l'impulsion plate à haute puissance apparaît, l'ID et le QI ont une nouvelle valeur. Chaque cycle de contrôle EN_IDQ générera une impulsion plate à haute puissance
    .id           ( id             ), // Sortie: La valeur de courant réelle de l'axe D (axe droit) peut être positive ou négative
    .iq           ( iq             ), // Sortie: la valeur de courant réelle de l'axe Q (rapports sexuels) peut être positif et négatif (si positif représente le sens antihoraire, négatif représente dans le sens des aiguilles d'une montre et vice versa)
    .id_aim       ( id_aim         ), // Entrée: la valeur de courant cible de l'axe d (axe droit) peut être positive ou négative. Il est généralement réglé sur 0 sans utiliser de contrôle magnétique faible
    .iq_aim       ( iq_aim         ), // Entrée: la valeur de courant cible de l'axe Q (axe droit) peut être positive et négative (si le positif représente dans le sens antihoraire, négatif représente le sens horaire et vice versa)
    .init_done    (                )  // Sortie: initialisez le signal final.Avant la fin de l'initialisation = 0, une fois l'initialisation terminée (entrez l'état du contrôle foc) = 1
);

////////////////////////////////////////////////////////////////////////////
//register management
////////////////////////////////////////////////////////////////////////////

always @ (posedge clk)
    if (~rst_n) begin
        reg_load_i <= '0;
        reg_d_i <= '0;
    end else begin
        if (en_idq == 1'b1) begin
            reg_load_i[7:4] <= 4'hF;
            reg_d_i[7:6] <= id;
            reg_d_i[5:4] <= iq;
        end else begin 
            reg_load_i[7:4] <= '0;
        end
    end

always @ (posedge clk)
    if (~rst_n) begin
        iq_aim <= '0;
        id_aim <= '0;
        ctrl_reg  <= '0;
    end else begin
        iq_aim <= reg_q_o[1:0];
        id_aim <= reg_q_o[3:2];
        ctrl_reg <= reg_q_o[9:8];
    end

always_ff @(posedge clk or negedge rst_n) begin
  if (~rst_n) begin
    Q <= 1'b0;
  end else begin
    Q <= D;
  end
end

assign D = ~Q;
assign clk_int = (ctrl_reg[0] == 1) ? Q : clk;

endmodule
