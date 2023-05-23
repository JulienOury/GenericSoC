module axi_mux_621CA (
	clk_i,
	rst_ni,
	test_i,
	slv_reqs_i,
	slv_resps_o,
	mst_req_o,
	mst_resp_i
);
	parameter [31:0] SlvAxiIDWidth = 32'd0;
	parameter [31:0] NoSlvPorts = 32'd0;
	parameter [31:0] MaxWTrans = 32'd8;
	parameter [0:0] FallThrough = 1'b0;
	parameter [0:0] SpillAw = 1'b1;
	parameter [0:0] SpillW = 1'b0;
	parameter [0:0] SpillB = 1'b0;
	parameter [0:0] SpillAr = 1'b1;
	parameter [0:0] SpillR = 1'b0;
	input wire clk_i;
	input wire rst_ni;
	input wire test_i;
	input wire [NoSlvPorts - 1:0] slv_reqs_i;
	output wire [NoSlvPorts - 1:0] slv_resps_o;
	output wire mst_req_o;
	input wire mst_resp_i;
	localparam [31:0] MstIdxBits = $clog2(NoSlvPorts);
	localparam [31:0] MstAxiIDWidth = SlvAxiIDWidth + MstIdxBits;
	function automatic [MstIdxBits - 1:0] sv2v_cast_548D5;
		input reg [MstIdxBits - 1:0] inp;
		sv2v_cast_548D5 = inp;
	endfunction
	generate
		if (NoSlvPorts == 32'h00000001) begin : gen_no_mux
			spill_register_F2424 #(.Bypass(~SpillAw)) i_aw_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_reqs_i[0].aw_valid),
				.ready_o(slv_resps_o[0].aw_ready),
				.data_i(slv_reqs_i[0].aw),
				.valid_o(mst_req_o.aw_valid),
				.ready_i(mst_resp_i.aw_ready),
				.data_o(mst_req_o.aw)
			);
			spill_register_F2424 #(.Bypass(~SpillW)) i_w_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_reqs_i[0].w_valid),
				.ready_o(slv_resps_o[0].w_ready),
				.data_i(slv_reqs_i[0].w),
				.valid_o(mst_req_o.w_valid),
				.ready_i(mst_resp_i.w_ready),
				.data_o(mst_req_o.w)
			);
			spill_register_F2424 #(.Bypass(~SpillB)) i_b_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_resp_i.b_valid),
				.ready_o(mst_req_o.b_ready),
				.data_i(mst_resp_i.b),
				.valid_o(slv_resps_o[0].b_valid),
				.ready_i(slv_reqs_i[0].b_ready),
				.data_o(slv_resps_o[0].b)
			);
			spill_register_F2424 #(.Bypass(~SpillAr)) i_ar_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_reqs_i[0].ar_valid),
				.ready_o(slv_resps_o[0].ar_ready),
				.data_i(slv_reqs_i[0].ar),
				.valid_o(mst_req_o.ar_valid),
				.ready_i(mst_resp_i.ar_ready),
				.data_o(mst_req_o.ar)
			);
			spill_register_F2424 #(.Bypass(~SpillR)) i_r_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_resp_i.r_valid),
				.ready_o(mst_req_o.r_ready),
				.data_i(mst_resp_i.r),
				.valid_o(slv_resps_o[0].r_valid),
				.ready_i(slv_reqs_i[0].r_ready),
				.data_o(slv_resps_o[0].r)
			);
		end
		else begin : gen_mux
			wire [NoSlvPorts - 1:0] slv_aw_chans;
			wire [NoSlvPorts - 1:0] slv_aw_valids;
			wire [NoSlvPorts - 1:0] slv_aw_readies;
			wire [NoSlvPorts - 1:0] slv_w_chans;
			wire [NoSlvPorts - 1:0] slv_w_valids;
			reg [NoSlvPorts - 1:0] slv_w_readies;
			wire [NoSlvPorts - 1:0] slv_b_chans;
			wire [NoSlvPorts - 1:0] slv_b_valids;
			wire [NoSlvPorts - 1:0] slv_b_readies;
			wire [NoSlvPorts - 1:0] slv_ar_chans;
			wire [NoSlvPorts - 1:0] slv_ar_valids;
			wire [NoSlvPorts - 1:0] slv_ar_readies;
			wire [NoSlvPorts - 1:0] slv_r_chans;
			wire [NoSlvPorts - 1:0] slv_r_valids;
			wire [NoSlvPorts - 1:0] slv_r_readies;
			wire mst_aw_chan;
			reg mst_aw_valid;
			wire mst_aw_ready;
			wire aw_valid;
			reg aw_ready;
			reg lock_aw_valid_d;
			reg lock_aw_valid_q;
			reg load_aw_lock;
			wire w_fifo_full;
			wire w_fifo_empty;
			reg w_fifo_push;
			reg w_fifo_pop;
			wire [MstIdxBits - 1:0] w_fifo_data;
			wire mst_w_chan;
			reg mst_w_valid;
			wire mst_w_ready;
			wire [MstIdxBits - 1:0] switch_b_id;
			wire mst_b_chan;
			wire mst_b_valid;
			wire mst_ar_chan;
			wire ar_valid;
			wire ar_ready;
			wire [MstIdxBits - 1:0] switch_r_id;
			wire mst_r_chan;
			wire mst_r_valid;
			genvar i;
			for (i = 0; i < NoSlvPorts; i = i + 1) begin : gen_id_prepend
				axi_id_prepend_D1C46 #(
					.NoBus(32'd1),
					.AxiIdWidthSlvPort(SlvAxiIDWidth),
					.AxiIdWidthMstPort(MstAxiIDWidth)
				) i_id_prepend(
					.pre_id_i(sv2v_cast_548D5(i)),
					.slv_aw_chans_i(slv_reqs_i[i].aw),
					.slv_aw_valids_i(slv_reqs_i[i].aw_valid),
					.slv_aw_readies_o(slv_resps_o[i].aw_ready),
					.slv_w_chans_i(slv_reqs_i[i].w),
					.slv_w_valids_i(slv_reqs_i[i].w_valid),
					.slv_w_readies_o(slv_resps_o[i].w_ready),
					.slv_b_chans_o(slv_resps_o[i].b),
					.slv_b_valids_o(slv_resps_o[i].b_valid),
					.slv_b_readies_i(slv_reqs_i[i].b_ready),
					.slv_ar_chans_i(slv_reqs_i[i].ar),
					.slv_ar_valids_i(slv_reqs_i[i].ar_valid),
					.slv_ar_readies_o(slv_resps_o[i].ar_ready),
					.slv_r_chans_o(slv_resps_o[i].r),
					.slv_r_valids_o(slv_resps_o[i].r_valid),
					.slv_r_readies_i(slv_reqs_i[i].r_ready),
					.mst_aw_chans_o(slv_aw_chans[i]),
					.mst_aw_valids_o(slv_aw_valids[i]),
					.mst_aw_readies_i(slv_aw_readies[i]),
					.mst_w_chans_o(slv_w_chans[i]),
					.mst_w_valids_o(slv_w_valids[i]),
					.mst_w_readies_i(slv_w_readies[i]),
					.mst_b_chans_i(slv_b_chans[i]),
					.mst_b_valids_i(slv_b_valids[i]),
					.mst_b_readies_o(slv_b_readies[i]),
					.mst_ar_chans_o(slv_ar_chans[i]),
					.mst_ar_valids_o(slv_ar_valids[i]),
					.mst_ar_readies_i(slv_ar_readies[i]),
					.mst_r_chans_i(slv_r_chans[i]),
					.mst_r_valids_i(slv_r_valids[i]),
					.mst_r_readies_o(slv_r_readies[i])
				);
			end
			localparam [31:0] sv2v_uu_i_aw_arbiter_NumIn = NoSlvPorts;
			localparam [31:0] sv2v_uu_i_aw_arbiter_IdxWidth = (sv2v_uu_i_aw_arbiter_NumIn > 32'd1 ? $unsigned($clog2(sv2v_uu_i_aw_arbiter_NumIn)) : 32'd1);
			localparam [sv2v_uu_i_aw_arbiter_IdxWidth - 1:0] sv2v_uu_i_aw_arbiter_ext_rr_i_0 = 1'sb0;
			rr_arb_tree_25AF9 #(
				.NumIn(NoSlvPorts),
				.AxiVldRdy(1'b1),
				.LockIn(1'b1)
			) i_aw_arbiter(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(1'b0),
				.rr_i(sv2v_uu_i_aw_arbiter_ext_rr_i_0),
				.req_i(slv_aw_valids),
				.gnt_o(slv_aw_readies),
				.data_i(slv_aw_chans),
				.gnt_i(aw_ready),
				.req_o(aw_valid),
				.data_o(mst_aw_chan)
			);
			always @(*) begin
				lock_aw_valid_d = lock_aw_valid_q;
				load_aw_lock = 1'b0;
				w_fifo_push = 1'b0;
				mst_aw_valid = 1'b0;
				aw_ready = 1'b0;
				if (lock_aw_valid_q) begin
					mst_aw_valid = 1'b1;
					if (mst_aw_ready) begin
						aw_ready = 1'b1;
						lock_aw_valid_d = 1'b0;
						load_aw_lock = 1'b1;
					end
				end
				else if (!w_fifo_full && aw_valid) begin
					mst_aw_valid = 1'b1;
					w_fifo_push = 1'b1;
					if (mst_aw_ready)
						aw_ready = 1'b1;
					else begin
						lock_aw_valid_d = 1'b1;
						load_aw_lock = 1'b1;
					end
				end
			end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					lock_aw_valid_q <= 1'sb0;
				else if (load_aw_lock)
					lock_aw_valid_q <= lock_aw_valid_d;
			fifo_v3_46451_657B6 #(
				.dtype_MstIdxBits(MstIdxBits),
				.FALL_THROUGH(FallThrough),
				.DEPTH(MaxWTrans)
			) i_w_fifo(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(1'b0),
				.testmode_i(test_i),
				.full_o(w_fifo_full),
				.empty_o(w_fifo_empty),
				.data_i(mst_aw_chan.id[SlvAxiIDWidth+:MstIdxBits]),
				.push_i(w_fifo_push),
				.data_o(w_fifo_data),
				.pop_i(w_fifo_pop)
			);
			spill_register_F2424 #(.Bypass(~SpillAw)) i_aw_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_aw_valid),
				.ready_o(mst_aw_ready),
				.data_i(mst_aw_chan),
				.valid_o(mst_req_o.aw_valid),
				.ready_i(mst_resp_i.aw_ready),
				.data_o(mst_req_o.aw)
			);
			assign mst_w_chan = slv_w_chans[w_fifo_data];
			always @(*) begin
				mst_w_valid = 1'b0;
				slv_w_readies = 1'sb0;
				w_fifo_pop = 1'b0;
				if (!w_fifo_empty) begin
					mst_w_valid = slv_w_valids[w_fifo_data];
					slv_w_readies[w_fifo_data] = mst_w_ready;
					w_fifo_pop = (slv_w_valids[w_fifo_data] & mst_w_ready) & mst_w_chan.last;
				end
			end
			spill_register_F2424 #(.Bypass(~SpillW)) i_w_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_w_valid),
				.ready_o(mst_w_ready),
				.data_i(mst_w_chan),
				.valid_o(mst_req_o.w_valid),
				.ready_i(mst_resp_i.w_ready),
				.data_o(mst_req_o.w)
			);
			assign slv_b_chans = {NoSlvPorts {mst_b_chan}};
			assign switch_b_id = mst_b_chan.id[SlvAxiIDWidth+:MstIdxBits];
			assign slv_b_valids = (mst_b_valid ? 1 << switch_b_id : {NoSlvPorts {1'sb0}});
			spill_register_F2424 #(.Bypass(~SpillB)) i_b_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_resp_i.b_valid),
				.ready_o(mst_req_o.b_ready),
				.data_i(mst_resp_i.b),
				.valid_o(mst_b_valid),
				.ready_i(slv_b_readies[switch_b_id]),
				.data_o(mst_b_chan)
			);
			localparam [31:0] sv2v_uu_i_ar_arbiter_NumIn = NoSlvPorts;
			localparam [31:0] sv2v_uu_i_ar_arbiter_IdxWidth = (sv2v_uu_i_ar_arbiter_NumIn > 32'd1 ? $unsigned($clog2(sv2v_uu_i_ar_arbiter_NumIn)) : 32'd1);
			localparam [sv2v_uu_i_ar_arbiter_IdxWidth - 1:0] sv2v_uu_i_ar_arbiter_ext_rr_i_0 = 1'sb0;
			rr_arb_tree_25AF9 #(
				.NumIn(NoSlvPorts),
				.AxiVldRdy(1'b1),
				.LockIn(1'b1)
			) i_ar_arbiter(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(1'b0),
				.rr_i(sv2v_uu_i_ar_arbiter_ext_rr_i_0),
				.req_i(slv_ar_valids),
				.gnt_o(slv_ar_readies),
				.data_i(slv_ar_chans),
				.gnt_i(ar_ready),
				.req_o(ar_valid),
				.data_o(mst_ar_chan)
			);
			spill_register_F2424 #(.Bypass(~SpillAr)) i_ar_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(ar_valid),
				.ready_o(ar_ready),
				.data_i(mst_ar_chan),
				.valid_o(mst_req_o.ar_valid),
				.ready_i(mst_resp_i.ar_ready),
				.data_o(mst_req_o.ar)
			);
			assign slv_r_chans = {NoSlvPorts {mst_r_chan}};
			assign switch_r_id = mst_r_chan.id[SlvAxiIDWidth+:MstIdxBits];
			assign slv_r_valids = (mst_r_valid ? 1 << switch_r_id : {NoSlvPorts {1'sb0}});
			spill_register_F2424 #(.Bypass(~SpillR)) i_r_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_resp_i.r_valid),
				.ready_o(mst_req_o.r_ready),
				.data_i(mst_resp_i.r),
				.valid_o(mst_r_valid),
				.ready_i(slv_r_readies[switch_r_id]),
				.data_o(mst_r_chan)
			);
		end
	endgenerate
endmodule
