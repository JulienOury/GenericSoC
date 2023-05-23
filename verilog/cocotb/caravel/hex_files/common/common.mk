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

COMMON_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

##########################################################################
# Arguments
##########################################################################

ifeq ($(PATH),)
  $(error Error : PATH is not defined !)
endif
ifeq ($(MCW_ROOT),)
  $(error Error : MCW_ROOT is not defined !)
endif
ifeq ($(PROGRAM),)
  $(error Error : PROGRAM is not defined !)
endif

#######################################################################
## Compiler Information 
#######################################################################

export VERILOG_PATH   = $(MCW_ROOT)/verilog
export FIRMWARE_PATH  = $(MCW_ROOT)/verilog/dv/firmware
export GCC_PREFIX    ?= riscv64-unknown-elf

CPUFLAGS       = -march=rv32i -mabi=ilp32 -D__vexriscv__
LINKER_SCRIPT  = $(FIRMWARE_PATH)/sections.lds
SOURCE_FILES   = $(FIRMWARE_PATH)/crt0_vex.S $(FIRMWARE_PATH)/isr.c


.SUFFIXES:


all:  ${PROGRAM:=.hex}


##############################################################################
# Compile firmware
##############################################################################
%.elf: %.c $(LINKER_SCRIPT) $(SOURCE_FILES)
	${GCC_PREFIX}-gcc -g \
	-I$(FIRMWARE_PATH) \
	-I$(VERILOG_PATH)/dv/generated \
	-I$(VERILOG_PATH)/dv/ \
	-I$(VERILOG_PATH)/common \
	  $(CPUFLAGS) \
	-Wl,-Bstatic,-T,$(LINKER_SCRIPT),--strip-debug \
	-ffreestanding -nostdlib -o $@ $(SOURCE_FILES) $<

%.hex: %.elf
	${GCC_PREFIX}-objcopy -O verilog $< $@ 
	# to fix flash base address
	sed -ie 's/@10/@00/g' $@

# ---- Clean ----

clean:
	\rm  -f *.elf *.hex *.bin *.vvp *.log *.vcd *.lst *.hexe

.PHONY: clean hex all
