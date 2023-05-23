module addr_decode_160C3_6EDEE (
	addr_i,
	addr_map_i,
	idx_o,
	dec_valid_o,
	dec_error_o,
	en_default_idx_i,
	default_idx_i
);
	parameter [331:0] addr_t_Cfg = 0;
	parameter [31:0] NoIndices = 32'd0;
	parameter [31:0] NoRules = 32'd0;
	parameter [0:0] Napot = 0;
	function automatic [31:0] cf_math_pkg_idx_width;
		input reg [31:0] num_idx;
		cf_math_pkg_idx_width = (num_idx > 32'd1 ? $unsigned($clog2(num_idx)) : 32'd1);
	endfunction
	parameter [31:0] IdxWidth = cf_math_pkg_idx_width(NoIndices);
	input wire [addr_t_Cfg[95-:32] - 1:0] addr_i;
	input wire [(NoRules * 160) - 1:0] addr_map_i;
	output reg [IdxWidth - 1:0] idx_o;
	output reg dec_valid_o;
	output reg dec_error_o;
	input wire en_default_idx_i;
	input wire [IdxWidth - 1:0] default_idx_i;
	reg [NoRules - 1:0] matched_rules;
	function automatic [IdxWidth - 1:0] sv2v_cast_29535;
		input reg [IdxWidth - 1:0] inp;
		sv2v_cast_29535 = inp;
	endfunction
	always @(*) begin
		matched_rules = 1'sb0;
		dec_valid_o = 1'b0;
		dec_error_o = (en_default_idx_i ? 1'b0 : 1'b1);
		idx_o = (en_default_idx_i ? default_idx_i : {IdxWidth {1'sb0}});
		begin : sv2v_autoblock_1
			reg [31:0] i;
			for (i = 0; i < NoRules; i = i + 1)
				if (((!Napot && (addr_i >= addr_map_i[(i * 160) + 127-:64])) && ((addr_i < addr_map_i[(i * 160) + 63-:64]) || (addr_map_i[(i * 160) + 63-:64] == {(((0 >= ((NoRules * 160) - 1) ? i * 160 : (i * 160) + 159) >= (0 >= ((NoRules * 160) - 1) ? (i * 160) + 159 : i * 160) ? 63 : 0) >= ((0 >= ((NoRules * 160) - 1) ? i * 160 : (i * 160) + 159) >= (0 >= ((NoRules * 160) - 1) ? (i * 160) + 159 : i * 160) ? 0 : 63) ? (((0 >= ((NoRules * 160) - 1) ? i * 160 : (i * 160) + 159) >= (0 >= ((NoRules * 160) - 1) ? (i * 160) + 159 : i * 160) ? 63 : 0) - ((0 >= ((NoRules * 160) - 1) ? i * 160 : (i * 160) + 159) >= (0 >= ((NoRules * 160) - 1) ? (i * 160) + 159 : i * 160) ? 0 : 63)) + 1 : (((0 >= ((NoRules * 160) - 1) ? i * 160 : (i * 160) + 159) >= (0 >= ((NoRules * 160) - 1) ? (i * 160) + 159 : i * 160) ? 0 : 63) - ((0 >= ((NoRules * 160) - 1) ? i * 160 : (i * 160) + 159) >= (0 >= ((NoRules * 160) - 1) ? (i * 160) + 159 : i * 160) ? 63 : 0)) + 1) {1'sb0}}))) || (Napot && ((addr_map_i[(i * 160) + 127-:64] & addr_map_i[(i * 160) + 63-:64]) == (addr_i & addr_map_i[(i * 160) + 63-:64])))) begin
					matched_rules[i] = 1'b1;
					dec_valid_o = 1'b1;
					dec_error_o = 1'b0;
					idx_o = sv2v_cast_29535(addr_map_i[(i * 160) + 159-:32]);
				end
		end
	end
endmodule
