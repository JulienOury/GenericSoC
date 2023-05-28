//--------------------------------------------------------------------------------------------------------
// Module  : tb_swpwm
// Type    : simulation, top
// Standard: SystemVerilog 2005 (IEEE1800-2005)
// Function: testbench for cartesian2polar.sv and swpwm.sv
//--------------------------------------------------------------------------------------------------------

`timescale 1ps/1ps

module tb_swpwm();


initial $dumpvars(1, tb_swpwm);
initial $dumpvars(1, svpwm_i);


reg rstn = 1'b0;
reg clk  = 1'b1;
always #(13563) clk = ~clk;   // 36.864MHz
initial begin repeat(4) @(posedge clk); rstn<=1'b1; end


reg         [11:0] theta = '0;

wire signed [15:0] x, y;

wire        [11:0] rho;
wire        [11:0] phi;

wire pwm_en, pwm_a, pwm_b, pwm_c;

// Ici, utilisez simplement le module sincos pour générer des ondes sinusoïdales pour cartesian2polar, juste pour la simulation. Dans la conception FOC, le module sincos n'est pas utilisé pour fournir des données d'entrée à cartesian2polar, mais est appelé par park_tr.
sincos sincos_i (
    .rstn         ( rstn       ),
    .clk          ( clk        ),
    .i_en         ( 1'b1       ),
    .i_theta      ( theta      ),   // input : θ, une valeur d'angle croissante
    .o_en         (            ),
    .o_sin        ( y          ),   // sortie : y, une onde sinusoïdale d'amplitude de ±16384
    .o_cos        ( x          )    // sortie : x, une onde cosinus avec une amplitude de ±16384
);

cartesian2polar cartesian2polar_i (
    .rstn         ( rstn       ),
    .clk          ( clk        ),
    .i_en         ( 1'b1       ),
    .i_x          ( x / 16'sd5 ),  // entrée : onde cosinus d'amplitude ±3277
    .i_y          ( y / 16'sd5 ),  // entrée : une onde sinusoïdale avec une amplitude de ±3277
    .o_en         (            ),
    .o_rho        ( rho        ),  // sortie : ρ, doit toujours être égal ou approximativement à 3277
    .o_theta      ( phi        )   // sortie : φ, doit être un angle proche de θ
);

svpwm svpwm_i (
    .rstn         ( rstn       ),
    .clk          ( clk        ),
    .v_amp        ( 9'd384     ),
    .v_rho        ( rho        ),  // input : ρ
    .v_theta      ( phi        ),  // input : φ
    .pwm_en       ( pwm_en     ),  // output
    .pwm_a        ( pwm_a      ),  // output
    .pwm_b        ( pwm_b      ),  // output
    .pwm_c        ( pwm_c      )   // output
);


initial begin
    while(~rstn) @ (posedge clk);
    for(int i=0; i<200; i++) begin
        theta <= 25 * i;               // incrémente θ
        repeat(2048) @ (posedge clk);
        $display("%d/200", i);
    end
    $finish;
end

endmodule
