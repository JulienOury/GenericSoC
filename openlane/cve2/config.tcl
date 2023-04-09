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

set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/defines.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/generic_sram_1rw1r.v \
	$::env(DESIGN_DIR)/../../verilog/rtl/inferred_sram_1rw1r.v \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_pkg.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_alu.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_compressed_decoder.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_controller.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_cs_registers.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_counters.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_decoder.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_ex_block.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_id_stage.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_if_stage.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_wb_stage.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_load_store_unit.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_multdiv_slow.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_multdiv_fast.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_prefetch_buffer.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_fetch_fifo.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_pmp.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/rtl/cve2_core.sv \
  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2.sv \
  "
  
#$::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core/shared/rtl/prim_assert.sv \

set ::env(DESIGN_IS_CORE) 0

set ::env(CLOCK_PORT)   "clk_i"
set ::env(CLOCK_NET)    "clk_i"
set ::env(CLOCK_PERIOD) "10"

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1200 1400"

set ::env(FP_PIN_ORDER_CFG) $::env(DESIGN_DIR)/pin_order.cfg

set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY)  0.32

#set ::env(SYNTH_USE_PG_PINS_DEFINES) "USE_POWER_PINS"

set ::env(FP_CORE_UTIL) 40

set ::env(SYNTH_MAX_FANOUT) 4

#set ::env(PL_TIME_DRIVEN) 
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