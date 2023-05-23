# SPDX-FileCopyrightText: 2022 , Julien OURY
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
# SPDX-FileContributor: Created by Julien OURY <julien.oury@outlook.fr>

ifndef COCOTB_MK
COCOTB_MK := 1

##########################################################################
# Includes
##########################################################################

include $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/configuration.mk


##########################################################################
# Default configuration
##########################################################################

# Nom du top module
TOPLEVEL         := caravel_th
TOPLEVEL_LANG    := verilog
TOPLEVEL_LIBRARY := work
RTL_LIBRARY      := work

# Nom du fichier de test Python
MODULE := caravel_th

# Simulateur
#SIM := questa
SIM := questa

GUI := 0

# Arguments de compilation pour définir les macros
#COMPILE_ARGS := +define+GPIO_TESTING
#COMPILE_ARGS += +define+LA_TESTING
#
#COMPILE_ARGS := +define+GPIO_TESTING
#COMPILE_ARGS += +define+LA_TESTING

ifeq ($(SIM),questa)
	COMPILE_ARGS :=
	COMPILE_ARGS += +define+FUNCTIONAL
	COMPILE_ARGS += +define+SIM=RTL
	COMPILE_ARGS += +define+USE_POWER_PINS
	COMPILE_ARGS += +define+UNIT_DELAY=#1
	COMPILE_ARGS += +define+TESTNAME=\\\"{top_hex_test}\\\"
	COMPILE_ARGS += +define+MAIN_PATH=$(VERILOG_ROOT)/dv/cocotb/
	COMPILE_ARGS += +define+IVERILOG
	COMPILE_ARGS += +define+TAG=DUMMY_TAG
	VLOG_ARGS    := -mfcu -suppress 2892,2388
	EXTRA_ARGS   := 
endif

ifeq ($(SIM),icarus)
	COMPILE_ARGS :=
	COMPILE_ARGS += -DFUNCTIONAL
	COMPILE_ARGS += -DSIM=RTL
	COMPILE_ARGS += -DUSE_POWER_PINS
	COMPILE_ARGS += -DUNIT_DELAY=#1
	COMPILE_ARGS += -DTESTNAME=top_hex
	COMPILE_ARGS += -DMAIN_PATH=$(VERILOG_ROOT)/dv/cocotb/
	COMPILE_ARGS += -DIVERILOG
	COMPILE_ARGS += -DTAG=DUMMY_TAG
endif

# Inclure le makefile de Cocotb
#include $(shell cocotb-config --makefiles)/Makefile.inc
#include $(shell cocotb-config --makefiles)/Makefile.sim

# Fichiers de source Verilog
CARAVEL_SOURCES :=

## VIP
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/dv/vip/tbuart.v
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/dv/vip/spiflash.v
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/dv/vip/wb_rw_test.v

## DFFRAM Behavioral Model
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/dv/vip/RAM256.v
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/dv/vip/RAM128.v

## DFFRAM Full RTL
#CARAVEL_SOURCES += $(MCW_ROOT)/verilog/rtl/DFFRAM.v
#CARAVEL_SOURCES += $(MCW_ROOT)/verilog/rtl/DFFRAMBB.v

# Mgmt Core Wrapper
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/rtl/defines.v
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/rtl/mgmt_core.v
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/rtl/mgmt_core_wrapper.v
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/rtl/VexRiscv_MinDebugCache.v

# Caravel

## These blocks need to stay in RTL
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/pads.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/defines.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/user_defines.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/mprj_io.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/simple_por.v

## These blocks only needed for RTL sims
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/digital_pll_controller.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/ring_osc2x13.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/clock_div.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/housekeeping_spi.v

CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/chip_io_alt.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/chip_io.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/mprj_logic_high.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/mprj2_logic_high.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/mgmt_protect.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/mgmt_protect_hv.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/gpio_control_block.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/gpio_defaults_block.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/gpio_logic_high.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/constant_block.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/xres_buf.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/spare_logic_block.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/housekeeping.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/caravel_clocking.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/digital_pll.v
#CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/__user_project_wrapper.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/debug_regs.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/user_id_programming.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/buff_flash_clkrst.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/gpio_signal_buffering.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/caravel.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/gpio_signal_buffering_alt.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/caravan.v

## These blocks are manually designed
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_0403.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_1803.v
CARAVEL_SOURCES += $(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_0801.v

# STD CELLS - they need to be below the defines.v files
CARAVEL_SOURCES += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_io/verilog/sky130_fd_io.v
CARAVEL_SOURCES += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_io/verilog/sky130_ef_io.v
CARAVEL_SOURCES += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
CARAVEL_SOURCES += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v
CARAVEL_SOURCES += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hvl/verilog/primitives.v
CARAVEL_SOURCES += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v
#CARAVEL_SOURCES += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_sram_macros/verilog/sky130_sram_2kbyte_1rw1r_32x512_8.v


## STD CELLS - they need to be below the defines.v files
#CARAVEL_SOURCES += $(MCW_ROOT)/cvc-pdk/sky130_ef_io.v
#CARAVEL_SOURCES += $(MCW_ROOT)/cvc-pdk/sky130_fd_io.v
#CARAVEL_SOURCES += $(MCW_ROOT)/cvc-pdk/primitives_hd.v
#CARAVEL_SOURCES += $(MCW_ROOT)/cvc-pdk/sky130_fd_sc_hd.v
#CARAVEL_SOURCES += $(MCW_ROOT)/cvc-pdk/primitives_hvl.v
#CARAVEL_SOURCES += $(MCW_ROOT)/cvc-pdk/sky130_fd_sc_hvl.v
CARAVEL_SOURCES += $(MCW_ROOT)/verilog/cvc-pdk/sky130_sram_2kbyte_1rw1r_32x512_8.v

USER_VERILOG_SOURCES :=
USER_VERILOG_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/defines.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/syn/rtl/prim_clock_gating.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_alu.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_compressed_decoder.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_controller.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_register_file_ff.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_csr.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_cs_registers.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_counter.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_decoder.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_ex_block.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_id_stage.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_if_stage.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_wb_stage.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_load_store_unit.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_slow.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_fast.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_prefetch_buffer.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_fetch_fifo.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_pmp.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_core.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_top.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/wb2axi/wbm2axisp.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/wb2axi/skidbuffer.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/addr_decode.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/spill_register.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/spill_register_flushable.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/rr_arb_tree.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/fifo_v3.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_xbar.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_mux.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_err_slv.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_multicut.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_id_prepend.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_to_mem.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_demux.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/core2axi.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_bus.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/core2axi_wrap.v
USER_VERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi_ram/axi_ram_1kB.sv

USER_SYSVERILOG_SOURCES :=
USER_SYSVERILOG_SOURCES += $(CARAVEL_ROOT)/verilog/rtl/defines.v
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/syn/rtl/prim_clock_gating.v
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_pkg.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_alu.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_compressed_decoder.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_controller.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_register_file_ff.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_csr.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_cs_registers.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_counter.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_decoder.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_ex_block.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_id_stage.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_if_stage.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_wb_stage.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_load_store_unit.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_slow.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_fast.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_prefetch_buffer.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_fetch_fifo.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_pmp.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_core.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_top.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/cve2/cve2.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/wb2axi/wbm2axisp.v
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/wb2axi/skidbuffer.v
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/cf_math_pkg.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_pkg.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_intf.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/addr_decode.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/spill_register.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/spill_register_flushable.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/rr_arb_tree.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/fifo_v3.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_xbar.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_mux.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_err_slv.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_multicut.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_id_prepend.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_to_mem.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_demux.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/core2axi.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/axi_bus.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi/core2axi_wrap.sv
USER_SYSVERILOG_SOURCES += $(VERILOG_ROOT)/rtl/axi_ram/axi_ram_1kB.sv

VERILOG_SOURCES := $(CARAVEL_SOURCES)
VERILOG_SOURCES += $(USER_SYSVERILOG_SOURCES)
VERILOG_SOURCES += $(VERILOG_ROOT)/dv/cocotb/caravel_th.sv

VHDL_SOURCES :=

COCOTB_TEMP     := $(VERILOG_ROOT)/dv/cocotb/simu_temp


##########################################################################
# Simulation
##########################################################################

.PHONY: cocotb_questa_top
cocotb_questa_top:

	if [ -d "$(COCOTB_TEMP)" ]; then\
		echo "Deleting exisiting $(COCOTB_TEMP)" && \
		rm -rf $(COCOTB_TEMP) && sleep 2;\
	fi
	
	# Create temp folder (if not already exist)
	mkdir -p $(COCOTB_TEMP)

	{ \
	export PATH=$(PATH);\
	export SIM_BUILD=$(COCOTB_TEMP);\
	export GUI=$(GUI);\
	export TOPLEVEL_LANG=$(TOPLEVEL_LANG);\
	export TOPLEVEL_LIBRARY=$(TOPLEVEL_LIBRARY);\
	export RTL_LIBRARY=$(RTL_LIBRARY);\
	export MODULE=$(MODULE);\
	export VHDL_SOURCES="$(VHDL_SOURCES)";\
	export VERILOG_SOURCES="$(VERILOG_SOURCES)";\
	export SIM="$(SIM)";\
	export COMPILE_ARGS="$(COMPILE_ARGS)";\
	export VLOG_ARGS="$(VLOG_ARGS)";\
	export EXTRA_ARGS="$(EXTRA_ARGS)";\
	cd $(COCOTB_TEMP);\
	make -f $(shell cocotb-config --makefiles)/Makefile.sim TOPLEVEL:=$(TOPLEVEL);\
	}


##########################################################################
endif
