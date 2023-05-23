# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set ::env(PDK) "sky130A"
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

set ::env(DESIGN_NAME) cve2

set ::env(VERILOG_FILES) "                                                                                  /
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v                                                                /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/syn/rtl/prim_clock_gating.v                     /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.v     /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_alu.v                                  /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_compressed_decoder.v                   /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_controller.v                           /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_register_file_ff.v                     /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_csr.v                                  /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_cs_registers.v                         /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_counter.sv                             /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_decoder.v                              /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_ex_block.v                             /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_id_stage.v                             /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_if_stage.v                             /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_wb_stage.v                             /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_load_store_unit.v                      /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_slow.v                         /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_fast.v                         /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_prefetch_buffer.v                      /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_fetch_fifo.v                           /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_pmp.v                                  /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_core.v                                 /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_top.v                                  /
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2.v                                                          /
  $::env(DESIGN_DIR)/../../verilog/rtl/wb2axi/wbm2axisp.v                                                   /
  $::env(DESIGN_DIR)/../../verilog/rtl/wb2axi/skidbuffer.v                                                  /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/addr_decode.v                                                    /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/spill_register.v                                                 /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/spill_register_flushable.v                                       /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/rr_arb_tree.v                                                    /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/fifo_v3.v                                                        /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_xbar.v                                                       /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_mux.v                                                        /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_err_slv.v                                                    /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_multicut.v                                                   /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_id_prepend.v                                                 /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_to_mem.v                                                     /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_demux.v                                                      /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/core2axi.v                                                       /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/axi_bus.v                                                        /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi/core2axi_wrap.v                                                  /
  $::env(DESIGN_DIR)/../../verilog/rtl/axi_ram/axi_ram_1kB.v                                                
	"

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT)   "clk_i"
set ::env(CLOCK_NET)    "clk_i"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1000 1000"
set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY)  0.40

#set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"

set ::env(FP_CORE_UTIL) 40

set ::env(SYNTH_STRATEGY) "DELAY 3"
set ::env(SYNTH_MAX_FANOUT) 4

set ::env(PL_TIME_DRIVEN) 
set ::env(PL_RESIZER_HOLD_SLACK_MARGIN) 0.25
set ::env(GLB_RESIZER_HOLD_SLACK_MARGIN) 0.25

# Maximum layer used for routing is metal 4.
# This is because this macro will be inserted in a top level (user_project_wrapper) 
# where the PDN is planned on metal 5. So, to avoid having shorts between routes
# in this macro and the top level metal 5 stripes, we have to restrict routes to metal4.  
# 
#set ::env(GLB_RT_MAXLAYER) 5
set ::env(RT_MAX_LAYER) {met4}

# You can draw more power domains if you need to 
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

set ::env(DIODE_INSERTION_STRATEGY) 4

# If you're going to use multiple power domains, then disable cvc run.
set ::env(RUN_CVC) 1