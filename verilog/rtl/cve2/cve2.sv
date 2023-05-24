////////////////////////////////////////////////////////////////////////////
// SPDX-FileCopyrightText: 2022 , Julien OURY
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
module cve2 (

`ifdef USE_POWER_PINS
    inout  wire vccd1,  // User area 1 1.8V supply
    inout  wire vssd1,  // User area 1 digital ground
`endif

  // Clock and Reset
  input  logic                         clk_i                  ,
  input  logic                         rst_ni                 ,

  input  logic                         test_en_i              , // enable all clock gates for testing

  // Instruction memory interface
  output logic                         instr_req_o            ,
  input  logic                         instr_gnt_i            ,
  input  logic                         instr_rvalid_i         ,
  output logic [31:0]                  instr_addr_o           ,
  input  logic [31:0]                  instr_rdata_i          ,
  input  logic                         instr_err_i            ,

  // Data memory interface
  output logic                         data_req_o             ,
  input  logic                         data_gnt_i             ,
  input  logic                         data_rvalid_i          ,
  output logic                         data_we_o              ,
  output logic [3:0]                   data_be_o              ,
  output logic [31:0]                  data_addr_o            ,
  output logic [31:0]                  data_wdata_o           ,
  input  logic [31:0]                  data_rdata_i           ,
  input  logic                         data_err_i             ,

  // Interrupt inputs
  input  logic                         irq_software_i         ,
  input  logic                         irq_timer_i            ,
  input  logic                         irq_external_i         ,
  input  logic [14:0]                  irq_fast_i             ,
  input  logic                         irq_nm_i               , // non-maskeable interrupt

  // Debug Interface
  input  logic                         debug_req_i            ,

  // CPU Control Signals
  output logic                         core_sleep_o           ,

  // DFT bypass controls
  input logic                          scan_rst_ni
);

  import cve2_pkg::*;
  import prim_ram_1p_pkg::*;

  // Définition des constantes pour les paramètres par défaut
  localparam int unsigned MHPMCounterNum   = 0;
  localparam int unsigned MHPMCounterWidth = 40;
  localparam bit          RV32E            = 1'b0;
  localparam rv32m_e      RV32M            = RV32MFast;
  localparam bit          WritebackStage   = 1'b0;
  localparam bit          BranchPredictor  = 1'b0;
  localparam int unsigned DmHaltAddr       = 32'h1A110800;
  localparam int unsigned DmExceptionAddr  = 32'h1A110808;
  
  localparam logic [31:0] hart_id_i        = 32'h00000001;
  localparam logic [31:0] boot_addr_i      = 32'h30000000;
  
  localparam prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i = prim_ram_1p_pkg::RAM_1P_CFG_DEFAULT;
  
  //ram_cfg_i.ram_cfg.cfg_en = 1'b0;
  //ram_cfg_i.ram_cfg.cfg    = 4'b0000;
  //ram_cfg_i.rf_cfg.cfg_en  = 1'b0;
  //ram_cfg_i.rf_cfg.cfg     = 4'b0000;
	
	wire [  6:0] dummy_data_wdata_intg_o;
	wire [127:0] dummy_crash_dump_o     ;
	
`ifdef RVFI
  logic        rvfi_valid         ;
  logic [63:0] rvfi_order         ;
  logic [31:0] rvfi_insn          ;
  logic        rvfi_trap          ;
  logic        rvfi_halt          ;
  logic        rvfi_intr          ;
  logic [ 1:0] rvfi_mode          ;
  logic [ 1:0] rvfi_ixl           ;
  logic [ 4:0] rvfi_rs1_addr      ;
  logic [ 4:0] rvfi_rs2_addr      ;
  logic [ 4:0] rvfi_rs3_addr      ;
  logic [31:0] rvfi_rs1_rdata     ;
  logic [31:0] rvfi_rs2_rdata     ;
  logic [31:0] rvfi_rs3_rdata     ;
  logic [ 4:0] rvfi_rd_addr       ;
  logic [31:0] rvfi_rd_wdata      ;
  logic [31:0] rvfi_pc_rdata      ;
  logic [31:0] rvfi_pc_wdata      ;
  logic [31:0] rvfi_mem_addr      ;
  logic [ 3:0] rvfi_mem_rmask     ;
  logic [ 3:0] rvfi_mem_wmask     ;
  logic [31:0] rvfi_mem_rdata     ;
  logic [31:0] rvfi_mem_wdata     ;
  logic [31:0] rvfi_ext_mip       ;
  logic        rvfi_ext_nmi       ;
  logic        rvfi_ext_debug_req ;
  logic [63:0] rvfi_ext_mcycle    ;
`endif

  // Instanciation du module cve2_top avec les paramètres par défaut
  cve2_top #(
    .MHPMCounterNum             (MHPMCounterNum          ),
    .MHPMCounterWidth           (MHPMCounterWidth        ),
    .RV32E                      (RV32E                   ),
    .RV32M                      (RV32M                   ),
    .WritebackStage             (WritebackStage          ),
    .BranchPredictor            (BranchPredictor         ),
    .DmHaltAddr                 (DmHaltAddr              ),
    .DmExceptionAddr            (DmExceptionAddr         )
  ) u_cve2_top (
    .clk_i                      (clk_i                   ),
    .rst_ni                     (rst_ni                  ),
    .test_en_i                  (test_en_i               ),
    .ram_cfg_i                  (ram_cfg_i               ),
    .hart_id_i                  (hart_id_i               ),
    .boot_addr_i                (boot_addr_i             ),
    .instr_req_o                (instr_req_o             ),
    .instr_gnt_i                (instr_gnt_i             ),
    .instr_rvalid_i             (instr_rvalid_i          ),
    .instr_addr_o               (instr_addr_o            ),
    .instr_rdata_i              (instr_rdata_i           ),
    .instr_rdata_intg_i         (7'b0000000              ),
    .instr_err_i                (instr_err_i             ),
    .data_req_o                 (data_req_o              ),
    .data_gnt_i                 (data_gnt_i              ),
    .data_rvalid_i              (data_rvalid_i           ),
    .data_we_o                  (data_we_o               ),
    .data_be_o                  (data_be_o               ),
    .data_addr_o                (data_addr_o             ),
    .data_wdata_o               (data_wdata_o            ),
    .data_wdata_intg_o          (dummy_data_wdata_intg_o ),
    .data_rdata_i               (data_rdata_i            ),
    .data_rdata_intg_i          (7'b0000000              ),
    .data_err_i                 (data_err_i              ),
    .irq_software_i             (irq_software_i          ),
    .irq_timer_i                (irq_timer_i             ),
    .irq_external_i             (irq_external_i          ),
    .irq_fast_i                 (irq_fast_i              ),
    .irq_nm_i                   (irq_nm_i                ),
    .debug_req_i                (debug_req_i             ),
    .crash_dump_o               (dummy_crash_dump_o      ),
`ifdef RVFI
    .rvfi_valid                 (rvfi_valid              ),
    .rvfi_order                 (rvfi_order              ),
    .rvfi_insn                  (rvfi_insn               ),
    .rvfi_trap                  (rvfi_trap               ),
    .rvfi_halt                  (rvfi_halt               ),
    .rvfi_intr                  (rvfi_intr               ),
    .rvfi_mode                  (rvfi_mode               ),
    .rvfi_ixl                   (rvfi_ixl                ),
    .rvfi_rs1_addr              (rvfi_rs1_addr           ),
    .rvfi_rs2_addr              (rvfi_rs2_addr           ),
    .rvfi_rs3_addr              (rvfi_rs3_addr           ),
    .rvfi_rs1_rdata             (rvfi_rs1_rdata          ),
    .rvfi_rs2_rdata             (rvfi_rs2_rdata          ),
    .rvfi_rs3_rdata             (rvfi_rs3_rdata          ),
    .rvfi_rd_addr               (rvfi_rd_addr            ),
    .rvfi_rd_wdata              (rvfi_rd_wdata           ),
    .rvfi_pc_rdata              (rvfi_pc_rdata           ),
    .rvfi_pc_wdata              (rvfi_pc_wdata           ),
    .rvfi_mem_addr              (rvfi_mem_addr           ),
    .rvfi_mem_rmask             (rvfi_mem_rmask          ),
    .rvfi_mem_wmask             (rvfi_mem_wmask          ),
    .rvfi_mem_rdata             (rvfi_mem_rdata          ),
    .rvfi_mem_wdata             (rvfi_mem_wdata          ),
    .rvfi_ext_mip               (rvfi_ext_mip            ),
    .rvfi_ext_nmi               (rvfi_ext_nmi            ),
    .rvfi_ext_debug_req         (rvfi_ext_debug_req      ),
    .rvfi_ext_mcycle            (rvfi_ext_mcycle         ),
`endif
    .alert_minor_o              (open                    ),
    .alert_major_internal_o     (open                    ),
    .alert_major_bus_o          (open                    ),
    .core_sleep_o               (core_sleep_o            ),
    .scan_rst_ni                (scan_rst_ni             )
  );
	
`ifdef RVFI
  cve2_tracer
  u_cve2_tracer (
    .clk_i,
    .rst_ni,

    .hart_id_i,

    .rvfi_valid,
    .rvfi_order,
    .rvfi_insn,
    .rvfi_trap,
    .rvfi_halt,
    .rvfi_intr,
    .rvfi_mode,
    .rvfi_ixl,
    .rvfi_rs1_addr,
    .rvfi_rs2_addr,
    .rvfi_rs3_addr,
    .rvfi_rs1_rdata,
    .rvfi_rs2_rdata,
    .rvfi_rs3_rdata,
    .rvfi_rd_addr,
    .rvfi_rd_wdata,
    .rvfi_pc_rdata,
    .rvfi_pc_wdata,
    .rvfi_mem_addr,
    .rvfi_mem_rmask,
    .rvfi_mem_wmask,
    .rvfi_mem_rdata,
    .rvfi_mem_wdata
  );
`endif

endmodule