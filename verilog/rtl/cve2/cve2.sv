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
module cve2 #(
) (

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
  input  logic [6:0]                   instr_rdata_intg_i     ,
  input  logic                         instr_err_i            ,

  // Data memory interface
  output logic                         data_req_o             ,
  input  logic                         data_gnt_i             ,
  input  logic                         data_rvalid_i          ,
  output logic                         data_we_o              ,
  output logic [3:0]                   data_be_o              ,
  output logic [31:0]                  data_addr_o            ,
  output logic [31:0]                  data_wdata_o           ,
  output logic [6:0]                   data_wdata_intg_o      ,
  input  logic [31:0]                  data_rdata_i           ,
  input  logic [6:0]                   data_rdata_intg_i      ,
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
  output logic                         alert_minor_o          ,
  output logic                         alert_major_internal_o ,
  output logic                         alert_major_bus_o      ,
  output logic                         core_sleep_o           ,

  // DFT bypass controls
  input logic                          scan_rst_ni
);

  // Définition des constantes pour les paramètres par défaut
  localparam int unsigned MHPMCounterNum   = 0;
  localparam int unsigned MHPMCounterWidth = 40;
  localparam bit          RV32E            = 1'b0;
  localparam rv32m_e      RV32M            = RV32MFast;
  localparam bit          WritebackStage   = 1'b0;
  localparam bit          BranchPredictor  = 1'b0;
  localparam int unsigned DmHaltAddr       = 32'h1A110800;
  localparam int unsigned DmExceptionAddr  = 32'h1A110808;
  
  localparam logic [31:0] hart_id_i        = 32'h1234ABCD;
  localparam logic [31:0] boot_addr_i      = 32'h00000000;
  
  localparam prim_ram_1p_pkg::ram_1p_cfg_t ram_cfg_i;
  
  ram_cfg_i.ram_cfg.cfg_en = 1'b0;
  ram_cfg_i.ram_cfg.cfg    = 4'b0000;
  ram_cfg_i.rf_cfg.cfg_en  = 1'b0;
  ram_cfg_i.rf_cfg.cfg     = 4'b0000;

  // Instanciation du module cve2_top avec les paramètres par défaut
  cve2_top #(
    .MHPMCounterNum             (MHPMCounterNum        ),
    .MHPMCounterWidth           (MHPMCounterWidth      ),
    .RV32E                      (RV32E                 ),
    .RV32M                      (RV32M                 ),
    .WritebackStage             (WritebackStage        ),
    .BranchPredictor            (BranchPredictor       ),
    .DmHaltAddr                 (DmHaltAddr            ),
    .DmExceptionAddr            (DmExceptionAddr       )
  ) u_cve2_top (
    .clk_i                      (clk_i                 ),
    .rst_ni                     (rst_ni                ),
    .test_en_i                  (test_en_i             ),
    .ram_cfg_i                  (ram_cfg_i             ),
    .hart_id_i                  (hart_id_i             ),
    .boot_addr_i                (boot_addr_i           ),
    .instr_req_o                (instr_req_o           ),
    .instr_gnt_i                (instr_gnt_i           ),
    .instr_rvalid_i             (instr_rvalid_i        ),
    .instr_addr_o               (instr_addr_o          ),
    .instr_rdata_i              (instr_rdata_i         ),
    .instr_rdata_intg_i         (instr_rdata_intg_i    ),
    .instr_err_i                (instr_err_i           ),
    .data_req_o                 (data_req_o            ),
    .data_gnt_i                 (data_gnt_i            ),
    .data_rvalid_i              (data_rvalid_i         ),
    .data_we_o                  (data_we_o             ),
    .data_be_o                  (data_be_o             ),
    .data_addr_o                (data_addr_o           ),
    .data_wdata_o               (data_wdata_o          ),
    .data_wdata_intg_o          (data_wdata_intg_o     ),
    .data_rdata_i               (data_rdata_i          ),
    .data_rdata_intg_i          (data_rdata_intg_i     ),
    .data_err_i                 (data_err_i            ),
    .irq_software_i             (irq_software_i        ),
    .irq_timer_i                (irq_timer_i           ),
    .irq_external_i             (irq_external_i        ),
    .irq_fast_i                 (irq_fast_i            ),
    .irq_nm_i                   (irq_nm_i              ),
    .debug_req_i                (debug_req_i           ),
    .crash_dump_o               (open                  ),
    .rvfi_valid                 (open                  ),
    .rvfi_order                 (open                  ),
    .rvfi_insn                  (open                  ),
    .rvfi_trap                  (open                  ),
    .rvfi_halt                  (open                  ),
    .rvfi_intr                  (open                  ),
    .rvfi_mode                  (open                  ),
    .rvfi_ixl                   (open                  ),
    .rvfi_rs1_addr              (open                  ),
    .rvfi_rs2_addr              (open                  ),
    .rvfi_rs3_addr              (open                  ),
    .rvfi_rs1_rdata             (open                  ),
    .rvfi_rs2_rdata             (open                  ),
    .rvfi_rs3_rdata             (open                  ),
    .rvfi_rd_addr               (open                  ),
    .rvfi_rd_wdata              (open                  ),
    .rvfi_pc_rdata              (open                  ),
    .rvfi_pc_wdata              (open                  ),
    .rvfi_mem_addr              (open                  ),
    .rvfi_mem_rmask             (open                  ),
    .rvfi_mem_wmask             (open                  ),
    .rvfi_mem_rdata             (open                  ),
    .rvfi_mem_wdata             (open                  ),
    .rvfi_ext_mip               (open                  ),
    .rvfi_ext_nmi               (open                  ),
    .rvfi_ext_debug_req         (open                  ),
    .rvfi_ext_mcycle            (open                  ),
    .alert_minor_o              (alert_minor_o         ),
    .alert_major_internal_o     (alert_major_internal_o),
    .alert_major_bus_o          (alert_major_bus_o     ),
    .core_sleep_o               (core_sleep_o          ),
    .scan_rst_ni                (scan_rst_ni           )
