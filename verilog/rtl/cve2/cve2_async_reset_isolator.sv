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

module cve2_async_reset_isolator (

  // Synchronous clear
  input  wire        clear_n        ,

  // BUS SIDE
  input  wire        clk_i          ,
  input  wire        rst_ni         ,
  input  wire        test_en_i      ,
  output wire        instr_req_o    ,
  input  wire        instr_gnt_i    ,
  input  wire        instr_rvalid_i ,
  output wire [31:0] instr_addr_o   ,
  input  wire [31:0] instr_rdata_i  ,
  input  wire        instr_err_i    ,
  output wire        data_req_o     ,
  input  wire        data_gnt_i     ,
  input  wire        data_rvalid_i  ,
  output wire        data_we_o      ,
  output wire [3:0]  data_be_o      ,
  output wire [31:0] data_addr_o    ,
  output wire [31:0] data_wdata_o   ,
  input  wire [31:0] data_rdata_i   ,
  input  wire        data_err_i     ,
  input  wire        irq_software_i ,
  input  wire        irq_timer_i    ,
  input  wire        irq_external_i ,
  input  wire [14:0] irq_fast_i     ,
  input  wire        irq_nm_i       ,
  input  wire        debug_req_i    ,
  output wire        core_sleep_o   ,
  input  wire        scan_rst_ni    ,

  // PROC SIDE
  output wire        clk_o          ,
  output wire        rst_no         ,
  output wire        test_en_o      ,
  input  wire        instr_req_i    ,
  output wire        instr_gnt_o    ,
  output wire        instr_rvalid_o ,
  input  wire [31:0] instr_addr_i   ,
  output wire [31:0] instr_rdata_o  ,
  output wire        instr_err_o    ,
  input  wire        data_req_i     ,
  output wire        data_gnt_o     ,
  output wire        data_rvalid_o  ,
  input  wire        data_we_i      ,
  input  wire [3:0]  data_be_i      ,
  input  wire [31:0] data_addr_i    ,
  input  wire [31:0] data_wdata_i   ,
  output wire [31:0] data_rdata_o   ,
  output wire        data_err_o     ,
  output wire        irq_software_o ,
  output wire        irq_timer_o    ,
  output wire        irq_external_o ,
  output wire [14:0] irq_fast_o     ,
  output wire        irq_nm_o       ,
  output wire        debug_req_o    ,
  input  wire        core_sleep_i   ,
  output wire        scan_rst_no
);

  reg proc_clear_n   ;
  reg proc_clear_n_r ;

  //Generate synchronous reset
  always @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      proc_clear_n   <= 1'b0;
      proc_clear_n_r <= 1'b0;
    end else begin
      if (clear_n == 1'b0) begin
        proc_clear_n   <= 1'b0;
        proc_clear_n_r <= proc_clear_n;
      end else begin
        proc_clear_n   <= 1'b1;
        proc_clear_n_r <= 1'b1;
      end
    end
  end

  // CORE to BUS
  assign instr_req_o    = (proc_clear_n == 1'b0) ?  1'b0 : instr_req_i  ;
  assign instr_addr_o   = (proc_clear_n == 1'b0) ? 32'b0 : instr_addr_i ;
  assign data_req_o     = (proc_clear_n == 1'b0) ?  1'b0 : data_req_i   ;
  assign data_we_o      = (proc_clear_n == 1'b0) ?  1'b0 : data_we_i    ;
  assign data_be_o      = (proc_clear_n == 1'b0) ?  1'b0 : data_be_i    ;
  assign data_addr_o    = (proc_clear_n == 1'b0) ? 32'b0 : data_addr_i  ;
  assign data_wdata_o   = (proc_clear_n == 1'b0) ? 32'b0 : data_wdata_i ;
  assign core_sleep_o   = (proc_clear_n == 1'b0) ?  1'b0 : core_sleep_i ;

  // BUS to CORE
  assign clk_o          = clk_i                    ;
  assign rst_no         = proc_clear_n_r && rst_ni ;
  assign test_en_o      = test_en_i                ;
  assign instr_gnt_o    = instr_gnt_i              ;
  assign instr_rvalid_o = instr_rvalid_i           ;
  assign instr_rdata_o  = instr_rdata_i            ;
  assign instr_err_o    = instr_err_i              ;
  assign data_gnt_o     = data_gnt_i               ;
  assign data_rvalid_o  = data_rvalid_i            ;
  assign data_rdata_o   = data_rdata_i             ;
  assign data_err_o     = data_err_i               ;
  assign irq_software_o = irq_software_i           ;
  assign irq_timer_o    = irq_timer_i              ;
  assign irq_external_o = irq_external_i           ;
  assign irq_fast_o     = irq_fast_i               ;
  assign irq_nm_o       = irq_nm_i                 ;
  assign debug_req_o    = debug_req_i              ;
  assign scan_rst_no    = scan_rst_ni              ;

endmodule
