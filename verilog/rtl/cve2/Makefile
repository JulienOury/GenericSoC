# Makefile to compile and simulate sv designs


#set paths to modelsim
VLOG ?= vlog
VSIM ?= vsim
VOPT ?= vopt

#Directories
SRC_DIR         = ./cve2-core
PRIM_ASSERT_DIR = ./cve2-core/vendor/lowrisc_ip/ip/prim/rtl
DV_FCOV_DIR     = ./cve2-core/vendor/lowrisc_ip/dv/sv/dv_utils
PRIM_RAM_DIR    = ./cve2-core/vendor/lowrisc_ip/ip/prim/rtl

SRC_DIR_LOCAL   = ./cve2-core-local

#top
TOP = cve2_simple_system

#design files
DESIGN_FILES ?= \
  $(SRC_DIR)/syn/rtl/prim_clock_gating.v \
  $(SRC_DIR)/rtl/cve2_alu.sv \
  $(SRC_DIR)/rtl/cve2_compressed_decoder.sv \
  $(SRC_DIR)/rtl/cve2_controller.sv \
  $(SRC_DIR)/rtl/cve2_counter.sv \
  $(SRC_DIR)/rtl/cve2_csr.sv \
  $(SRC_DIR)/rtl/cve2_cs_registers.sv \
  $(SRC_DIR)/rtl/cve2_decoder.sv \
  $(SRC_DIR)/rtl/cve2_ex_block.sv \
  $(SRC_DIR)/rtl/cve2_fetch_fifo.sv \
  $(SRC_DIR)/rtl/cve2_id_stage.sv \
  $(SRC_DIR)/rtl/cve2_if_stage.sv \
  $(SRC_DIR)/rtl/cve2_load_store_unit.sv \
  $(SRC_DIR)/rtl/cve2_multdiv_fast.sv \
  $(SRC_DIR)/rtl/cve2_multdiv_slow.sv \
  $(SRC_DIR)/rtl/cve2_prefetch_buffer.sv \
  $(SRC_DIR)/rtl/cve2_pmp.sv \
  $(SRC_DIR)/rtl/cve2_register_file_ff.sv \
  $(SRC_DIR)/rtl/cve2_wb_stage.sv \
  $(SRC_DIR)/rtl/cve2_core.sv \
  $(SRC_DIR)/rtl/cve2_tracer.sv \
  $(SRC_DIR)/rtl/cve2_top.sv \
  $(SRC_DIR)/rtl/cve2_top_tracing.sv \
  $(SRC_DIR)/shared/rtl/bus.sv \
  $(SRC_DIR)/shared/rtl/ram_1p.sv \
  $(SRC_DIR)/shared/rtl/ram_2p.sv \
  $(SRC_DIR)/shared/rtl/timer.sv \
  $(SRC_DIR)/shared/rtl/sim/simulator_ctrl.sv \
  $(SRC_DIR)/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_generic_ram_2p.sv \
  $(SRC_DIR)/examples/simple_system/rtl/cve2_simple_system.sv

DESIGN_FILES_LOCAL ?= \
  $(SRC_DIR_LOCAL)/syn/rtl/prim_clock_gating.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_alu.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_compressed_decoder.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_controller.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_counter.sv \
  $(SRC_DIR_LOCAL)/rtl/cve2_csr.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_cs_registers.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_decoder.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_ex_block.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_fetch_fifo.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_id_stage.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_if_stage.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_load_store_unit.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_multdiv_fast.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_multdiv_slow.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_prefetch_buffer.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_pmp.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_register_file_ff.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_wb_stage.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_core.v \
  $(SRC_DIR_LOCAL)/rtl/cve2_top.v \
  $(SRC_DIR)/rtl/cve2_tracer.sv \
  $(SRC_DIR)/rtl/cve2_top_tracing.sv \
  $(SRC_DIR)/shared/rtl/bus.sv \
  $(SRC_DIR)/shared/rtl/ram_1p.sv \
  $(SRC_DIR)/shared/rtl/ram_2p.sv \
  $(SRC_DIR)/shared/rtl/timer.sv \
  $(SRC_DIR)/shared/rtl/sim/simulator_ctrl.sv \
  $(SRC_DIR)/vendor/lowrisc_ip/ip/prim_generic/rtl/prim_generic_ram_2p.sv \
  $(SRC_DIR)/examples/simple_system/rtl/cve2_simple_system.sv
	
#  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.v \
#  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.v \
#  $::env(DESIGN_DIR)/../../verilog/rtl/cve2/cve2-core-local/rtl/cve2_pkg.v \
	
PACKAGE_FILES ?= \
  $(SRC_DIR)/rtl/cve2_pkg.sv \
  $(SRC_DIR)/rtl/cve2_tracer_pkg.sv \
  $(PRIM_RAM_DIR)/prim_secded_pkg.sv \
  $(PRIM_RAM_DIR)/prim_ram_1p_pkg.sv \
  $(PRIM_RAM_DIR)/prim_ram_2p_pkg.sv
  
DEFINES = \
  +define+RV32E=0 \
  +define+RV32M=cve2_pkg::RV32MFast \
  +define+RVFI
  
all: compile simulate

#compile
compile:
	vlib work
	$(VLOG) +incdir+$(PRIM_ASSERT_DIR) +incdir+$(DV_FCOV_DIR) +incdir+$(PRIM_RAM_DIR) +incdir+$(SRC_DIR)/rtl $(PACKAGE_FILES) $(DESIGN_FILES_LOCAL) $(DEFINES) +define+TOP=$(TOP)
  
# -suppress 2720
	
optimize:
	$(VOPT) +cover -incr -nologo -quiet -permissive -suppress 3013,2732 $(TOP) -o optimized_top +acc
  
simulate:
	$(VSIM) +permissive -suppress 3013,2732 -voptargs=+acc -t 1ns -coverage -classdebug -GSRAMInitFile="../../../soft/simple_system/hello_test/hello_test.vmem" -do "log -r /*;" cve2_simple_system

#-suppress 3013,2732

clean:
	rm -f transcript *.wlf work/*.*
  
.PHONY: clean compile optimize simulate
