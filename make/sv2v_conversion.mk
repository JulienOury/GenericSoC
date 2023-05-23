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

ifndef SV2V_CONVERSION_MK
SV2V_CONVERSION_MK := 1

##########################################################################
# Includes
##########################################################################
include $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/configuration.mk


##########################################################################
# SystemVerilog to Verilog conversion
##########################################################################

.PHONY: sv2v_convert
sv2v_convert: cve2_convert  \
              axi_convert


##########################################################################
# Delete conversion files
##########################################################################

.PHONY: sv2v_delete_converted
sv2v_delete_converted: cve2_delete_converted \
                       axi_delete_converted


##########################################################################
# CVE2
##########################################################################

export CVE2_ROOT := $(VERILOG_ROOT)/rtl/cve2

.PHONY: cve2_convert
cve2_convert: cve2_delete_converted
	export PATH=${PATH} && \
	sv2v -w adjacent                                                       \
		--define=SYNTHESIS                                                   \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_pkg.sv"                                  \
		"$(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv"     \
		"$(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv" \
		"$(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv" \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_alu.sv"                                  \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_compressed_decoder.sv"                   \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_controller.sv"                           \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_csr.sv"                                  \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_cs_registers.sv"                         \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_load_store_unit.sv"                      \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_prefetch_buffer.sv"                      \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_counter.sv"                              \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_decoder.sv"                              \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_ex_block.sv"                             \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_id_stage.sv"                             \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_if_stage.sv"                             \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_wb_stage.sv"                             \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_multdiv_slow.sv"                         \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_multdiv_fast.sv"                         \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_fetch_fifo.sv"                           \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_pmp.sv"                                  \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_register_file_ff.sv"                     \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_core.sv"                                 \
		"$(CVE2_ROOT)/cve2-core-local/rtl/cve2_top.sv"                                  \
		"$(CVE2_ROOT)/cve2.sv"
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_pkg.v
	rm -f $(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.v
	rm -f $(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.v

.PHONY: cve2_delete_converted
cve2_delete_converted:
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_pkg.v
	rm -f $(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.v
	rm -f $(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.v
	rm -f $(CVE2_ROOT)/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_alu.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_compressed_decoder.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_controller.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_csr.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_cs_registers.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_load_store_unit.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_prefetch_buffer.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_counter.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_decoder.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_ex_block.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_id_stage.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_if_stage.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_wb_stage.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_multdiv_slow.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_multdiv_fast.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_fetch_fifo.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_pmp.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_register_file_ff.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_core.v
	rm -f $(CVE2_ROOT)/cve2-core-local/rtl/cve2_top.v
	rm -f $(CVE2_ROOT)/cve2.v

##########################################################################
# AXI
##########################################################################

export AXI_ROOT  := $(VERILOG_ROOT)/rtl/axi

.PHONY: axi_convert
axi_convert: axi_delete_converted
	- export PATH=${PATH} && \
	sv2v -w adjacent                                                  \
		--define=SYNTHESIS                                              \
		--define=VERILATOR                                              \
		$(AXI_ROOT)/cf_math_pkg.sv                                      \
		$(AXI_ROOT)/addr_decode.sv                                      \
		$(AXI_ROOT)/spill_register.sv                                   \
		$(AXI_ROOT)/spill_register_flushable.sv                         \
		$(AXI_ROOT)/rr_arb_tree.sv                                      \
		$(AXI_ROOT)/fifo_v3.sv                                          \
		$(AXI_ROOT)/axi_pkg.sv                                          \
		$(AXI_ROOT)/axi_intf.sv                                         \
		$(AXI_ROOT)/axi_xbar.sv                                         \
		$(AXI_ROOT)/axi_mux.sv                                          \
		$(AXI_ROOT)/axi_demux.sv                                        \
		$(AXI_ROOT)/axi_err_slv.sv                                      \
		$(AXI_ROOT)/axi_multicut.sv                                     \
		$(AXI_ROOT)/axi_id_prepend.sv                                   \
		$(AXI_ROOT)/axi_to_mem.sv                                       \
		$(AXI_ROOT)/core2axi.sv                                         \
		$(AXI_ROOT)/axi_bus.sv                                          \
		$(AXI_ROOT)/core2axi_wrap.sv                                    \
		$(AXI_ROOT)/../../../caravel/verilog/rtl/defines.v              \
		$(AXI_ROOT)/../main_partition.sv
	rm -f $(AXI_ROOT)/axi_pkg.v
	rm -f $(AXI_ROOT)/axi_intf.v

.PHONY: axi_delete_converted
axi_delete_converted:
	rm -f $(AXI_ROOT)/cf_math_pkg.v              
	rm -f $(AXI_ROOT)/addr_decode.v              
	rm -f $(AXI_ROOT)/spill_register.v           
	rm -f $(AXI_ROOT)/spill_register_flushable.v 
	rm -f $(AXI_ROOT)/rr_arb_tree.v              
	rm -f $(AXI_ROOT)/fifo_v3.v
	rm -f $(AXI_ROOT)/axi_pkg.v
	rm -f $(AXI_ROOT)/axi_intf.v
	rm -f $(AXI_ROOT)/axi_xbar.v                 
	rm -f $(AXI_ROOT)/axi_mux.v                  
	rm -f $(AXI_ROOT)/axi_demux.v                
	rm -f $(AXI_ROOT)/axi_err_slv.v              
	rm -f $(AXI_ROOT)/axi_multicut.v             
	rm -f $(AXI_ROOT)/axi_id_prepend.v           
	rm -f $(AXI_ROOT)/axi_to_mem.v               
	rm -f $(AXI_ROOT)/core2axi.v                 
	rm -f $(AXI_ROOT)/axi_bus.v                  
	rm -f $(AXI_ROOT)/core2axi_wrap.v


##########################################################################
endif
