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
# CONFIGURATION
##########################################################################

# Install lite version of caravel, (1): caravel-lite, (0): caravel
CARAVEL_LITE?=1

# PDK switch varient
export PDK?=sky130A
#export PDK?=gf180mcuC

##########################################################################
# PATHs
##########################################################################

export PROJECT_ROOT      := $(PWD)
export DEPENDENCIES_ROOT := $(PROJECT_ROOT)/dependencies

export OPENLANE_ROOT     := $(DEPENDENCIES_ROOT)/openlane_src
export PDK_ROOT          := $(DEPENDENCIES_ROOT)/pdks
export RISCV             := $(DEPENDENCIES_ROOT)/riscv
export PRECHECK_ROOT     := $(DEPENDENCIES_ROOT)/precheck
export TIMING_ROOT       := $(DEPENDENCIES_ROOT)/timing-scripts

export CARAVEL_ROOT      := $(PROJECT_ROOT)/caravel
export MCW_ROOT          := $(PROJECT_ROOT)/mgmt_core_wrapper
export PDKPATH           := $(PDK_ROOT)/$(PDK)

export PATH              := "/home/joy/.local/bin:$(PATH)"
export PATH              := "$(DEPENDENCIES_ROOT)/sv2v/bin:$(PATH)"
export PATH              := "$(RISCV)/bin:/bin:$(PATH)"

##########################################################################
# PDK & OPENLANE CONFIGURATION
##########################################################################

ifeq ($(PDK),sky130A)
	SKYWATER_COMMIT=f70d8ca46961ff92719d8870a18a076370b85f6c
	export OPEN_PDKS_COMMIT?=0059588eebfc704681dc2368bd1d33d96281d10f
	export OPENLANE_TAG?=2022.11.19
	#export OPENLANE_TAG?=2023.03.30
	MPW_TAG ?= mpw-8c
endif

ifeq ($(PDK),sky130B)
	SKYWATER_COMMIT=f70d8ca46961ff92719d8870a18a076370b85f6c
	export OPEN_PDKS_COMMIT?=0059588eebfc704681dc2368bd1d33d96281d10f
	export OPENLANE_TAG?=2022.11.19
	MPW_TAG ?= mpw-8c
endif

ifeq ($(PDK),gf180mcuC)
	export OPEN_PDKS_COMMIT?=141eea4d1bb8c6d4dd85fcbf2c0bdface7df9cfc
	export OPENLANE_TAG?=2022.12.02
	MPW_TAG ?= gfmpw-0d
endif

##########################################################################
# CARAVEL CONFIGURATION
##########################################################################

# Force caravel (not lite) for gf180mcuC PDK
ifeq ($(PDK),gf180mcuC)
  CARAVEL_LITE?=0
endif

ifeq ($(CARAVEL_LITE),1)
	CARAVEL_NAME := caravel-lite
	CARAVEL_REPO := https://github.com/efabless/caravel-lite
	CARAVEL_TAG := $(MPW_TAG)
else
	CARAVEL_NAME := caravel
	CARAVEL_REPO := https://github.com/efabless/caravel
	CARAVEL_TAG := $(MPW_TAG)
endif

##########################################################################
# TIMING SCRIPTS CONFIGURATION
##########################################################################

TIMING_SCRIPTS_REPO=https://github.com/efabless/timing-scripts.git


##########################################################################
