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

ifndef MISC_MK
MISC_MK := 1

##########################################################################
# Includes
##########################################################################

include $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))/configuration.mk


##########################################################################
# Find targets
##########################################################################

blocks=$(shell cd openlane && find * -maxdepth 0 -type d)
clean-targets=$(blocks:%=clean-%)


##########################################################################
# Clean
##########################################################################

.PHONY: clean
clean: $(clean-targets) clean-dv soft_all_clean cocotb_all_clean

.PHONY: $(clean-targets)
$(clean-targets): clean-% :
	rm -rf openlane/$*/runs
	rm -f ./verilog/gl/$*.v
	rm -f ./spef/$*.spef
	rm -f ./spef/multicorner/$*.min.spef
	rm -f ./spef/multicorner/$*.nom.spef
	rm -f ./spef/multicorner/$*.max.spef
	rm -f ./sdc/$*.sdc
	rm -f ./sdf/$*.sdf
	rm -f ./sdf/multicorner/$*.sdf
	rm -f ./sdf/multicorner/min/$*.ff.sdf
	rm -f ./sdf/multicorner/min/$*.ss.sdf
	rm -f ./sdf/multicorner/min/$*.tt.sdf
	rm -f ./sdf/multicorner/nom/$*.ff.sdf
	rm -f ./sdf/multicorner/nom/$*.ss.sdf
	rm -f ./sdf/multicorner/nom/$*.tt.sdf
	rm -f ./sdf/multicorner/max/$*.ff.sdf
	rm -f ./sdf/multicorner/max/$*.ss.sdf
	rm -f ./sdf/multicorner/max/$*.tt.sdf
	rm -f ./gds/$*.gds
	rm -f ./mag/$*.mag
	rm -f ./lef/$*.lef
	rm -f ./maglef/$*.mag
	rm -f ./def/$*.def
	rm -f ./spi/$*.spice
	rm -f ./spi/lvs/$*.spice
	rm -f ./lib/$*.lib

.PHONY: clean-dv
clean-dv:
	cd ./verilog/dv/ && \
		$(MAKE) clean


##########################################################################
# ZIP / UNZIP
##########################################################################

.PHONY: zip
zip:
	gzip -f def/*.def
	gzip -f lef/*.lef
	gzip -f gds/*.gds
	gzip -f mag/*.mag
	gzip -f maglef/*.mag
	gzip -f spef/*.spef
	gzip -f spef/multicorner/*.min.spef
	gzip -f spef/multicorner/*.nom.spef
	gzip -f spef/multicorner/*.max.spef
	gzip -f spi/*.spice
	gzip -f spi/lvs/*.spice
	gzip -f sdf/*.sdf
	gzip -f sdf/multicorner/*.sdf
	gzip -f sdf/multicorner/min/*.ff.sdf
	gzip -f sdf/multicorner/min/*.ss.sdf
	gzip -f sdf/multicorner/min/*.tt.sdf
	gzip -f sdf/multicorner/nom/*.ff.sdf
	gzip -f sdf/multicorner/nom/*.ss.sdf
	gzip -f sdf/multicorner/nom/*.tt.sdf
	gzip -f sdf/multicorner/max/*.ff.sdf
	gzip -f sdf/multicorner/max/*.ss.sdf
	gzip -f sdf/multicorner/max/*.tt.sdf

.PHONY: unzip
unzip:
	gzip -d def/*.gz
	gzip -d lef/*.gz
	gzip -d gds/*.gz
	gzip -d mag/*.gz
	gzip -d maglef/*.gz
	gzip -d spef/*.gz
	gzip -d spef/multicorner/*.min.gz
	gzip -d spef/multicorner/*.nom.gz
	gzip -d spef/multicorner/*.max.gz
	gzip -d spi/*.gz
	gzip -d spi/lvs/*.gz
	gzip -d sdf/*.gz
	gzip -d sdf/multicorner/*.gz
	gzip -d sdf/multicorner/min/*.ff.gz
	gzip -d sdf/multicorner/min/*.ss.gz
	gzip -d sdf/multicorner/min/*.tt.gz
	gzip -d sdf/multicorner/nom/*.ff.gz
	gzip -d sdf/multicorner/nom/*.ss.gz
	gzip -d sdf/multicorner/nom/*.tt.gz
	gzip -d sdf/multicorner/max/*.ff.gz
	gzip -d sdf/multicorner/max/*.ss.gz
	gzip -d sdf/multicorner/max/*.tt.gz


##########################################################################
# HELP
##########################################################################

.PHONY: help
help:
	cd $(CARAVEL_ROOT) && $(MAKE) help
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


##########################################################################
endif
