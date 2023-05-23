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
# Parameters
##########################################################################

MAKEFLAGS+=--warn-undefined-variables


##########################################################################
# Includes
##########################################################################

include make/configuration.mk
include make/install.mk
include make/verify.mk
include make/misc.mk
include make/timing.mk
include make/precheck.mk
include make/sv2v_conversion.mk


##########################################################################
# Include Caravel Makefile Targets
##########################################################################
check-caravel:
	@if [ ! -d "$(CARAVEL_ROOT)" ]; then \
		echo "Caravel Root: "$(CARAVEL_ROOT)" doesn't exists, please export the correct path before running make. "; \
		exit 1; \
	fi

.PHONY: % : check-caravel
%:
	export CARAVEL_ROOT=$(CARAVEL_ROOT) && $(MAKE) -f $(CARAVEL_ROOT)/Makefile $@


##########################################################################
# SETUP / REMOVE
##########################################################################

.PHONY: setup
setup: install install_mcw pdk-with-volare

.PHONY: remove
remove: clean uninstall
	rm -rf caravel
	rm -rf mgmt_core_wrapper


##########################################################################
# Software gen
##########################################################################
soft_names = $(shell cd $(SOFT_ROOT) && find * -maxdepth 0 -type d)
soft_names := $(filter-out common,$(soft_names))

.PHONY: soft_all_%
soft_all_%:
	for i in $(soft_names); do \
		(export PATH=${PATH} && export PROGRAM_CFLAGS="" && cd $(SOFT_ROOT)/$$i && $(MAKE) $*) ; \
	done

soft_blocks := $(foreach name, $(soft_names), soft_$(name)_%)
.PHONY: $(soft_blocks)
$(soft_blocks):
	export PATH=${PATH} && export PROGRAM_CFLAGS="" && cd $(SOFT_ROOT)/$(subst soft_,,$(subst _$*,,$@)) && $(MAKE) $*


##########################################################################
# Hardware gen
##########################################################################

.PHONY: docker_start
docker_start:
	#Start docker if not already started
	@if ! service docker status > /dev/null 2>&1; then \
		sudo service docker start; \
	fi

# Openlane
blocks=$(shell cd openlane && find * -maxdepth 0 -type d)
.PHONY: $(blocks)
$(blocks): % : docker_start
	$(MAKE) -C openlane $*

.PHONY: harden
harden: $(blocks)


##########################################################################
# COCOTB verify
##########################################################################
cocotb_blocks := $(shell cd $(COCOTB_ROOT) && find * -maxdepth 0 -type d)
cocotb_blocks := $(addprefix cocotb_, $(cocotb_blocks))
cocotb_blocks := $(addsuffix _%, $(cocotb_blocks))
.PHONY: $(cocotb_blocks)
$(cocotb_blocks):
	@{ \
	export PATH=$(PATH);\
	export MCW_ROOT=$(MCW_ROOT);\
	export CARAVEL_ROOT=$(CARAVEL_ROOT);\
	export VERILOG_ROOT=$(VERILOG_ROOT);\
	export PDK_ROOT=$(PDK_ROOT);\
	export PDK=$(PDK);\
	cd $(COCOTB_ROOT)/$(subst cocotb_,,$(subst _$*,,$@));\
	$(MAKE) $*;\
	}


##########################################################################
#### Others

# Create symbolic links to caravel's main files
.PHONY: simlink
simlink: check-caravel
### Symbolic links relative path to $CARAVEL_ROOT
	$(eval MAKEFILE_PATH := $(shell realpath --relative-to=openlane $(CARAVEL_ROOT)/openlane/Makefile))
	$(eval PIN_CFG_PATH  := $(shell realpath --relative-to=openlane/user_project_wrapper $(CARAVEL_ROOT)/openlane/user_project_wrapper_empty/pin_order.cfg))
	mkdir -p openlane
	mkdir -p openlane/user_project_wrapper
#	cd openlane &&\
#	ln -sf $(MAKEFILE_PATH) Makefile
#	cd openlane/user_project_wrapper &&\
#	ln -sf $(PIN_CFG_PATH) pin_order.cfg

