////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2023 , Julien OURY                       
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
// SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>
//
////////////////////////////////////////////////////////////////////////////

module main_partition(

`ifdef USE_POWER_PINS
    inout  wire vccd1,  // User area 1 1.8V supply
    inout  wire vssd1,  // User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input  wire         wb_clk_i ,
    input  wire         wb_rst_i ,
    input  wire         wbs_stb_i,
    input  wire         wbs_cyc_i,
    input  wire         wbs_we_i ,
    input  wire [3:0]   wbs_sel_i,
    input  wire [31:0]  wbs_dat_i,
    input  wire [31:0]  wbs_adr_i,
    output wire         wbs_ack_o,
    output wire [31:0]  wbs_dat_o,

    // IOs
    input  wire [`MPRJ_IO_PADS-1:0] io_in,
    output wire [`MPRJ_IO_PADS-1:0] io_out,
    output wire [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output wire [2:0] irq
);

////////////////////////////////////////////////////////////////////////////
// Local parameters
////////////////////////////////////////////////////////////////////////////

  /// Addr/Data width of the AXI channels.
  localparam int unsigned AxiAddrWidth      = 32'd32;
  localparam int unsigned AxiDataWidth      = 32'd32;
	
  typedef axi_pkg::xbar_rule_32_t rule_t; // Has to be the same width as axi addr

  // Number of AXI masters connected to the xbar. (Number of slave ports)
  localparam int unsigned NumMasters        = 32'd3;
	
  // Number of AXI slaves connected to the xbar. (Number of master ports)
  localparam int unsigned NumSlaves         = 32'd2;
	
  /// AXI4+ATOP ID width of the masters connected to the slave ports of the DUT.
  /// The ID width of the slaves is calculated depending on the xbar configuration.
  localparam int unsigned AxiIdWidthMasters = 32'd5;
  localparam int unsigned AxiIdWidthSlaves  =  AxiIdWidthMasters + $clog2(NumMasters);
	
  /// The used ID width of the DUT.
  /// Has to be `TbAxiIdWidthMasters >= TbAxiIdUsed`.
  localparam int unsigned AxiIdUsed         = 32'd3;
	
  // AXI configuration which is automatically derived.
  localparam int unsigned AxiStrbWidth      =  AxiDataWidth / 8;
  localparam int unsigned AxiUserWidth      =  5;
	
  // In the bench can change this variables which are set here freely,
  localparam axi_pkg::xbar_cfg_t xbar_cfg = '{
    NoSlvPorts         : NumMasters          ,
    NoMstPorts         : NumSlaves           ,
    MaxMstTrans        : 10                  ,
    MaxSlvTrans        : 6                   ,
    FallThrough        : 1'b0                ,
    LatencyMode        : axi_pkg::NO_LATENCY , // (axi_pkg::NO_LATENCY | axi_pkg::CUT_ALL_AX)
    PipelineStages     : 32'd1               , // Pipeline stages in the xbar itself (between demux and mux).
    AxiIdWidthSlvPorts : AxiIdWidthMasters   ,
    AxiIdUsedSlvPorts  : AxiIdUsed           ,
    UniqueIds          : 1'b0                , // Restrict to only unique IDs
    AxiAddrWidth       : AxiAddrWidth        ,
    AxiDataWidth       : AxiDataWidth        ,
    NoAddrRules        : NumSlaves           
  };
	
	localparam int unsigned AXI_MST_IDX_CVE2_INSTR =  0;
	localparam int unsigned AXI_MST_IDX_CVE2_DATA  =  1;
	localparam int unsigned AXI_MST_IDX_WB         =  2;
	
	localparam int unsigned AXI_SLV_IDX_RAM        =  0;
	localparam int unsigned AXI_SLV_IDX_SYS        =  1;
	
  // Each slave has its own address range:
  localparam rule_t [xbar_cfg.NoAddrRules-1:0] AddrMap = '{
	  '{ idx: AXI_SLV_IDX_RAM , start_addr: 32'h30000000, end_addr: 32'h30000FFF},
	  '{ idx: AXI_SLV_IDX_SYS , start_addr: 32'h30001000, end_addr: 32'h30001FFF}
	};


////////////////////////////////////////////////////////////////////////////
// Signals declaration
////////////////////////////////////////////////////////////////////////////

  // CVE2 : Instruction memory interface
  logic        cve2_instr_req    ;
  logic        cve2_instr_gnt    ;
  logic        cve2_instr_rvalid ;
  logic [31:0] cve2_instr_addr   ;
  logic [31:0] cve2_instr_rdata  ;

  // CVE2 : Data memory interface
  logic        cve2_data_req     ;
  logic        cve2_data_gnt     ;
  logic        cve2_data_rvalid  ;
  logic        cve2_data_we      ;
  logic [3:0]  cve2_data_be      ;
  logic [31:0] cve2_data_addr    ;
  logic [31:0] cve2_data_wdata   ;
  logic [31:0] cve2_data_rdata   ;

  // Dummies for unconnected outputs
	wire dummy_o_wb_stall;
	wire dummy_o_wb_err;
	wire dummy_core_sleep;
	
	//AXI SystemManager
	wire logic proc_rst_n; // Processor reset
	
	wire logic rst   ;
	wire logic rst_n ;
	
	assign rst   =  wb_rst_i;
	assign rst_n = !wb_rst_i;
	
////////////////////////////////////////////////////////////////////////////
// AXI interconnect
////////////////////////////////////////////////////////////////////////////
	
  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth      ),
    .AXI_DATA_WIDTH ( AxiDataWidth      ),
    .AXI_ID_WIDTH   ( AxiIdWidthMasters ),
    .AXI_USER_WIDTH ( AxiUserWidth      )
  ) master [NumMasters-1:0] ();
	
  AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
  ) slave [NumSlaves-1:0] ();


  axi_xbar_intf #(
    .AXI_USER_WIDTH         ( AxiUserWidth    ),
    .Cfg                    ( xbar_cfg        ),
    .rule_t                 ( rule_t          )
  ) inst_xbar_interconnect (
    .clk_i                  ( wb_clk_i        ),
    .rst_ni                 ( rst_n           ),
    .test_i                 ( 1'b0            ),
    .slv_ports              ( master          ),
    .mst_ports              ( slave           ),
    .addr_map_i             ( AddrMap         ),
    .en_default_mst_port_i  ( '0              ),
    .default_mst_port_i     ( '0              )
  );

////////////////////////////////////////////////////////////////////////////
// Wishbone to AXI bridge
////////////////////////////////////////////////////////////////////////////

  wbm2axisp #(
    .C_AXI_DATA_WIDTH   (AxiAddrWidth                          ), // Width of the AXI R&W data
    .C_AXI_ADDR_WIDTH   (AxiDataWidth                          ), // AXI Address width (log wordsize)
    .C_AXI_ID_WIDTH     (AxiIdWidthMasters                     ),
    .DW                 (AxiDataWidth                          ), // Wishbone data width
    .AW                 (30                                    ), // Wishbone address width (log wordsize)
    .AXI_WRITE_ID       (5'b00000                              ), // [C_AXI_ID_WIDTH-1:0]
    .AXI_READ_ID        (5'b00001                              ), // [C_AXI_ID_WIDTH-1:0]
    .OPT_LITTLE_ENDIAN  (1'b1                                  ), // [0:0]
    .LGFIFO             (6                                     )
   ) inst_wbm2axisp (
    .i_clk              (wb_clk_i                              ), // System clock
    .i_reset            (rst                                   ), // Reset signal,drives AXI rst
  
    // AXI write address channel signals
    .o_axi_awvalid      (master[AXI_MST_IDX_WB].aw_valid       ), // Write address valid
    .i_axi_awready      (master[AXI_MST_IDX_WB].aw_ready       ), // Slave is ready to accept
    .o_axi_awid         (master[AXI_MST_IDX_WB].aw_id          ), // Write ID              [C_AXI_ID_WIDTH-1:0]
    .o_axi_awaddr       (master[AXI_MST_IDX_WB].aw_addr        ), // Write address         [C_AXI_ADDR_WIDTH-1:0]
    .o_axi_awlen        (master[AXI_MST_IDX_WB].aw_len         ), // Write Burst Length    [7:0]
    .o_axi_awsize       (master[AXI_MST_IDX_WB].aw_size        ), // Write Burst size      [2:0]
    .o_axi_awburst      (master[AXI_MST_IDX_WB].aw_burst       ), // Write Burst type      [1:0]
    .o_axi_awlock       (master[AXI_MST_IDX_WB].aw_lock        ), // Write lock type       [0:0]
    .o_axi_awcache      (master[AXI_MST_IDX_WB].aw_cache       ), // Write Cache type      [3:0]
    .o_axi_awprot       (master[AXI_MST_IDX_WB].aw_prot        ), // Write Protection type [2:0]
    .o_axi_awqos        (master[AXI_MST_IDX_WB].aw_qos         ), // Write Quality of Svc  [3:0]
  
    // AXI write data channel signals
    .o_axi_wvalid       (master[AXI_MST_IDX_WB].w_valid        ), // Write valid
    .i_axi_wready       (master[AXI_MST_IDX_WB].w_ready        ), // Write data ready
    .o_axi_wdata        (master[AXI_MST_IDX_WB].w_data         ), // Write data            [C_AXI_DATA_WIDTH-1:0]
    .o_axi_wstrb        (master[AXI_MST_IDX_WB].w_strb         ), // Write strobes         [C_AXI_DATA_WIDTH/8-1:0]
    .o_axi_wlast        (master[AXI_MST_IDX_WB].w_last         ), // Last write transaction
  
    // AXI write response channel signals
    .i_axi_bvalid       (master[AXI_MST_IDX_WB].b_valid        ), // Write reponse valid
    .o_axi_bready       (master[AXI_MST_IDX_WB].b_ready        ), // Response ready
    .i_axi_bid          (master[AXI_MST_IDX_WB].b_id           ), // Response ID    [C_AXI_ID_WIDTH-1:0]
    .i_axi_bresp        (master[AXI_MST_IDX_WB].b_resp         ), // Write response [1:0]
																											        
    // AXI read address channel signals                       
    .o_axi_arvalid      (master[AXI_MST_IDX_WB].ar_valid       ), // Read address valid
    .i_axi_arready      (master[AXI_MST_IDX_WB].ar_ready       ), // Read address ready
    .o_axi_arid         (master[AXI_MST_IDX_WB].ar_id          ), // Read ID              [C_AXI_ID_WIDTH-1:0]
    .o_axi_araddr       (master[AXI_MST_IDX_WB].ar_addr        ), // Read address         [C_AXI_ADDR_WIDTH-1:0]
    .o_axi_arlen        (master[AXI_MST_IDX_WB].ar_len         ), // Read Burst Length    [7:0]
    .o_axi_arsize       (master[AXI_MST_IDX_WB].ar_size        ), // Read Burst size      [2:0]
    .o_axi_arburst      (master[AXI_MST_IDX_WB].ar_burst       ), // Read Burst type      [1:0]
    .o_axi_arlock       (master[AXI_MST_IDX_WB].ar_lock        ), // Read lock type       [0:0]
    .o_axi_arcache      (master[AXI_MST_IDX_WB].ar_cache       ), // Read Cache type      [3:0]
    .o_axi_arprot       (master[AXI_MST_IDX_WB].ar_prot        ), // Read Protection type [2:0]
    .o_axi_arqos        (master[AXI_MST_IDX_WB].ar_qos         ), // Read Protection type [3:0]
																											        
    // AXI read data channel signals                          
    .i_axi_rvalid       (master[AXI_MST_IDX_WB].r_valid        ), // Read reponse valid
    .o_axi_rready       (master[AXI_MST_IDX_WB].r_ready        ), // Read Response ready
    .i_axi_rid          (master[AXI_MST_IDX_WB].r_id           ), // Response ID         [C_AXI_ID_WIDTH-1:0]
    .i_axi_rdata        (master[AXI_MST_IDX_WB].r_data         ), // Read data           [C_AXI_DATA_WIDTH-1:0]
    .i_axi_rresp        (master[AXI_MST_IDX_WB].r_resp         ), // Read response       [1:0]
    .i_axi_rlast        (master[AXI_MST_IDX_WB].r_last         ), // Read last
  
    // We'll share the clock and the reset
    .i_wb_cyc           (wbs_cyc_i                             ),
    .i_wb_stb           (wbs_stb_i                             ),
    .i_wb_we            (wbs_we_i                              ),
    .i_wb_addr          (wbs_adr_i[31:2]                       ), // [(AW-1):0]  
    .i_wb_data          (wbs_dat_i                             ), // [(DW-1):0]  
    .i_wb_sel           (wbs_sel_i                             ), // [(DW/8-1):0]
    .o_wb_stall         (dummy_o_wb_stall                      ),
    .o_wb_ack           (wbs_ack_o                             ),
    .o_wb_data          (wbs_dat_o                             ), // [(DW-1):0]
    .o_wb_err           (dummy_o_wb_err                        )
  );

  assign master[AXI_MST_IDX_WB].aw_region = 'b0;
  assign master[AXI_MST_IDX_WB].aw_atop   = 'b0;
  assign master[AXI_MST_IDX_WB].aw_user   = 'b0;
  assign master[AXI_MST_IDX_WB].w_user    = 'b0;
  assign master[AXI_MST_IDX_WB].ar_region = 'b0;
  assign master[AXI_MST_IDX_WB].ar_user   = 'b0;


////////////////////////////////////////////////////////////////////////////
// CVE2 processor
////////////////////////////////////////////////////////////////////////////

  cve2 inst_cve2 (
    
`ifdef USE_POWER_PINS
    .vccd1             (vccd1             ),  // User area 1 1.8V supply
    .vssd1             (vssd1             ),  // User area 1 digital ground
`endif

    // Clock and Reset
    .clk_i             (wb_clk_i          ),
    .rst_ni            (proc_rst_n        ),
  
    .test_en_i         (1'b0              ), // enable all clock gates for testing
  
    // Instruction memory interface
    .instr_req_o       (cve2_instr_req    ),
    .instr_gnt_i       (cve2_instr_gnt    ),
    .instr_rvalid_i    (cve2_instr_rvalid ),
    .instr_addr_o      (cve2_instr_addr   ), // [31:0]
    .instr_rdata_i     (cve2_instr_rdata  ), // [31:0]
    .instr_err_i       (1'b0              ),
  
    // Data memory interface
    .data_req_o        (cve2_data_req     ),
    .data_gnt_i        (cve2_data_gnt     ),
    .data_rvalid_i     (cve2_data_rvalid  ),
    .data_we_o         (cve2_data_we      ),
    .data_be_o         (cve2_data_be      ), // [3:0] 
    .data_addr_o       (cve2_data_addr    ), // [31:0]
    .data_wdata_o      (cve2_data_wdata   ), // [31:0]
    .data_rdata_i      (cve2_data_rdata   ), // [31:0]
    .data_err_i        (1'b0              ),
  
    // Interrupt inputs
    .irq_software_i    (1'b0              ),
    .irq_timer_i       (1'b0              ),
    .irq_external_i    (1'b0              ),
    .irq_fast_i        (15'b0             ), // [14:0]
    .irq_nm_i          (1'b0              ), // non-maskeable interrupt
  
    // Debug Interface
    .debug_req_i       (1'b0              ),
  
    // CPU Control Signals
    .core_sleep_o      (dummy_core_sleep  ),
  
    // DFT bypass controls
    .scan_rst_ni       (1'b1              )
  );
	
  core2axi #(
    .AXI4_ADDRESS_WIDTH ( AxiAddrWidth      ),
    .AXI4_RDATA_WIDTH   ( AxiDataWidth      ),
    .AXI4_WDATA_WIDTH   ( AxiDataWidth      ),
    .AXI4_ID_WIDTH      ( AxiIdWidthMasters ),
    .AXI4_USER_WIDTH    ( AxiUserWidth      ),
    .REGISTERED_GRANT   ( "TRUE "           )
  )
  inst_core2axi_instr
  (
    .clk_i         ( wb_clk_i               ),
    .rst_ni        ( rst_n                  ),

    .data_req_i    ( cve2_instr_req         ),
    .data_gnt_o    ( cve2_instr_gnt         ),
    .data_rvalid_o ( cve2_instr_rvalid      ),
    .data_addr_i   ( cve2_instr_addr        ),
    .data_we_i     ( 1'b0                   ),
    .data_be_i     ( 4'b0                   ),
    .data_rdata_o  ( cve2_instr_rdata       ),
    .data_wdata_i  ( 32'b0                  ),

    .aw_id_o       ( master[AXI_MST_IDX_CVE2_INSTR].aw_id        ),
    .aw_addr_o     ( master[AXI_MST_IDX_CVE2_INSTR].aw_addr      ),
    .aw_len_o      ( master[AXI_MST_IDX_CVE2_INSTR].aw_len       ),
    .aw_size_o     ( master[AXI_MST_IDX_CVE2_INSTR].aw_size      ),
    .aw_burst_o    ( master[AXI_MST_IDX_CVE2_INSTR].aw_burst     ),
    .aw_lock_o     ( master[AXI_MST_IDX_CVE2_INSTR].aw_lock      ),
    .aw_cache_o    ( master[AXI_MST_IDX_CVE2_INSTR].aw_cache     ),
    .aw_prot_o     ( master[AXI_MST_IDX_CVE2_INSTR].aw_prot      ),
    .aw_region_o   ( master[AXI_MST_IDX_CVE2_INSTR].aw_region    ),
    .aw_user_o     ( master[AXI_MST_IDX_CVE2_INSTR].aw_user      ),
    .aw_qos_o      ( master[AXI_MST_IDX_CVE2_INSTR].aw_qos       ),
    .aw_valid_o    ( master[AXI_MST_IDX_CVE2_INSTR].aw_valid     ),
    .aw_ready_i    ( master[AXI_MST_IDX_CVE2_INSTR].aw_ready     ),

    .w_data_o      ( master[AXI_MST_IDX_CVE2_INSTR].w_data       ),
    .w_strb_o      ( master[AXI_MST_IDX_CVE2_INSTR].w_strb       ),
    .w_last_o      ( master[AXI_MST_IDX_CVE2_INSTR].w_last       ),
    .w_user_o      ( master[AXI_MST_IDX_CVE2_INSTR].w_user       ),
    .w_valid_o     ( master[AXI_MST_IDX_CVE2_INSTR].w_valid      ),
    .w_ready_i     ( master[AXI_MST_IDX_CVE2_INSTR].w_ready      ),

    .b_id_i        ( master[AXI_MST_IDX_CVE2_INSTR].b_id         ),
    .b_resp_i      ( master[AXI_MST_IDX_CVE2_INSTR].b_resp       ),
    .b_valid_i     ( master[AXI_MST_IDX_CVE2_INSTR].b_valid      ),
    .b_user_i      ( master[AXI_MST_IDX_CVE2_INSTR].b_user       ),
    .b_ready_o     ( master[AXI_MST_IDX_CVE2_INSTR].b_ready      ),

    .ar_id_o       ( master[AXI_MST_IDX_CVE2_INSTR].ar_id        ),
    .ar_addr_o     ( master[AXI_MST_IDX_CVE2_INSTR].ar_addr      ),
    .ar_len_o      ( master[AXI_MST_IDX_CVE2_INSTR].ar_len       ),
    .ar_size_o     ( master[AXI_MST_IDX_CVE2_INSTR].ar_size      ),
    .ar_burst_o    ( master[AXI_MST_IDX_CVE2_INSTR].ar_burst     ),
    .ar_lock_o     ( master[AXI_MST_IDX_CVE2_INSTR].ar_lock      ),
    .ar_cache_o    ( master[AXI_MST_IDX_CVE2_INSTR].ar_cache     ),
    .ar_prot_o     ( master[AXI_MST_IDX_CVE2_INSTR].ar_prot      ),
    .ar_region_o   ( master[AXI_MST_IDX_CVE2_INSTR].ar_region    ),
    .ar_user_o     ( master[AXI_MST_IDX_CVE2_INSTR].ar_user      ),
    .ar_qos_o      ( master[AXI_MST_IDX_CVE2_INSTR].ar_qos       ),
    .ar_valid_o    ( master[AXI_MST_IDX_CVE2_INSTR].ar_valid     ),
    .ar_ready_i    ( master[AXI_MST_IDX_CVE2_INSTR].ar_ready     ),

    .r_id_i        ( master[AXI_MST_IDX_CVE2_INSTR].r_id         ),
    .r_data_i      ( master[AXI_MST_IDX_CVE2_INSTR].r_data       ),
    .r_resp_i      ( master[AXI_MST_IDX_CVE2_INSTR].r_resp       ),
    .r_last_i      ( master[AXI_MST_IDX_CVE2_INSTR].r_last       ),
    .r_user_i      ( master[AXI_MST_IDX_CVE2_INSTR].r_user       ),
    .r_valid_i     ( master[AXI_MST_IDX_CVE2_INSTR].r_valid      ),
    .r_ready_o     ( master[AXI_MST_IDX_CVE2_INSTR].r_ready      )
  );
	
  core2axi #(
    .AXI4_ADDRESS_WIDTH ( AxiAddrWidth      ),
    .AXI4_RDATA_WIDTH   ( AxiDataWidth      ),
    .AXI4_WDATA_WIDTH   ( AxiDataWidth      ),
    .AXI4_ID_WIDTH      ( AxiIdWidthMasters ),
    .AXI4_USER_WIDTH    ( AxiUserWidth      ),
    .REGISTERED_GRANT   ( "TRUE "           )
  )
  inst_core2axi_data
  (
    .clk_i         ( wb_clk_i               ),
    .rst_ni        ( rst_n                  ),

    .data_req_i    ( cve2_data_req          ),
    .data_gnt_o    ( cve2_data_gnt          ),
    .data_rvalid_o ( cve2_data_rvalid       ),
    .data_addr_i   ( cve2_data_addr         ),
    .data_we_i     ( cve2_data_we           ),
    .data_be_i     ( cve2_data_be           ),
    .data_rdata_o  ( cve2_data_rdata        ),
    .data_wdata_i  ( cve2_data_wdata        ),

    .aw_id_o       ( master[AXI_MST_IDX_CVE2_DATA].aw_id        ),
    .aw_addr_o     ( master[AXI_MST_IDX_CVE2_DATA].aw_addr      ),
    .aw_len_o      ( master[AXI_MST_IDX_CVE2_DATA].aw_len       ),
    .aw_size_o     ( master[AXI_MST_IDX_CVE2_DATA].aw_size      ),
    .aw_burst_o    ( master[AXI_MST_IDX_CVE2_DATA].aw_burst     ),
    .aw_lock_o     ( master[AXI_MST_IDX_CVE2_DATA].aw_lock      ),
    .aw_cache_o    ( master[AXI_MST_IDX_CVE2_DATA].aw_cache     ),
    .aw_prot_o     ( master[AXI_MST_IDX_CVE2_DATA].aw_prot      ),
    .aw_region_o   ( master[AXI_MST_IDX_CVE2_DATA].aw_region    ),
    .aw_user_o     ( master[AXI_MST_IDX_CVE2_DATA].aw_user      ),
    .aw_qos_o      ( master[AXI_MST_IDX_CVE2_DATA].aw_qos       ),
    .aw_valid_o    ( master[AXI_MST_IDX_CVE2_DATA].aw_valid     ),
    .aw_ready_i    ( master[AXI_MST_IDX_CVE2_DATA].aw_ready     ),

    .w_data_o      ( master[AXI_MST_IDX_CVE2_DATA].w_data       ),
    .w_strb_o      ( master[AXI_MST_IDX_CVE2_DATA].w_strb       ),
    .w_last_o      ( master[AXI_MST_IDX_CVE2_DATA].w_last       ),
    .w_user_o      ( master[AXI_MST_IDX_CVE2_DATA].w_user       ),
    .w_valid_o     ( master[AXI_MST_IDX_CVE2_DATA].w_valid      ),
    .w_ready_i     ( master[AXI_MST_IDX_CVE2_DATA].w_ready      ),

    .b_id_i        ( master[AXI_MST_IDX_CVE2_DATA].b_id         ),
    .b_resp_i      ( master[AXI_MST_IDX_CVE2_DATA].b_resp       ),
    .b_valid_i     ( master[AXI_MST_IDX_CVE2_DATA].b_valid      ),
    .b_user_i      ( master[AXI_MST_IDX_CVE2_DATA].b_user       ),
    .b_ready_o     ( master[AXI_MST_IDX_CVE2_DATA].b_ready      ),

    .ar_id_o       ( master[AXI_MST_IDX_CVE2_DATA].ar_id        ),
    .ar_addr_o     ( master[AXI_MST_IDX_CVE2_DATA].ar_addr      ),
    .ar_len_o      ( master[AXI_MST_IDX_CVE2_DATA].ar_len       ),
    .ar_size_o     ( master[AXI_MST_IDX_CVE2_DATA].ar_size      ),
    .ar_burst_o    ( master[AXI_MST_IDX_CVE2_DATA].ar_burst     ),
    .ar_lock_o     ( master[AXI_MST_IDX_CVE2_DATA].ar_lock      ),
    .ar_cache_o    ( master[AXI_MST_IDX_CVE2_DATA].ar_cache     ),
    .ar_prot_o     ( master[AXI_MST_IDX_CVE2_DATA].ar_prot      ),
    .ar_region_o   ( master[AXI_MST_IDX_CVE2_DATA].ar_region    ),
    .ar_user_o     ( master[AXI_MST_IDX_CVE2_DATA].ar_user      ),
    .ar_qos_o      ( master[AXI_MST_IDX_CVE2_DATA].ar_qos       ),
    .ar_valid_o    ( master[AXI_MST_IDX_CVE2_DATA].ar_valid     ),
    .ar_ready_i    ( master[AXI_MST_IDX_CVE2_DATA].ar_ready     ),

    .r_id_i        ( master[AXI_MST_IDX_CVE2_DATA].r_id         ),
    .r_data_i      ( master[AXI_MST_IDX_CVE2_DATA].r_data       ),
    .r_resp_i      ( master[AXI_MST_IDX_CVE2_DATA].r_resp       ),
    .r_last_i      ( master[AXI_MST_IDX_CVE2_DATA].r_last       ),
    .r_user_i      ( master[AXI_MST_IDX_CVE2_DATA].r_user       ),
    .r_valid_i     ( master[AXI_MST_IDX_CVE2_DATA].r_valid      ),
    .r_ready_o     ( master[AXI_MST_IDX_CVE2_DATA].r_ready      )
  );


////////////////////////////////////////////////////////////////////////////
// AXI RAM
////////////////////////////////////////////////////////////////////////////
	
  axi_ram_2kB #(
    .ID_WIDTH   (AxiIdWidthSlaves      ), // AXI4+ATOP ID width
    .USER_WIDTH (AxiUserWidth          )  // AXI4+ATOP user width
  ) inst_axi_ram_2kB (                 
																       
`ifdef USE_POWER_PINS                  
    .vccd1      (vccd1                 ), // User area 1 1.8V supply
    .vssd1      (vssd1                 ), // User area 1 digital ground
`endif                                           
                                                   
    .clk_i      (wb_clk_i              ), // Clock input
    .rst_ni     (rst_n                 ), // Asynchronous reset, active low
                                             
    //AXI slave interface                    
    .slv        (slave[AXI_SLV_IDX_RAM])  // AXI4+ATOP slave interface port
  );


////////////////////////////////////////////////////////////////////////////
// AXI SystemManager
////////////////////////////////////////////////////////////////////////////
	
  axi_system_manager #(
    .ID_WIDTH   (AxiIdWidthSlaves      ), // AXI4+ATOP ID width
    .USER_WIDTH (AxiUserWidth          )  // AXI4+ATOP user width
  ) inst_axi_system_manager (                 
																       
`ifdef USE_POWER_PINS                  
    .vccd1      (vccd1                 ), // User area 1 1.8V supply
    .vssd1      (vssd1                 ), // User area 1 digital ground
`endif                                           
                                                   
    .clk_i      (wb_clk_i              ), // Clock input
    .rst_ni     (rst_n                 ), // Asynchronous reset, active low
		
    .proc_rst_n (proc_rst_n            ), // Processor reset
                                             
    //AXI slave interface                    
    .slv        (slave[AXI_SLV_IDX_SYS])  // AXI4+ATOP slave interface port
  );

endmodule
