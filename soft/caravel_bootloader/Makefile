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
#
# Generate a baremetal application

# Name of the program $(PROGRAM).c will be added as a source file
PWDD        := $(shell pwd)
PROGRAM     := $(shell basename $(PWDD))
PROGRAM_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

include ${PROGRAM_DIR}/../common/caravel_riscv/common.mk
