quietly WaveActivateNextPane {} 0
add wave -noupdate /caravel_th/power1
add wave -noupdate /caravel_th/power2
add wave -noupdate /caravel_th/clock_tb
add wave -noupdate /caravel_th/resetb_tb
add wave -noupdate /caravel_th/gpio

add wave -noupdate -group Wishbone -label clk   /caravel_th/uut/mprj/wb_clk_i
add wave -noupdate -group Wishbone -label rst   /caravel_th/uut/mprj/wb_rst_i
add wave -noupdate -group Wishbone -label stb   /caravel_th/uut/mprj/wbs_stb_i
add wave -noupdate -group Wishbone -label cyc   /caravel_th/uut/mprj/wbs_cyc_i
add wave -noupdate -group Wishbone -label we    /caravel_th/uut/mprj/wbs_we_i
add wave -noupdate -group Wishbone -label sel   /caravel_th/uut/mprj/wbs_sel_i
add wave -noupdate -group Wishbone -label adr   /caravel_th/uut/mprj/wbs_adr_i
add wave -noupdate -group Wishbone -label dat_i /caravel_th/uut/mprj/wbs_dat_i
add wave -noupdate -group Wishbone -label dat_o /caravel_th/uut/mprj/wbs_dat_o
add wave -noupdate -group Wishbone -label ack   /caravel_th/uut/mprj/wbs_ack_o

add wave -noupdate -group SysManager -label mem_req       /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_req
add wave -noupdate -group SysManager -label mem_gnt       /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_gnt
add wave -noupdate -group SysManager -label mem_addr      /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_addr
add wave -noupdate -group SysManager -label mem_wdata     /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_wdata
add wave -noupdate -group SysManager -label mem_strb      /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_strb
add wave -noupdate -group SysManager -label mem_we        /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_we
add wave -noupdate -group SysManager -label mem_rvalid    /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_rvalid
add wave -noupdate -group SysManager -label mem_rdata     /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/mem_rdata
add wave -noupdate -group SysManager -label proc_clear_n  /caravel_th/uut/mprj/inst_main_partition/inst_axi_system_manager/proc_clear_n

add wave -position end {sim:/caravel_th/uut/mprj/inst_main_partition/master[2]/*}

TreeUpdate [SetDefaultTree]
