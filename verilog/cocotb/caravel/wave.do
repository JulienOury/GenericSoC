quietly WaveActivateNextPane {} 0
add wave -noupdate -group Power -label vddio   /caravel_th/vddio  
add wave -noupdate -group Power -label vddio_2 /caravel_th/vddio_2
add wave -noupdate -group Power -label vssio   /caravel_th/vssio  
add wave -noupdate -group Power -label vssio_2 /caravel_th/vssio_2
add wave -noupdate -group Power -label vdda    /caravel_th/vdda   
add wave -noupdate -group Power -label vssa    /caravel_th/vssa   
add wave -noupdate -group Power -label vccd    /caravel_th/vccd   
add wave -noupdate -group Power -label vssd    /caravel_th/vssd   
add wave -noupdate -group Power -label vdda1   /caravel_th/vdda1  
add wave -noupdate -group Power -label vdda1_2 /caravel_th/vdda1_2
add wave -noupdate -group Power -label vdda2   /caravel_th/vdda2  
add wave -noupdate -group Power -label vssa1   /caravel_th/vssa1  
add wave -noupdate -group Power -label vssa1_2 /caravel_th/vssa1_2
add wave -noupdate -group Power -label vssa2   /caravel_th/vssa2  
add wave -noupdate -group Power -label vccd1   /caravel_th/vccd1  
add wave -noupdate -group Power -label vccd2   /caravel_th/vccd2  
add wave -noupdate -group Power -label vssd1   /caravel_th/vssd1  
add wave -noupdate -group Power -label vssd2   /caravel_th/vssd2  

add wave -noupdate -label rst_n   /caravel_th/rst_n
add wave -noupdate -label clk_en  /caravel_th/clk_en
add wave -noupdate -label clk     /caravel_th/clk
add wave -noupdate -label gpio    /caravel_th/gpio
add wave -noupdate -label mprj_io /caravel_th/mprj_io

add wave -noupdate -group Flash -label csb  /caravel_th/flash_csb
add wave -noupdate -group Flash -label clk  /caravel_th/flash_clk
add wave -noupdate -group Flash -label io0  /caravel_th/flash_io0
add wave -noupdate -group Flash -label io1  /caravel_th/flash_io1


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

TreeUpdate [SetDefaultTree]
