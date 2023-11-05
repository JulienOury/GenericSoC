transcript on

#-----------------------------------------------------------------------
# Call compile scripts from dependent libraries
#-----------------------------------------------------------------------

#quietly set root_path "../../UVVM-master"
#do $root_path/script/compile_src.do $root_path/uvvm_util $root_path/uvvm_util/sim
#do $root_path/script/compile_src.do $root_path/uvvm_vvc_framework $root_path/uvvm_vvc_framework/sim
#do $root_path/script/compile_src.do $root_path/bitvis_vip_scoreboard $root_path/bitvis_vip_scoreboard/sim
#do $root_path/script/compile_src.do $root_path/bitvis_vip_gpio $root_path/bitvis_vip_gpio/sim
#do $root_path/script/compile_src.do $root_path/bitvis_vip_sbi $root_path/bitvis_vip_sbi/sim
#do $root_path/script/compile_src.do $root_path/bitvis_vip_gmii $root_path/bitvis_vip_gmii/sim
#do $root_path/script/compile_src.do $root_path/bitvis_vip_hvvc_to_vvc_bridge $root_path/bitvis_vip_hvvc_to_vvc_bridge/sim
#do $root_path/script/compile_src.do $root_path/bitvis_vip_ethernet $root_path/bitvis_vip_ethernet/sim
#do $root_path/script/compile_src.do $root_path/bitvis_vip_clock_generator $root_path/bitvis_vip_clock_generator/sim

#do compile_src.do
#do compile_demo_tb.do
#do simulate_demo_tb.do

quietly set sim_dir "sim"
file mkdir sim_dir


proc create_lib {lib_dir lib_name} {
  set lib_path ./sim_dir/rtl_$lib_name
  if {[file exists $lib_path]} {
  	vdel -lib $lib_path -all
  }
  vlib $lib_path
  vmap $lib_name $lib_path
}

quietly set vlog_option -mfcu

#Compile axi_lite sources
create_lib sim_dir axi_lite_lib

quietly set axi_lite_path "../../rtl/axi"
vlog $vlog_option -work axi_lite_lib $axi_lite_path/common_verification/rand_id_queue.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/common_verification/clk_rst_gen.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/axi_pkg.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/cf_math_pkg.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/addr_decode.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/axi_lite_regs.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/spill_register.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/spill_register_flushable.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/axi_test.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/axi_intf.sv
vlog $vlog_option -work axi_lite_lib $axi_lite_path/axi_to_axi_lite.sv

#Compile fpga_foc_top sources
create_lib sim_dir foc_lib

quietly set foc_path "../../rtl/foc"
vlog $vlog_option -work foc_lib $foc_path/adc_ad7928.sv
#vlog $vlog_option -work foc_lib $foc_path/foc_ctrl_top.sv
vlog $vlog_option -work foc_lib $foc_path/foc2axi_lite.sv
vlog $vlog_option -work foc_lib $foc_path/i2c_register_read.sv
vlog $vlog_option -work foc_lib $foc_path/cartesian2polar.sv
vlog $vlog_option -work foc_lib $foc_path/clark_tr.sv
vlog $vlog_option -work foc_lib $foc_path/foc_top.sv
vlog $vlog_option -work foc_lib $foc_path/hold_detect.sv
vlog $vlog_option -work foc_lib $foc_path/park_tr.sv
vlog $vlog_option -work foc_lib $foc_path/pi_controller.sv
vlog $vlog_option -work foc_lib $foc_path/sincos.sv
vlog $vlog_option -work foc_lib $foc_path/svpwm.sv

#Compile TestBench
create_lib sim_dir tb_lib
quietly set testbench_path "."

vlog $vlog_option -work tb_lib -L foc_lib $testbench_path/tb_clark_park_tr.sv
vlog $vlog_option -work tb_lib -L foc_lib $testbench_path/tb_svpwm.sv
#vlog $vlog_option -work tb_lib -L axi_lite_lib $testbench_path/tb_foc_ctrl_top.sv

# Start simulation
#vsim -voptargs=+acc -L foc_lib -L tb_lib -L axi_lite_lib foc_lib.foc2axi_lite
#log * -r

do wave.do
