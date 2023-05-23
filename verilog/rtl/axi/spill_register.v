module spill_register_497C2_3F032 (
	clk_i,
	rst_ni,
	valid_i,
	ready_o,
	data_i,
	valid_o,
	ready_i,
	data_o
);
	parameter [31:0] T_SelectWidth = 0;
	parameter [0:0] Bypass = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	output wire ready_o;
	input wire [T_SelectWidth - 1:0] data_i;
	output wire valid_o;
	input wire ready_i;
	output wire [T_SelectWidth - 1:0] data_o;
	spill_register_flushable_ECCE9_D4EC8 #(
		.T_T_SelectWidth(T_SelectWidth),
		.Bypass(Bypass)
	) spill_register_flushable_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(valid_i),
		.flush_i(1'b0),
		.ready_o(ready_o),
		.data_i(data_i),
		.valid_o(valid_o),
		.ready_i(ready_i),
		.data_o(data_o)
	);
endmodule
module spill_register_F2424 (
	clk_i,
	rst_ni,
	valid_i,
	ready_o,
	data_i,
	valid_o,
	ready_i,
	data_o
);
	parameter [0:0] Bypass = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire valid_i;
	output wire ready_o;
	input wire data_i;
	output wire valid_o;
	input wire ready_i;
	output wire data_o;
	spill_register_flushable_C4179 #(.Bypass(Bypass)) spill_register_flushable_i(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(valid_i),
		.flush_i(1'b0),
		.ready_o(ready_o),
		.data_i(data_i),
		.valid_o(valid_o),
		.ready_i(ready_i),
		.data_o(data_o)
	);
endmodule
