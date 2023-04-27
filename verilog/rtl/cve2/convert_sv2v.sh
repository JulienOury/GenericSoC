export PATH="../../../dependencies/sv2v/bin:$PATH"

#rm -rf ./cve2-core-local
### ../../../script/VerilogDirectoryConversion.sh -r -l ./sv2v.log ./ cve2-core cve2-core-local
### 
### cp "./cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv"                  "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv"
### cp "./cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_dummy_macros.svh"    "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_dummy_macros.svh"
### cp "./cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_sec_cm.svh"          "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_sec_cm.svh"
### cp "./cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv"              "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv"
### cp "./cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh"
### cp "./cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv"              "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv"
### 
### cp "./cve2-core/vendor/lowrisc_ip/dv/sv/dv_utils/dv_fcov_macros.svh"           "./cve2-core-local/vendor/lowrisc_ip/dv/sv/dv_utils/dv_fcov_macros.svh"
### 
### 
### 
### cp "./cve2-core/vendor/lowrisc_ip/dv/sv/dv_utils/dv_fcov_macros.svh"        "./cve2-core-local/rtl/dv_fcov_macros.svh"            #redundant
### cp "./cve2-core/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv"               "./cve2-core-local/rtl/prim_assert.sv"                #redundant
### cp "./cve2-core/rtl/cve2_pkg.sv"                                            "./cve2-core-local/rtl/cve2_pkg.sv"
### cp "./cve2-core/rtl/cve2_alu.sv"                                            "./cve2-core-local/rtl/cve2_alu.sv"
### cp "./cve2-core/rtl/cve2_compressed_decoder.sv"                             "./cve2-core-local/rtl/cve2_compressed_decoder.sv"
### cp "./cve2-core/rtl/cve2_controller.sv"                                     "./cve2-core-local/rtl/cve2_controller.sv"
### cp "./cve2-core/rtl/cve2_cs_registers.sv"                                   "./cve2-core-local/rtl/cve2_cs_registers.sv"
### cp "./cve2-core/rtl/cve2_pmp_reset_default.svh"                             "./cve2-core-local/rtl/cve2_pmp_reset_default.svh"
### cp "./cve2-core/rtl/cve2_counter.sv"                                        "./cve2-core-local/rtl/cve2_counter.sv"
### cp "./cve2-core/rtl/cve2_decoder.sv"                                        "./cve2-core-local/rtl/cve2_decoder.sv"
### cp "./cve2-core/rtl/cve2_ex_block.sv"                                       "./cve2-core-local/rtl/cve2_ex_block.sv"
### cp "./cve2-core/rtl/cve2_id_stage.sv"                                       "./cve2-core-local/rtl/cve2_id_stage.sv"
### cp "./cve2-core/rtl/cve2_if_stage.sv"                                       "./cve2-core-local/rtl/cve2_if_stage.sv"
### cp "./cve2-core/rtl/cve2_wb_stage.sv"                                       "./cve2-core-local/rtl/cve2_wb_stage.sv"
### cp "./cve2-core/rtl/cve2_load_store_unit.sv"                                "./cve2-core-local/rtl/cve2_load_store_unit.sv"
### cp "./cve2-core/rtl/cve2_multdiv_slow.sv"                                   "./cve2-core-local/rtl/cve2_multdiv_slow.sv"
### cp "./cve2-core/rtl/cve2_multdiv_fast.sv"                                   "./cve2-core-local/rtl/cve2_multdiv_fast.sv"
### cp "./cve2-core/rtl/cve2_prefetch_buffer.sv"                                "./cve2-core-local/rtl/cve2_prefetch_buffer.sv"
### cp "./cve2-core/rtl/cve2_fetch_fifo.sv"                                     "./cve2-core-local/rtl/cve2_fetch_fifo.sv"
### cp "./cve2-core/rtl/cve2_pmp.sv"                                            "./cve2-core-local/rtl/cve2_pmp.sv"
### cp "./cve2-core/rtl/cve2_core.sv"                                           "./cve2-core-local/rtl/cve2_core.sv"
### cp "./cve2-core/rtl/cve2_csr.sv"                                            "./cve2-core-local/rtl/cve2_csr.sv"
### cp "./cve2-core/rtl/cve2_register_file_ff.sv"                               "./cve2-core-local/rtl/cve2_register_file_ff.sv"
### cp "./cve2-core/rtl/cve2_top.sv"                                            "./cve2-core-local/rtl/cve2_top.sv"
### 
### cp "./cve2-core/syn/rtl/prim_clock_gating.v"                                "./cve2-core-local/syn/rtl/prim_clock_gating.v"
### 
### 
### sed -i '87s/.*/\/\//' "./cve2-core-local/rtl/cve2_ex_block.sv"
### sed -i '92s/.*/\/\//' "./cve2-core-local/rtl/cve2_ex_block.sv"
### sed -i '301s/.*/\/\//' "./cve2-core-local/rtl/cve2_id_stage.sv"
### sed -i '326s/.*/\/\//' "./cve2-core-local/rtl/cve2_id_stage.sv"
### sed -i '601s/.*/\/\//' "./cve2-core-local/rtl/cve2_id_stage.sv"
### sed -i '620s/.*/\/\//' "./cve2-core-local/rtl/cve2_id_stage.sv"     
### sed -i '168s/.*/\/\//' "./cve2-core-local/rtl/cve2_if_stage.sv"
### sed -i '198s/.*/\/\//' "./cve2-core-local/rtl/cve2_if_stage.sv"
### sed -i '259s/.*/\/\//' "./cve2-core-local/rtl/cve2_if_stage.sv"
### sed -i '282s/.*/\/\//' "./cve2-core-local/rtl/cve2_if_stage.sv"
### sed -i '151s/.*/\/\//' "./cve2-core-local/rtl/cve2_fetch_fifo.sv"
### sed -i '159s/.*/\/\//' "./cve2-core-local/rtl/cve2_fetch_fifo.sv"
### sed -i '370s/.*/\/\//' "./cve2-core-local/rtl/cve2_core.sv"
### sed -i '373s/.*/\/\//' "./cve2-core-local/rtl/cve2_core.sv"
### sed -i '729s/.*/\/\//' "./cve2-core-local/rtl/cve2_core.sv"
### sed -i '748s/.*/\/\//' "./cve2-core-local/rtl/cve2_core.sv"     
### sed -i '64s/.*/\/\//' "./cve2-core-local/rtl/cve2_register_file_ff.sv"
### sed -i '67s/.*/\/\//' "./cve2-core-local/rtl/cve2_register_file_ff.sv"
### sed -i '249s/.*/\/\//' "./cve2-core-local/rtl/cve2_top.sv"
### sed -i '257s/.*/\/\//' "./cve2-core-local/rtl/cve2_top.sv"
### sed -i '157s/.*/\/\//' "./cve2-core-local/rtl/cve2_prefetch_buffer.sv"
### sed -i '165s/.*/\/\//' "./cve2-core-local/rtl/cve2_prefetch_buffer.sv"
### sed -i '177s/.*/\/\//' "./cve2-core-local/rtl/cve2_prefetch_buffer.sv"
### sed -i '185s/.*/\/\//' "./cve2-core-local/rtl/cve2_prefetch_buffer.sv"


# sv2v -w "./cve2-core-local/rtl/cve2_alu.v" \
#         "./cve2-core-local/rtl/cve2_pkg.sv" \
#         "./cve2-core-local/rtl/cve2_alu.sv"
# 
# sv2v -w "./cve2-core-local/rtl/cve2_compressed_decoder.v" \
#         "./cve2-core-local/rtl/cve2_pkg.sv" \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#         "./cve2-core-local/rtl/cve2_compressed_decoder.sv"
#      
# sv2v -w "./cve2-core-local/rtl/cve2_controller.v" \
#         "./cve2-core-local/rtl/cve2_pkg.sv" \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#         "./cve2-core-local/rtl/cve2_controller.sv"
#      
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/rtl/cve2_cs_registers.sv" > "./cve2-core-local/rtl/cve2_cs_registers.v"
#      
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/rtl/cve2_decoder.sv" > "./cve2-core-local/rtl/cve2_decoder.v"
# 
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/rtl/cve2_ex_block.sv" > "./cve2-core-local/rtl/cve2_ex_block.v"
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/rtl/cve2_id_stage.sv" > "./cve2-core-local/rtl/cve2_id_stage.v"
#      
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/rtl/cve2_if_stage.sv" > "./cve2-core-local/rtl/cve2_if_stage.v"
# 
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/rtl/cve2_wb_stage.sv" > "./cve2-core-local/rtl/cve2_wb_stage.v"
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/rtl/cve2_multdiv_slow.sv" > "./cve2-core-local/rtl/cve2_multdiv_slow.v"
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/rtl/cve2_multdiv_fast.sv" > "./cve2-core-local/rtl/cve2_multdiv_fast.v"
# 
# sv2v -w "./cve2-core-local/rtl/cve2_fetch_fifo.v" \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#         "./cve2-core-local/rtl/cve2_fetch_fifo.sv"
#      
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/rtl/cve2_pmp.sv" > "./cve2-core-local/rtl/cve2_pmp.v"
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv" \
#      "./cve2-core-local/rtl/cve2_core.sv" > "./cve2-core-local/rtl/cve2_core.v"
#      
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv" \
#      "./cve2.sv" > "./cve2.v"
# 
# sv2v "./cve2-core-local/rtl/cve2_register_file_ff.sv" > "./cve2-core-local/rtl/cve2_register_file_ff.v"
# 
# sv2v "./cve2-core-local/rtl/cve2_pkg.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert_standard_macros.svh" \
#      "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv" \
#      "./cve2-core-local/rtl/cve2_top.sv" > "./cve2-core-local/rtl/cve2_top.v"
     
     
# sv2v -w adjacent                                                                          \
#         "./cve2-core-local/rtl/cve2_pkg.sv"                                               \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv"                  \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv"              \
#         "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv"              \
#         "./cve2-core-local/rtl/cve2_alu.sv"                                               \
#         "./cve2-core-local/rtl/cve2_compressed_decoder.sv"                                \
#         "./cve2-core-local/rtl/cve2_controller.sv"                                        \
#         "./cve2-core-local/rtl/cve2_cs_registers.sv"                                      \
#         "./cve2-core-local/rtl/cve2_decoder.sv"                                           \
#         "./cve2-core-local/rtl/cve2_ex_block.sv"                                          \
#         "./cve2-core-local/rtl/cve2_id_stage.sv"                                          \
#         "./cve2-core-local/rtl/cve2_if_stage.sv"                                          \
#         "./cve2-core-local/rtl/cve2_wb_stage.sv"                                          \
#         "./cve2-core-local/rtl/cve2_multdiv_slow.sv"                                      \
#         "./cve2-core-local/rtl/cve2_multdiv_fast.sv"                                      \
#         "./cve2-core-local/rtl/cve2_fetch_fifo.sv"                                        \
#         "./cve2-core-local/rtl/cve2_pmp.sv"                                               \
#         "./cve2-core-local/rtl/cve2_register_file_ff.sv"                                  \
#         "./cve2-core-local/rtl/cve2_core.sv"                                              \
#         "./cve2-core-local/rtl/cve2_top.sv"                                               \
#         "./cve2.sv"
     

sv2v -w adjacent                                                                          \
		 --define=SYNTHESIS                                                                   \
        "./cve2-core-local/rtl/cve2_pkg.sv"                                               \
        "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_assert.sv"                  \
        "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_secded_pkg.sv"              \
        "./cve2-core-local/vendor/lowrisc_ip/ip/prim/rtl/prim_ram_1p_pkg.sv"              \
        "./cve2-core-local/rtl/cve2_alu.sv"                                               \
        "./cve2-core-local/rtl/cve2_compressed_decoder.sv"                                \
        "./cve2-core-local/rtl/cve2_controller.sv"                                        \
        "./cve2-core-local/rtl/cve2_csr.sv"                                               \
        "./cve2-core-local/rtl/cve2_cs_registers.sv"                                      \
        "./cve2-core-local/rtl/cve2_load_store_unit.sv"                                   \
        "./cve2-core-local/rtl/cve2_prefetch_buffer.sv"                                   \
        "./cve2-core-local/rtl/cve2_decoder.sv"                                           \
        "./cve2-core-local/rtl/cve2_ex_block.sv"                                          \
        "./cve2-core-local/rtl/cve2_id_stage.sv"                                          \
        "./cve2-core-local/rtl/cve2_if_stage.sv"                                          \
        "./cve2-core-local/rtl/cve2_wb_stage.sv"                                          \
        "./cve2-core-local/rtl/cve2_multdiv_slow.sv"                                      \
        "./cve2-core-local/rtl/cve2_multdiv_fast.sv"                                      \
        "./cve2-core-local/rtl/cve2_fetch_fifo.sv"                                        \
        "./cve2-core-local/rtl/cve2_pmp.sv"                                               \
        "./cve2-core-local/rtl/cve2_register_file_ff.sv"                                  \
        "./cve2-core-local/rtl/cve2_core.sv"                                              \
        "./cve2-core-local/rtl/cve2_top.sv"                                               \
        "./cve2.sv"
