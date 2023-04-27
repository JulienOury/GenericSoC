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
# INSTALL / UNINSTALL all
##########################################################################

.PHONY: install
install: install_cmds           \
         install_sv2v           \
				 install_magic          \
				 install_yosys          \
				 install_riscv_gcc      \
				 install_caravel        \
				 install_precheck       \
				 install_openlane       \
				 install_timing_scripts \
				 simenv

.PHONY: uninstall
uninstall:
	sudo rm -rf $(DEPENDENCIES_ROOT)
	

##########################################################################
# INSTALL commands
##########################################################################

.PHONY: install_cmds
install_cmds:
	sudo apt-get update                          --assume-yes || true
	sudo apt-get install m4                      --assume-yes
	sudo apt-get install tcsh                    --assume-yes
	sudo apt-get install csh                     --assume-yes
	sudo apt-get install libx11-dev              --assume-yes
	sudo apt-get install tcl-dev tk-dev          --assume-yes
	sudo apt-get install libcairo2-dev           --assume-yes
	sudo apt-get install mesa-common-dev         --assume-yes
	sudo apt-get install libglu1-mesa-dev        --assume-yes
	sudo apt-get install libncurses-dev          --assume-yes
	sudo apt-get install git                     --assume-yes
	sudo apt-get install build-essential         --assume-yes
	sudo apt-get install clang                   --assume-yes
	sudo apt-get install bison                   --assume-yes
	sudo apt-get install flex                    --assume-yes
	sudo apt-get install libreadline-dev         --assume-yes
	sudo apt-get install gawk                    --assume-yes
	sudo apt-get install libffi-dev              --assume-yes
	sudo apt-get install graphviz                --assume-yes
	sudo apt-get install xdot                    --assume-yes
	sudo apt-get install pkg-config              --assume-yes
	sudo apt-get install python3                 --assume-yes
	sudo apt-get install python3-pip             --assume-yes
	sudo apt-get install python3.8-venv          --assume-yes
	sudo apt-get install libboost-system-dev     --assume-yes
	sudo apt-get install libboost-python-dev     --assume-yes
	sudo apt-get install libboost-filesystem-dev --assume-yes
	sudo apt-get install zlib1g-dev              --assume-yes
	sudo apt-get install srecord                 --assume-yes
	sudo apt-get install apt-transport-https     --assume-yes
	sudo apt-get install ca-certificates         --assume-yes
	sudo apt-get install curl                    --assume-yes
	sudo apt-get install gnupg                   --assume-yes
	sudo apt-get install lsb-release             --assume-yes

	# install DOCKER
	sudo apt-get remove docker                   --assume-yes
	sudo apt-get remove docker-engine            --assume-yes
	sudo apt-get remove docker.io                --assume-yes
	sudo apt-get remove containerd               --assume-yes
	sudo apt-get remove runc                     --assume-yes
	
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg --yes
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	
	sudo apt-get install docker-ce               --assume-yes
	sudo apt-get install docker-ce-cli           --assume-yes
	sudo apt-get install containerd.io           --assume-yes

	sudo groupadd docker || true
	sudo usermod -aG docker $(USER)
	#sudo newgrp docker


##########################################################################
# INSTALL magic
##########################################################################

.PHONY: install_magic
install_magic: dependency_folder_check
	
	# Delete target folder (if needed)
	$(eval MAGIC_FOLDER=$(DEPENDENCIES_ROOT)/magic)
	if [ -d "$(MAGIC_FOLDER)" ]; then \
		echo "Deleting exisiting $(MAGIC_FOLDER)" && \
		sudo rm -rf $(MAGIC_FOLDER) && sleep 2;\
	fi
	
	echo "Installing magic.."
	
	# Clone and install
	{ \
	cd $(DEPENDENCIES_ROOT) ;\
	git clone https://github.com/RTimothyEdwards/magic.git ;\
	cd magic ;\
	./configure ;\
	sudo make ;\
	sudo make install ;\
	}


##########################################################################
# INSTALL yosys
##########################################################################

.PHONY: install_yosys
install_yosys: dependency_folder_check
	
	# Delete target folder (if needed)
	$(eval YOSYS_FOLDER=$(DEPENDENCIES_ROOT)/yosys)
	if [ -d "$(YOSYS_FOLDER)" ]; then\
		echo "Deleting exisiting $(YOSYS_FOLDER)" && \
		sudo rm -rf $(YOSYS_FOLDER) && sleep 2;\
	fi
	
	echo "Installing yosys.."
	
	# Clone and install
	{ \
	cd $(DEPENDENCIES_ROOT) ;\
	git clone https://github.com/YosysHQ/yosys.git ;\
	cd yosys ;\
	sudo make ;\
	sudo make install ;\
	}


##########################################################################
# INSTALL SV2V
##########################################################################

.PHONY: install_sv2v
install_sv2v: dependency_folder_check
	
	# Delete target folder (if needed)
	$(eval SV2V_FOLDER=$(DEPENDENCIES_ROOT)/sv2v)
	if [ -d "$(SV2V_FOLDER)" ]; then\
		echo "Deleting exisiting $(SV2V_FOLDER)" && \
		rm -rf $(SV2V_FOLDER) && sleep 2;\
	fi
	
	echo "Installing sv2v.."
	
	# Clone and install
	{ \
	cd $(DEPENDENCIES_ROOT) ;\
	curl -sSL https://get.haskellstack.org/ | sh ;\
	git clone https://github.com/zachjs/sv2v.git ;\
	cd sv2v ;\
	make ;\
	}


##########################################################################
# INSTALL GCC for RISCV
##########################################################################

.PHONY: install_riscv_gcc
install_riscv_gcc: dependency_folder_check
	
	# Delete target folder (if needed)
	if [ -d "$(RISCV)" ]; then\
		echo "Deleting exisiting $(RISCV)" && \
		rm -rf $(RISCV) && sleep 2;\
	fi
	
	echo "Installing GCC for RISCV.."
	
	# Create target folder
	mkdir -p $(RISCV)
	
	# Name of archive
	$(eval RISCV64_UNKNOWN_ELF_GCC=riscv64-unknown-elf-gcc-8.3.0-2020.04.0-x86_64-linux-ubuntu14.tar.gz)
	
	# Download archive if not exist
	if [ ! -f "$(DEPENDENCIES_ROOT)/$(RISCV64_UNKNOWN_ELF_GCC)" ]; then \
		wget -P $(DEPENDENCIES_ROOT) https://static.dev.sifive.com/dev-tools/$(RISCV64_UNKNOWN_ELF_GCC) ;\
	fi
	
	# UnTAR archive in target folder
	tar -x -f $(DEPENDENCIES_ROOT)/$(RISCV64_UNKNOWN_ELF_GCC) --strip-components=1 -C $(RISCV)
	
	# Delete archive
	rm -f $(DEPENDENCIES_ROOT)/$(RISCV64_UNKNOWN_ELF_GCC)


##########################################################################
# INSTALL GCC for RISCV
##########################################################################

.PHONY: install_precheck
install_precheck: dependency_folder_check
	
	# Delete target folder (if needed)
	if [ -d "$(PRECHECK_ROOT)" ]; then\
		echo "Deleting exisiting $(PRECHECK_ROOT)" && \
		rm -rf $(PRECHECK_ROOT) && sleep 2;\
	fi

	@git clone --depth=1 --branch $(MPW_TAG) https://github.com/efabless/mpw_precheck.git $(PRECHECK_ROOT)
	@docker pull efabless/mpw_precheck:latest


##########################################################################
# INSTALL caravel
##########################################################################

.PHONY: install_caravel
install_caravel:

ifndef CARAVEL_ROOT
	$(error CARAVEL_ROOT is undefined, please export it before running make)
endif
ifndef CARAVEL_NAME
	$(error CARAVEL_NAME is undefined, please export it before running make)
endif
ifndef CARAVEL_REPO
	$(error CARAVEL_REPO is undefined, please export it before running make)
endif
ifndef CARAVEL_TAG
	$(error CARAVEL_TAG is undefined, please export it before running make)
endif

	if [ -d "$(CARAVEL_ROOT)" ]; then\
		echo "Deleting exisiting $(CARAVEL_ROOT)" && \
		rm -rf $(CARAVEL_ROOT) && sleep 2;\
	fi
	echo "Installing $(CARAVEL_NAME).."
	git clone -b $(CARAVEL_TAG) $(CARAVEL_REPO) $(CARAVEL_ROOT) --depth=1


##########################################################################
# INSTALL Openlane
##########################################################################

.PHONY: install_openlane
install_openlane:

ifndef OPENLANE_ROOT
	$(error OPENLANE_ROOT is undefined, please export it before running make)
endif

	@if [ "$$(realpath $${OPENLANE_ROOT})" = "$$(realpath $$(pwd)/openlane)" ]; then\
		echo "OPENLANE_ROOT is set to '$$(pwd)/openlane' which contains openlane config files"; \
		echo "Please set it to a different directory"; \
		exit 1; \
	fi
	cd openlane && $(MAKE) openlane


##########################################################################
# INSTALL Timing scripts
##########################################################################

.PHONY: install_timing_scripts
install_timing_scripts:
	
ifndef TIMING_ROOT
	$(error TIMING_ROOT is undefined, please export it before running make)
endif
	
	if [ -d "$(TIMING_ROOT)" ]; then\
		echo "Deleting exisiting $(TIMING_ROOT)" && \
		rm -rf $(TIMING_ROOT) && sleep 2;\
	fi
	echo "Installing $(CARAVEL_NAME).."
	git clone $(TIMING_SCRIPTS_REPO) $(TIMING_ROOT)
	
	@( cd $(TIMING_ROOT) && git pull )
	@#( cd $(TIMING_ROOT) && git fetch && git checkout $(MPW_TAG); )


##########################################################################
# INSTALL DV setup
##########################################################################

.PHONY: simenv
simenv:
	docker pull efabless/dv:latest


##########################################################################
# Check if dependency folder path ise declared and folder exist
##########################################################################
.PHONY: dependency_folder_check
dependency_folder_check:
	
	# Check if dependencies folder path exist
ifndef DEPENDENCIES_ROOT
	$(error DEPENDENCIES_ROOT is undefined, please export it before running make)
endif
	
  # Create folder (if not already exist)
	mkdir -p $(DEPENDENCIES_ROOT)