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

ifeq ($(LIST_NAME),)
  $(error Error : LIST_NAME is not defined !)
endif
ifeq ($(MCW_ROOT),)
  $(error Error : MCW_ROOT is not defined !)
endif
ifeq ($(CARAVEL_ROOT),)
  $(error Error : CARAVEL_ROOT is not defined !)
endif
ifeq ($(PDK_ROOT),)
  $(error Error : PDK_ROOT is not defined !)
endif
ifeq ($(PDK),)
  $(error Error : PDK is not defined !)
endif


##########################################################################
# Default configuration
##########################################################################

## VIP
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/dv/vip/tbuart.v     )
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/dv/vip/spiflash.v   )
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/dv/vip/wb_rw_test.v )

## DFFRAM Behavioral Model
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/dv/vip/RAM256.v )
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/dv/vip/RAM128.v )

## DFFRAM Full RTL
#$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/rtl/DFFRAM.v   )
#$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/rtl/DFFRAMBB.v )

# Mgmt Core Wrapper
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/rtl/defines.v                )
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/rtl/mgmt_core.v              )
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/rtl/mgmt_core_wrapper.v      )
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/rtl/VexRiscv_MinDebugCache.v )

# Caravel

## These blocks need to stay in RTL
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/pads.v         )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/defines.v      )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/user_defines.v )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/mprj_io.v      )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/simple_por.v   )

## These blocks only needed for RTL sims                                    )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/digital_pll_controller.v )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/ring_osc2x13.v           )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/clock_div.v              )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/housekeeping_spi.v       )

$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/chip_io_alt.v              )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/chip_io.v                  )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/mprj_logic_high.v          )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/mprj2_logic_high.v         )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/mgmt_protect.v             )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/mgmt_protect_hv.v          )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/gpio_control_block.v       )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/gpio_defaults_block.v      )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/gpio_logic_high.v          )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/constant_block.v           )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/xres_buf.v                 )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/spare_logic_block.v        )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/housekeeping.v             )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/caravel_clocking.v         )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/digital_pll.v              )
#$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/__user_project_wrapper.v   )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/debug_regs.v               )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/user_id_programming.v      )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/buff_flash_clkrst.v        )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/gpio_signal_buffering.v    )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/caravel.v                  )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/gpio_signal_buffering_alt.v)
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/rtl/caravan.v                  )

## These blocks are manually designed
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_0403.v )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_1803.v )
$(eval $(LIST_NAME) += $(CARAVEL_ROOT)/verilog/gl/gpio_defaults_block_0801.v )

# STD CELLS - they need to be below the defines.v files
$(eval $(LIST_NAME) += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_io/verilog/sky130_fd_io.v                            )
$(eval $(LIST_NAME) += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_io/verilog/sky130_ef_io.v                            )
$(eval $(LIST_NAME) += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/primitives.v                           )
$(eval $(LIST_NAME) += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v                      )
$(eval $(LIST_NAME) += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hvl/verilog/primitives.v                          )
$(eval $(LIST_NAME) += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_fd_sc_hvl/verilog/sky130_fd_sc_hvl.v                    )
#$(eval $(LIST_NAME) += $(PDK_ROOT)/$(PDK)/libs.ref/sky130_sram_macros/verilog/sky130_sram_2kbyte_1rw1r_32x512_8.v )


## STD CELLS - they need to be below the defines.v files                                )
#$(eval $(LIST_NAME) += $(MCW_ROOT)/cvc-pdk/sky130_ef_io.v                              )
#$(eval $(LIST_NAME) += $(MCW_ROOT)/cvc-pdk/sky130_fd_io.v                              )
#$(eval $(LIST_NAME) += $(MCW_ROOT)/cvc-pdk/primitives_hd.v                             )
#$(eval $(LIST_NAME) += $(MCW_ROOT)/cvc-pdk/sky130_fd_sc_hd.v                           )
#$(eval $(LIST_NAME) += $(MCW_ROOT)/cvc-pdk/primitives_hvl.v                            )
#$(eval $(LIST_NAME) += $(MCW_ROOT)/cvc-pdk/sky130_fd_sc_hvl.v                          )
$(eval $(LIST_NAME) += $(MCW_ROOT)/verilog/cvc-pdk/sky130_sram_2kbyte_1rw1r_32x512_8.v )


##########################################################################
