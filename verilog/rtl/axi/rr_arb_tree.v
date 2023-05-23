module rr_arb_tree_25AF9 (
	clk_i,
	rst_ni,
	flush_i,
	rr_i,
	req_i,
	gnt_o,
	data_i,
	req_o,
	gnt_i,
	data_o,
	idx_o
);
	parameter [31:0] NumIn = 64;
	parameter [31:0] DataWidth = 32;
	parameter [0:0] ExtPrio = 1'b0;
	parameter [0:0] AxiVldRdy = 1'b0;
	parameter [0:0] LockIn = 1'b0;
	parameter [0:0] FairArb = 1'b1;
	parameter [31:0] IdxWidth = (NumIn > 32'd1 ? $unsigned($clog2(NumIn)) : 32'd1);
	input wire clk_i;
	input wire rst_ni;
	input wire flush_i;
	input wire [IdxWidth - 1:0] rr_i;
	input wire [NumIn - 1:0] req_i;
	output wire [NumIn - 1:0] gnt_o;
	input wire [NumIn - 1:0] data_i;
	output wire req_o;
	input wire gnt_i;
	output wire data_o;
	output wire [IdxWidth - 1:0] idx_o;
	function automatic [IdxWidth - 1:0] sv2v_cast_29535;
		input reg [IdxWidth - 1:0] inp;
		sv2v_cast_29535 = inp;
	endfunction
	generate
		if (NumIn == $unsigned(1)) begin : gen_pass_through
			assign req_o = req_i[0];
			assign gnt_o[0] = gnt_i;
			assign data_o = data_i[0];
			assign idx_o = 1'sb0;
		end
		else begin : gen_arbiter
			localparam [31:0] NumLevels = $unsigned($clog2(NumIn));
			wire [(((2 ** NumLevels) - 2) >= 0 ? (((2 ** NumLevels) - 1) * IdxWidth) - 1 : ((3 - (2 ** NumLevels)) * IdxWidth) + ((((2 ** NumLevels) - 2) * IdxWidth) - 1)):(((2 ** NumLevels) - 2) >= 0 ? 0 : ((2 ** NumLevels) - 2) * IdxWidth)] index_nodes;
			wire [(2 ** NumLevels) - 2:0] data_nodes;
			wire [(2 ** NumLevels) - 2:0] gnt_nodes;
			wire [(2 ** NumLevels) - 2:0] req_nodes;
			reg [IdxWidth - 1:0] rr_q;
			wire [NumIn - 1:0] req_d;
			assign req_o = req_nodes[0];
			assign data_o = data_nodes[0];
			assign idx_o = index_nodes[(((2 ** NumLevels) - 2) >= 0 ? 0 : (2 ** NumLevels) - 2) * IdxWidth+:IdxWidth];
			if (ExtPrio) begin : gen_ext_rr
				wire [IdxWidth:1] sv2v_tmp_4C2F0;
				assign sv2v_tmp_4C2F0 = rr_i;
				always @(*) rr_q = sv2v_tmp_4C2F0;
				assign req_d = req_i;
			end
			else begin : gen_int_rr
				wire [IdxWidth - 1:0] rr_d;
				if (LockIn) begin : gen_lock
					wire lock_d;
					reg lock_q;
					reg [NumIn - 1:0] req_q;
					assign lock_d = req_o & ~gnt_i;
					assign req_d = (lock_q ? req_q : req_i);
					always @(posedge clk_i or negedge rst_ni) begin : p_lock_reg
						if (!rst_ni)
							lock_q <= 1'sb0;
						else if (flush_i)
							lock_q <= 1'sb0;
						else
							lock_q <= lock_d;
					end
					always @(posedge clk_i or negedge rst_ni) begin : p_req_regs
						if (!rst_ni)
							req_q <= 1'sb0;
						else if (flush_i)
							req_q <= 1'sb0;
						else
							req_q <= req_d;
					end
				end
				else begin : gen_no_lock
					assign req_d = req_i;
				end
				if (FairArb) begin : gen_fair_arb
					wire [NumIn - 1:0] upper_mask;
					wire [NumIn - 1:0] lower_mask;
					wire [IdxWidth - 1:0] upper_idx;
					wire [IdxWidth - 1:0] lower_idx;
					wire [IdxWidth - 1:0] next_idx;
					wire upper_empty;
					wire lower_empty;
					genvar i;
					for (i = 0; i < NumIn; i = i + 1) begin : gen_mask
						assign upper_mask[i] = (i > rr_q ? req_d[i] : 1'b0);
						assign lower_mask[i] = (i <= rr_q ? req_d[i] : 1'b0);
					end
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_upper(
						.in_i(upper_mask),
						.cnt_o(upper_idx),
						.empty_o(upper_empty)
					);
					lzc #(
						.WIDTH(NumIn),
						.MODE(1'b0)
					) i_lzc_lower(
						.in_i(lower_mask),
						.cnt_o(lower_idx),
						.empty_o()
					);
					assign next_idx = (upper_empty ? lower_idx : upper_idx);
					assign rr_d = (gnt_i && req_o ? next_idx : rr_q);
				end
				else begin : gen_unfair_arb
					assign rr_d = (gnt_i && req_o ? (rr_q == sv2v_cast_29535(NumIn - 1) ? {IdxWidth {1'sb0}} : rr_q + 1'b1) : rr_q);
				end
				always @(posedge clk_i or negedge rst_ni) begin : p_rr_regs
					if (!rst_ni)
						rr_q <= 1'sb0;
					else if (flush_i)
						rr_q <= 1'sb0;
					else
						rr_q <= rr_d;
				end
			end
			assign gnt_nodes[0] = gnt_i;
			genvar level;
			for (level = 0; $unsigned(level) < NumLevels; level = level + 1) begin : gen_levels
				genvar l;
				for (l = 0; l < (2 ** level); l = l + 1) begin : gen_level
					wire sel;
					localparam [31:0] Idx0 = ((2 ** level) - 1) + l;
					localparam [31:0] Idx1 = ((2 ** (level + 1)) - 1) + (l * 2);
					if ($unsigned(level) == (NumLevels - 1)) begin : gen_first_level
						if (($unsigned(l) * 2) < (NumIn - 1)) begin : gen_reduce
							assign req_nodes[Idx0] = req_d[l * 2] | req_d[(l * 2) + 1];
							assign sel = ~req_d[l * 2] | (req_d[(l * 2) + 1] & rr_q[(NumLevels - 1) - level]);
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_29535(sel);
							assign data_nodes[Idx0] = (sel ? data_i[(l * 2) + 1] : data_i[l * 2]);
							assign gnt_o[l * 2] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2])) & ~sel;
							assign gnt_o[(l * 2) + 1] = (gnt_nodes[Idx0] & (AxiVldRdy | req_d[(l * 2) + 1])) & sel;
						end
						if (($unsigned(l) * 2) == (NumIn - 1)) begin : gen_first
							assign req_nodes[Idx0] = req_d[l * 2];
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = 1'sb0;
							assign data_nodes[Idx0] = data_i[l * 2];
							assign gnt_o[l * 2] = gnt_nodes[Idx0] & (AxiVldRdy | req_d[l * 2]);
						end
						if (($unsigned(l) * 2) > (NumIn - 1)) begin : gen_out_of_range
							assign req_nodes[Idx0] = 1'b0;
							assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = sv2v_cast_29535(1'sb0);
							assign data_nodes[Idx0] = 1'b0;
						end
					end
					else begin : gen_other_levels
						assign req_nodes[Idx0] = req_nodes[Idx1] | req_nodes[Idx1 + 1];
						assign sel = ~req_nodes[Idx1] | (req_nodes[Idx1 + 1] & rr_q[(NumLevels - 1) - level]);
						assign index_nodes[(((2 ** NumLevels) - 2) >= 0 ? Idx0 : ((2 ** NumLevels) - 2) - Idx0) * IdxWidth+:IdxWidth] = (sel ? sv2v_cast_29535({1'b1, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 + 1 : ((2 ** NumLevels) - 2) - (Idx1 + 1)) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}) : sv2v_cast_29535({1'b0, index_nodes[((((2 ** NumLevels) - 2) >= 0 ? Idx1 : ((2 ** NumLevels) - 2) - Idx1) * IdxWidth) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 2 : (((NumLevels - $unsigned(level)) - 2) + (((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))) - 1)-:(((NumLevels - $unsigned(level)) - 2) >= 0 ? (NumLevels - $unsigned(level)) - 1 : 3 - (NumLevels - $unsigned(level)))]}));
						assign data_nodes[Idx0] = (sel ? data_nodes[Idx1 + 1] : data_nodes[Idx1]);
						assign gnt_nodes[Idx1] = gnt_nodes[Idx0] & ~sel;
						assign gnt_nodes[Idx1 + 1] = gnt_nodes[Idx0] & sel;
					end
				end
			end
		end
	endgenerate
endmodule
