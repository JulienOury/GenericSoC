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

##########################################################################
# Arguments
##########################################################################

ifeq ($(CARAVEL_ROOT),)
  $(error Error : CARAVEL_ROOT is not defined !)
endif
ifeq ($(VERILOG_ROOT),)
  $(error Error : VERILOG_ROOT is not defined !)
endif


##########################################################################
# Default configuration
##########################################################################

$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/defines.v                                                     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/syn/rtl/prim_clock_gating.v                      )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_pkg.sv                                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_alu.sv                                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_compressed_decoder.sv                   )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_controller.sv                           )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_register_file_ff.sv                     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_csr.sv                                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_cs_registers.sv                         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_counter.sv                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_decoder.sv                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_ex_block.sv                             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_id_stage.sv                             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_if_stage.sv                             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_wb_stage.sv                             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_load_store_unit.sv                      )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_slow.sv                         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_fast.sv                         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_prefetch_buffer.sv                      )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_fetch_fifo.sv                           )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_pmp.sv                                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_core.sv                                 )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_tracer_pkg.sv                           ) ##Not added in sv2v conversion (only for RVFI)
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_tracer.sv                               ) ##Not added in sv2v conversion (only for RVFI)
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_top.sv                                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2.sv                                                          )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/wb2axi/wbm2axisp.v                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/wb2axi/skidbuffer.v                                                   )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/cf_math_pkg.sv                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_pkg.sv                                                        )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_intf.sv                                                       )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/addr_decode.sv                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/spill_register.sv                                                 )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/spill_register_flushable.sv                                       )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/rr_arb_tree.sv                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/fifo_v3.sv                                                        )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_xbar.sv                                                       )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_mux.sv                                                        )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_err_slv.sv                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_multicut.sv                                                   )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_id_prepend.sv                                                 )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_to_mem.sv                                                     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_demux.sv                                                      )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/core2axi.sv                                                       )
###$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_bus.sv                                                        )
###$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/core2axi_wrap.sv                                                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi_ram/axi_ram_1kB.sv                                                )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi_ram/axi_ram_2kB.sv                                                ) ##Not added in sv2v conversion

$(eval $(LIST_NAME) += $(VERILOG_ROOT)/beh/sky130_sram_1kbyte_1rw1r_32x256_8.v                                   )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/beh/sky130_sram_2kbyte_1rw1r_32x512_8.v                                   ) ##Not added in sv2v conversion
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/main_partition.sv                                                     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/user_project_wrapper.v                                                )

##Not added in sv2v conversion
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/stream_mux.sv          )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/stream_fork.sv         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/stream_fifo.sv         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/stream_to_mem.sv       )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/mem_to_banks.sv        )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/stream_join.sv         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/stream_fork_dynamic.sv )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/stream_register.sv     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/counter.sv             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/delta_counter.sv       )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/lzc.sv                 )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_atop_filter.sv     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_cut.sv             )

$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi_system_manager.sv )

$(eval $(LIST_NAME) += $(VERILOG_ROOT)/beh/reloadable_spiflash.v )

##########################################################################
