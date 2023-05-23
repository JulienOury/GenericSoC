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

ifeq ($(PATH),)
  $(error Error : PATH is not defined !)
endif
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
# General targets
##########################################################################

.PHONY: all
all: clean build_soft simu

.PHONY: clean
clean: clean_soft clean_simu


##########################################################################
# Simulation
##########################################################################

.PHONY: simu
simu: clean_simu

	mkdir  $(CUR_MK_DIR)/sim
	
	# Start cocotb simulation
	@{ \
	export MCW_ROOT=$(MCW_ROOT);\
	export CARAVEL_ROOT=$(CARAVEL_ROOT);\
	export VERILOG_ROOT=$(VERILOG_ROOT);\
	export PDK_ROOT=$(PDK_ROOT);\
	export PDK=$(PDK);\
	cd $(CUR_MK_DIR);\
	$(MAKE) -f $(CUR_MK_DIR)/make/sim_rtl.mk;\
	}

.PHONY: clean_simu
clean_simu:

	rm -rf $(CUR_MK_DIR)/sim_build
	rm -rf $(CUR_MK_DIR)/__pycache__
	rm -f  $(CUR_MK_DIR)/*.log
	rm -f  $(CUR_MK_DIR)/*.ini
	rm -f  $(CUR_MK_DIR)/*.vcd
	rm -f  $(CUR_MK_DIR)/transcript
	rm -f  $(CUR_MK_DIR)/results.xml
	
	rm -rf $(CUR_MK_DIR)/sim


##########################################################################
# Software
##########################################################################

.PHONY: build_soft
build_soft: clean_soft
	@{ \
	export PATH=$(PATH);\
	export MCW_ROOT=$(MCW_ROOT);\
	cd $(CUR_MK_DIR)/hex_files/nec_ir_receiver;\
	$(MAKE);\
	}

.PHONY: clean_soft
clean_soft:
	@{ \
	export PATH=$(PATH);\
	export MCW_ROOT=$(MCW_ROOT);\
	cd $(CUR_MK_DIR)/hex_files/nec_ir_receiver;\
	$(MAKE) clean;\
	}


##########################################################################
