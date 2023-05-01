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

ifndef TIMING_MK
TIMING_MK := 1

##########################################################################
# Includes
##########################################################################

include $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/configuration.mk


##########################################################################
# PATHs
##########################################################################

export PROJECT_ROOT ?=$(shell pwd)
export CUP_ROOT     ?=$(PROJECT_ROOT)
export PDK_ROOT     ?=$(CUP_ROOT)
export CARAVEL_ROOT ?=$(CUP_ROOT)
export MCW_ROOT     ?=$(CUP_ROOT)
export TIMING_ROOT  ?=$(CUP_ROOT)
export PDK          ?=""


##########################################################################
# caravel-sta
##########################################################################

./verilog/gl/user_project_wrapper.v:
	$(error you don't have $@)

./env/spef-mapping.tcl: 
	@echo "run the following:"
	@echo "make extract-parasitics"
	@echo "make create-spef-mapping"
	exit 1

.PHONY: create-spef-mapping
create-spef-mapping: ./verilog/gl/user_project_wrapper.v
	docker run \
		--rm \
		-u $$(id -u $$USER):$$(id -g $$USER) \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-v $(CUP_ROOT):$(CUP_ROOT) \
		-v $(CARAVEL_ROOT):$(CARAVEL_ROOT) \
		-v $(MCW_ROOT):$(MCW_ROOT) \
		-v $(TIMING_ROOT):$(TIMING_ROOT) \
		-w $(shell pwd) \
		efabless/timing-scripts:latest \
		python3 $(TIMING_ROOT)/scripts/generate_spef_mapping.py \
			-i ./verilog/gl/user_project_wrapper.v \
			-o ./env/spef-mapping.tcl \
			--pdk-path $(PDK_ROOT)/$(PDK) \
			--macro-parent mprj \
			--project-root "$(CUP_ROOT)"

.PHONY: extract-parasitics
extract-parasitics: ./verilog/gl/user_project_wrapper.v
	docker run \
		--rm \
		-u $$(id -u $$USER):$$(id -g $$USER) \
		-v $(PDK_ROOT):$(PDK_ROOT) \
		-v $(CUP_ROOT):$(CUP_ROOT) \
		-v $(CARAVEL_ROOT):$(CARAVEL_ROOT) \
		-v $(MCW_ROOT):$(MCW_ROOT) \
		-v $(TIMING_ROOT):$(TIMING_ROOT) \
		-w $(shell pwd) \
		efabless/timing-scripts:latest \
		python3 $(TIMING_ROOT)/scripts/get_macros.py \
			-i ./verilog/gl/user_project_wrapper.v \
			-o ./tmp-macros-list \
			--project-root "$(CUP_ROOT)" \
			--pdk-path $(PDK_ROOT)/$(PDK)
	@cat ./tmp-macros-list | cut -d " " -f2 \
		| xargs -I % bash -c "$(MAKE) -C $(TIMING_ROOT) \
			-f $(TIMING_ROOT)/timing.mk rcx-% || echo 'Cannot extract %. Probably no def for this macro'"
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk rcx-user_project_wrapper
	@cat ./tmp-macros-list
	@rm ./tmp-macros-list
	
.PHONY: caravel-sta
caravel-sta: ./env/spef-mapping.tcl
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk caravel-timing-typ
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk caravel-timing-fast
	@$(MAKE) -C $(TIMING_ROOT) -f $(TIMING_ROOT)/timing.mk caravel-timing-slow
	@echo =================================================Summary=================================================
	@find $(PROJECT_ROOT)/signoff/caravel/openlane-signoff -name "*-summary.rpt" | head -n1 \
		| xargs tail -n2 | head -n1
	@find $(PROJECT_ROOT)/signoff/caravel/openlane-signoff -name "*-summary.rpt" \
		| xargs -I {} tail -n1 "{}"
	@echo =========================================================================================================
	@echo "You can find results for all corners in $(CUP_ROOT)/signoff/caravel/openlane-signoff/timing/"


##########################################################################
endif
