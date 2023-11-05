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

CUR_MK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

##########################################################################
# Arguments
##########################################################################

ifeq ($(MCW_ROOT),)
  $(error Error : MCW_ROOT is not defined !)
endif
ifeq ($(CARAVEL_ROOT),)
  $(error Error : CARAVEL_ROOT is not defined !)
endif
ifeq ($(VERILOG_ROOT),)
  $(error Error : VERILOG_ROOT is not defined !)
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

# Nom du top module
TOPLEVEL         := caravel_th
TOPLEVEL_LANG    := verilog
TOPLEVEL_LIBRARY := work
RTL_LIBRARY      := work

# Nom du fichier de test Python
MODULE := caravel_tests

# Simulateur
#SIM := questa
SIM := questa
GUI := 1

# Arguments de compilation pour définir les macros
ifeq ($(SIM),questa)
	COMPILE_ARGS :=
	COMPILE_ARGS += +define+FUNCTIONAL
	COMPILE_ARGS += +define+SIM=\\\"RTL\\\"
	COMPILE_ARGS += +define+USE_POWER_PINS
	COMPILE_ARGS += +define+UNIT_DELAY=#1
	COMPILE_ARGS += +define+TESTNAME=\\\"nec_ir_receiver\\\"
	COMPILE_ARGS += +define+MAIN_PATH=$(VERILOG_ROOT)/dv/cocotb/
	COMPILE_ARGS += +define+IVERILOG
	COMPILE_ARGS += +define+TAG=\\\"DUMMY_TAG\\\"
	COMPILE_ARGS += +define+RVFI
	VLOG_ARGS    := -mfcu -suppress 2892,2388
	#EXTRA_ARGS   :=
	SIM_ARGS     := -suppress 3009
	#SCRIPT_FILE  := $(CUR_MK_DIR)/../wave.do
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


##########################################################################
# Add sources
##########################################################################

# Initialisation of source list
LIST_NAME       := VERILOG_SOURCES
VERILOG_SOURCES :=

# Include caravel RTL sources
include $(CUR_MK_DIR)/rtl_caravel.inc


# Include user RTL sources
#include $(CUR_MK_DIR)/rtl_v_user.inc
include $(CUR_MK_DIR)/rtl_sv_user.inc

VERILOG_SOURCES += $(VERILOG_ROOT)/cocotb/caravel/caravel_th.sv

VHDL_SOURCES :=


##########################################################################
# Simulation
##########################################################################

include $(shell cocotb-config --makefiles)/Makefile.sim


##########################################################################
