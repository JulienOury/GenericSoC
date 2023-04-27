module cve2 (
	clk_i,
	rst_ni,
	test_en_i,
	instr_req_o,
	instr_gnt_i,
	instr_rvalid_i,
	instr_addr_o,
	instr_rdata_i,
	instr_err_i,
	data_req_o,
	data_gnt_i,
	data_rvalid_i,
	data_we_o,
	data_be_o,
	data_addr_o,
	data_wdata_o,
	data_rdata_i,
	data_err_i,
	irq_software_i,
	irq_timer_i,
	irq_external_i,
	irq_fast_i,
	irq_nm_i,
	debug_req_i,
	core_sleep_o,
	scan_rst_ni
);
	input wire clk_i;
	input wire rst_ni;
	input wire test_en_i;
	output wire instr_req_o;
	input wire instr_gnt_i;
	input wire instr_rvalid_i;
	output wire [31:0] instr_addr_o;
	input wire [31:0] instr_rdata_i;
	input wire instr_err_i;
	output wire data_req_o;
	input wire data_gnt_i;
	input wire data_rvalid_i;
	output wire data_we_o;
	output wire [3:0] data_be_o;
	output wire [31:0] data_addr_o;
	output wire [31:0] data_wdata_o;
	input wire [31:0] data_rdata_i;
	input wire data_err_i;
	input wire irq_software_i;
	input wire irq_timer_i;
	input wire irq_external_i;
	input wire [14:0] irq_fast_i;
	input wire irq_nm_i;
	input wire debug_req_i;
	output wire core_sleep_o;
	input wire scan_rst_ni;
	localparam [31:0] MHPMCounterNum = 0;
	localparam [31:0] MHPMCounterWidth = 40;
	localparam [0:0] RV32E = 1'b0;
	localparam integer RV32M = 32'sd2;
	localparam [0:0] WritebackStage = 1'b0;
	localparam [0:0] BranchPredictor = 1'b0;
	localparam [31:0] DmHaltAddr = 32'h1a110800;
	localparam [31:0] DmExceptionAddr = 32'h1a110808;
	localparam [31:0] hart_id_i = 32'h1234abcd;
	localparam [31:0] boot_addr_i = 32'h00000000;
	localparam [9:0] prim_ram_1p_pkg_RAM_1P_CFG_DEFAULT = 1'sb0;
	localparam [9:0] ram_cfg_i = prim_ram_1p_pkg_RAM_1P_CFG_DEFAULT;
	wire [6:0] dummy_data_wdata_intg_o;
	wire [127:0] dummy_crash_dump_o;
	wire open;
	cve2_top #(
		.MHPMCounterNum(MHPMCounterNum),
		.MHPMCounterWidth(MHPMCounterWidth),
		.RV32E(RV32E),
		.RV32M(RV32M),
		.WritebackStage(WritebackStage),
		.BranchPredictor(BranchPredictor),
		.DmHaltAddr(DmHaltAddr),
		.DmExceptionAddr(DmExceptionAddr)
	) u_cve2_top(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.test_en_i(test_en_i),
		.ram_cfg_i(ram_cfg_i),
		.hart_id_i(hart_id_i),
		.boot_addr_i(boot_addr_i),
		.instr_req_o(instr_req_o),
		.instr_gnt_i(instr_gnt_i),
		.instr_rvalid_i(instr_rvalid_i),
		.instr_addr_o(instr_addr_o),
		.instr_rdata_i(instr_rdata_i),
		.instr_rdata_intg_i(7'b0000000),
		.instr_err_i(instr_err_i),
		.data_req_o(data_req_o),
		.data_gnt_i(data_gnt_i),
		.data_rvalid_i(data_rvalid_i),
		.data_we_o(data_we_o),
		.data_be_o(data_be_o),
		.data_addr_o(data_addr_o),
		.data_wdata_o(data_wdata_o),
		.data_wdata_intg_o(dummy_data_wdata_intg_o),
		.data_rdata_i(data_rdata_i),
		.data_rdata_intg_i(7'b0000000),
		.data_err_i(data_err_i),
		.irq_software_i(irq_software_i),
		.irq_timer_i(irq_timer_i),
		.irq_external_i(irq_external_i),
		.irq_fast_i(irq_fast_i),
		.irq_nm_i(irq_nm_i),
		.debug_req_i(debug_req_i),
		.crash_dump_o(dummy_crash_dump_o),
		.alert_minor_o(open),
		.alert_major_internal_o(open),
		.alert_major_bus_o(open),
		.core_sleep_o(core_sleep_o),
		.scan_rst_ni(scan_rst_ni)
	);
endmodule
