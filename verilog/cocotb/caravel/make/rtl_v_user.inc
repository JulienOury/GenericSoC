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

$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/defines.v                                                )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/syn/rtl/prim_clock_gating.v                 )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.v )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_alu.v                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_compressed_decoder.v               )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_controller.v                       )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_register_file_ff.v                 )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_csr.v                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_cs_registers.v                     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_counter.v                          )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_decoder.v                          )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_ex_block.v                         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_id_stage.v                         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_if_stage.v                         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_wb_stage.v                         )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_load_store_unit.v                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_slow.v                     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_multdiv_fast.v                     )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_prefetch_buffer.v                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_fetch_fifo.v                       )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_pmp.v                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_core.v                             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2-core-local/rtl/cve2_top.v                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/cve2/cve2.v                                                      )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/wb2axi/wbm2axisp.v                                               )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/wb2axi/skidbuffer.v                                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/addr_decode.v                                                )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/spill_register.v                                             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/spill_register_flushable.v                                   )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/rr_arb_tree.v                                                )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/fifo_v3.v                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_xbar.v                                                   )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_mux.v                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_err_slv.v                                                )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_multicut.v                                               )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_id_prepend.v                                             )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_to_mem.v                                                 )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_demux.v                                                  )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/core2axi.v                                                   )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/axi_bus.v                                                    )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi/core2axi_wrap.v                                              )
$(eval $(LIST_NAME) += $(VERILOG_ROOT)/rtl/axi_ram/axi_ram_1kB.sv                                           )

##########################################################################
