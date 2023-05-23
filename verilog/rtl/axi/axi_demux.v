module axi_demux_B794D (
	clk_i,
	rst_ni,
	test_i,
	slv_req_i,
	slv_aw_select_i,
	slv_ar_select_i,
	slv_resp_o,
	mst_reqs_o,
	mst_resps_i
);
	parameter [31:0] AxiIdWidth = 32'd0;
	parameter [0:0] AtopSupport = 1'b1;
	parameter [31:0] NoMstPorts = 32'd0;
	parameter [31:0] MaxTrans = 32'd8;
	parameter [31:0] AxiLookBits = 32'd3;
	parameter [0:0] UniqueIds = 1'b0;
	parameter [0:0] SpillAw = 1'b1;
	parameter [0:0] SpillW = 1'b0;
	parameter [0:0] SpillB = 1'b0;
	parameter [0:0] SpillAr = 1'b1;
	parameter [0:0] SpillR = 1'b0;
	parameter [31:0] SelectWidth = (NoMstPorts > 32'd1 ? $clog2(NoMstPorts) : 32'd1);
	input wire clk_i;
	input wire rst_ni;
	input wire test_i;
	input wire slv_req_i;
	input wire [SelectWidth - 1:0] slv_aw_select_i;
	input wire [SelectWidth - 1:0] slv_ar_select_i;
	output wire slv_resp_o;
	output reg [NoMstPorts - 1:0] mst_reqs_o;
	input wire [NoMstPorts - 1:0] mst_resps_i;
	function automatic [31:0] cf_math_pkg_idx_width;
		input reg [31:0] num_idx;
		cf_math_pkg_idx_width = (num_idx > 32'd1 ? $unsigned($clog2(num_idx)) : 32'd1);
	endfunction
	localparam [31:0] IdCounterWidth = cf_math_pkg_idx_width(MaxTrans);
	localparam axi_pkg_ATOP_R_RESP = 32'd5;
	function automatic [SelectWidth - 1:0] sv2v_cast_4FC3B;
		input reg [SelectWidth - 1:0] inp;
		sv2v_cast_4FC3B = inp;
	endfunction
	generate
		if (NoMstPorts == 32'h00000001) begin : gen_no_demux
			wire [$bits(type(mst_reqs_o[0].aw_valid)):1] sv2v_tmp_i_aw_spill_reg_valid_o;
			always @(*) mst_reqs_o[0].aw_valid = sv2v_tmp_i_aw_spill_reg_valid_o;
			wire [$bits(type(mst_reqs_o[0].aw)):1] sv2v_tmp_i_aw_spill_reg_data_o;
			always @(*) mst_reqs_o[0].aw = sv2v_tmp_i_aw_spill_reg_data_o;
			spill_register_F2424 #(.Bypass(~SpillAw)) i_aw_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.aw_valid),
				.ready_o(slv_resp_o.aw_ready),
				.data_i(slv_req_i.aw),
				.valid_o(sv2v_tmp_i_aw_spill_reg_valid_o),
				.ready_i(mst_resps_i[0].aw_ready),
				.data_o(sv2v_tmp_i_aw_spill_reg_data_o)
			);
			wire [$bits(type(mst_reqs_o[0].w_valid)):1] sv2v_tmp_i_w_spill_reg_valid_o;
			always @(*) mst_reqs_o[0].w_valid = sv2v_tmp_i_w_spill_reg_valid_o;
			wire [$bits(type(mst_reqs_o[0].w)):1] sv2v_tmp_i_w_spill_reg_data_o;
			always @(*) mst_reqs_o[0].w = sv2v_tmp_i_w_spill_reg_data_o;
			spill_register_F2424 #(.Bypass(~SpillW)) i_w_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.w_valid),
				.ready_o(slv_resp_o.w_ready),
				.data_i(slv_req_i.w),
				.valid_o(sv2v_tmp_i_w_spill_reg_valid_o),
				.ready_i(mst_resps_i[0].w_ready),
				.data_o(sv2v_tmp_i_w_spill_reg_data_o)
			);
			wire [$bits(type(mst_reqs_o[0].b_ready)):1] sv2v_tmp_i_b_spill_reg_ready_o;
			always @(*) mst_reqs_o[0].b_ready = sv2v_tmp_i_b_spill_reg_ready_o;
			spill_register_F2424 #(.Bypass(~SpillB)) i_b_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_resps_i[0].b_valid),
				.ready_o(sv2v_tmp_i_b_spill_reg_ready_o),
				.data_i(mst_resps_i[0].b),
				.valid_o(slv_resp_o.b_valid),
				.ready_i(slv_req_i.b_ready),
				.data_o(slv_resp_o.b)
			);
			wire [$bits(type(mst_reqs_o[0].ar_valid)):1] sv2v_tmp_i_ar_spill_reg_valid_o;
			always @(*) mst_reqs_o[0].ar_valid = sv2v_tmp_i_ar_spill_reg_valid_o;
			wire [$bits(type(mst_reqs_o[0].ar)):1] sv2v_tmp_i_ar_spill_reg_data_o;
			always @(*) mst_reqs_o[0].ar = sv2v_tmp_i_ar_spill_reg_data_o;
			spill_register_F2424 #(.Bypass(~SpillAr)) i_ar_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.ar_valid),
				.ready_o(slv_resp_o.ar_ready),
				.data_i(slv_req_i.ar),
				.valid_o(sv2v_tmp_i_ar_spill_reg_valid_o),
				.ready_i(mst_resps_i[0].ar_ready),
				.data_o(sv2v_tmp_i_ar_spill_reg_data_o)
			);
			wire [$bits(type(mst_reqs_o[0].r_ready)):1] sv2v_tmp_i_r_spill_reg_ready_o;
			always @(*) mst_reqs_o[0].r_ready = sv2v_tmp_i_r_spill_reg_ready_o;
			spill_register_F2424 #(.Bypass(~SpillR)) i_r_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(mst_resps_i[0].r_valid),
				.ready_o(sv2v_tmp_i_r_spill_reg_ready_o),
				.data_i(mst_resps_i[0].r),
				.valid_o(slv_resp_o.r_valid),
				.ready_i(slv_req_i.r_ready),
				.data_o(slv_resp_o.r)
			);
		end
		else begin : gen_demux
			wire slv_aw_chan;
			wire [SelectWidth - 1:0] slv_aw_select;
			wire slv_aw_valid;
			wire slv_aw_valid_chan;
			wire slv_aw_valid_sel;
			reg slv_aw_ready;
			wire slv_aw_ready_chan;
			wire slv_aw_ready_sel;
			wire [SelectWidth - 1:0] lookup_aw_select;
			wire aw_select_occupied;
			wire aw_id_cnt_full;
			reg atop_inject;
			wire [SelectWidth - 1:0] w_select;
			reg [SelectWidth - 1:0] w_select_q;
			wire w_select_valid;
			wire [IdCounterWidth - 1:0] w_open;
			reg w_cnt_up;
			reg w_cnt_down;
			reg lock_aw_valid_d;
			reg lock_aw_valid_q;
			reg load_aw_lock;
			reg aw_valid;
			wire aw_ready;
			wire slv_w_chan;
			wire slv_w_valid;
			reg slv_w_ready;
			wire [NoMstPorts - 1:0] mst_b_chans;
			wire [NoMstPorts - 1:0] mst_b_valids;
			wire [NoMstPorts - 1:0] mst_b_readies;
			wire slv_b_chan;
			wire slv_b_valid;
			wire slv_b_ready;
			wire slv_ar_valid;
			wire ar_valid_chan;
			wire ar_valid_sel;
			reg slv_ar_ready;
			wire slv_ar_ready_chan;
			wire slv_ar_ready_sel;
			wire [SelectWidth - 1:0] lookup_ar_select;
			wire ar_select_occupied;
			wire ar_id_cnt_full;
			reg ar_push;
			reg lock_ar_valid_d;
			reg lock_ar_valid_q;
			reg load_ar_lock;
			reg ar_valid;
			wire ar_ready;
			wire [NoMstPorts - 1:0] mst_r_chans;
			wire [NoMstPorts - 1:0] mst_r_valids;
			wire [NoMstPorts - 1:0] mst_r_readies;
			wire slv_r_chan;
			wire slv_r_valid;
			wire slv_r_ready;
			spill_register_F2424 #(.Bypass(~SpillAw)) i_aw_channel_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.aw_valid),
				.ready_o(slv_aw_ready_chan),
				.data_i(slv_req_i.aw),
				.valid_o(slv_aw_valid_chan),
				.ready_i(slv_aw_ready),
				.data_o(slv_aw_chan)
			);
			spill_register_497C2_3F032 #(
				.T_SelectWidth(SelectWidth),
				.Bypass(~SpillAw)
			) i_aw_select_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.aw_valid),
				.ready_o(slv_aw_ready_sel),
				.data_i(slv_aw_select_i),
				.valid_o(slv_aw_valid_sel),
				.ready_i(slv_aw_ready),
				.data_o(slv_aw_select)
			);
			assign slv_resp_o.aw_ready = slv_aw_ready_chan & slv_aw_ready_sel;
			assign slv_aw_valid = slv_aw_valid_chan & slv_aw_valid_sel;
			always @(*) begin
				slv_aw_ready = 1'b0;
				aw_valid = 1'b0;
				lock_aw_valid_d = lock_aw_valid_q;
				load_aw_lock = 1'b0;
				w_cnt_up = 1'b0;
				atop_inject = 1'b0;
				if (lock_aw_valid_q) begin
					aw_valid = 1'b1;
					if (aw_ready) begin
						slv_aw_ready = 1'b1;
						lock_aw_valid_d = 1'b0;
						load_aw_lock = 1'b1;
						atop_inject = slv_aw_chan.atop[axi_pkg_ATOP_R_RESP] & AtopSupport;
					end
				end
				else if ((!aw_id_cnt_full && (w_open != {IdCounterWidth {1'b1}})) && (!(ar_id_cnt_full && slv_aw_chan.atop[axi_pkg_ATOP_R_RESP]) || !AtopSupport))
					if ((slv_aw_valid && ((w_open == {IdCounterWidth {1'sb0}}) || (w_select == slv_aw_select))) && (!aw_select_occupied || (slv_aw_select == lookup_aw_select))) begin
						aw_valid = 1'b1;
						w_cnt_up = 1'b1;
						if (aw_ready) begin
							slv_aw_ready = 1'b1;
							atop_inject = slv_aw_chan.atop[axi_pkg_ATOP_R_RESP] & AtopSupport;
						end
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
			if (UniqueIds) begin : gen_unique_ids_aw
				assign lookup_aw_select = slv_aw_select;
				assign aw_select_occupied = 1'b0;
				assign aw_id_cnt_full = 1'b0;
			end
			else begin : gen_aw_id_counter
				localparam [31:0] sv2v_uu_i_aw_id_counter_AxiIdBits = AxiLookBits;
				localparam [sv2v_uu_i_aw_id_counter_AxiIdBits - 1:0] sv2v_uu_i_aw_id_counter_ext_inject_axi_id_i_0 = 1'sb0;
				axi_demux_id_counters_62B1B_828D5 #(
					.mst_port_select_t_SelectWidth(SelectWidth),
					.AxiIdBits(AxiLookBits),
					.CounterWidth(IdCounterWidth)
				) i_aw_id_counter(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.lookup_axi_id_i(slv_aw_chan.id[0+:AxiLookBits]),
					.lookup_mst_select_o(lookup_aw_select),
					.lookup_mst_select_occupied_o(aw_select_occupied),
					.full_o(aw_id_cnt_full),
					.inject_axi_id_i(sv2v_uu_i_aw_id_counter_ext_inject_axi_id_i_0),
					.inject_i(1'b0),
					.push_axi_id_i(slv_aw_chan.id[0+:AxiLookBits]),
					.push_mst_select_i(slv_aw_select),
					.push_i(w_cnt_up),
					.pop_axi_id_i(slv_b_chan.id[0+:AxiLookBits]),
					.pop_i(slv_b_valid & slv_b_ready)
				);
			end
			counter #(
				.WIDTH(IdCounterWidth),
				.STICKY_OVERFLOW(1'b0)
			) i_counter_open_w(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.clear_i(1'b0),
				.en_i(w_cnt_up ^ w_cnt_down),
				.load_i(1'b0),
				.down_i(w_cnt_down),
				.d_i(1'sb0),
				.q_o(w_open),
				.overflow_o()
			);
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					w_select_q <= sv2v_cast_4FC3B(0);
				else if (w_cnt_up)
					w_select_q <= slv_aw_select;
			assign w_select = (|w_open ? w_select_q : slv_aw_select);
			assign w_select_valid = w_cnt_up | |w_open;
			spill_register_F2424 #(.Bypass(~SpillW)) i_w_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.w_valid),
				.ready_o(slv_resp_o.w_ready),
				.data_i(slv_req_i.w),
				.valid_o(slv_w_valid),
				.ready_i(slv_w_ready),
				.data_o(slv_w_chan)
			);
			spill_register_F2424 #(.Bypass(~SpillB)) i_b_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_b_valid),
				.ready_o(slv_b_ready),
				.data_i(slv_b_chan),
				.valid_o(slv_resp_o.b_valid),
				.ready_i(slv_req_i.b_ready),
				.data_o(slv_resp_o.b)
			);
			localparam [31:0] sv2v_uu_i_b_mux_NumIn = NoMstPorts;
			localparam [31:0] sv2v_uu_i_b_mux_IdxWidth = (sv2v_uu_i_b_mux_NumIn > 32'd1 ? $unsigned($clog2(sv2v_uu_i_b_mux_NumIn)) : 32'd1);
			localparam [sv2v_uu_i_b_mux_IdxWidth - 1:0] sv2v_uu_i_b_mux_ext_rr_i_0 = 1'sb0;
			rr_arb_tree_25AF9 #(
				.NumIn(NoMstPorts),
				.AxiVldRdy(1'b1),
				.LockIn(1'b1)
			) i_b_mux(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(1'b0),
				.rr_i(sv2v_uu_i_b_mux_ext_rr_i_0),
				.req_i(mst_b_valids),
				.gnt_o(mst_b_readies),
				.data_i(mst_b_chans),
				.gnt_i(slv_b_ready),
				.req_o(slv_b_valid),
				.data_o(slv_b_chan)
			);
			wire slv_ar_chan;
			wire [SelectWidth - 1:0] slv_ar_select;
			spill_register_F2424 #(.Bypass(~SpillAr)) i_ar_chan_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.ar_valid),
				.ready_o(slv_ar_ready_chan),
				.data_i(slv_req_i.ar),
				.valid_o(ar_valid_chan),
				.ready_i(slv_ar_ready),
				.data_o(slv_ar_chan)
			);
			spill_register_497C2_3F032 #(
				.T_SelectWidth(SelectWidth),
				.Bypass(~SpillAr)
			) i_ar_sel_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_req_i.ar_valid),
				.ready_o(slv_ar_ready_sel),
				.data_i(slv_ar_select_i),
				.valid_o(ar_valid_sel),
				.ready_i(slv_ar_ready),
				.data_o(slv_ar_select)
			);
			assign slv_resp_o.ar_ready = slv_ar_ready_chan & slv_ar_ready_sel;
			assign slv_ar_valid = ar_valid_chan & ar_valid_sel;
			always @(*) begin
				slv_ar_ready = 1'b0;
				ar_valid = 1'b0;
				lock_ar_valid_d = lock_ar_valid_q;
				load_ar_lock = 1'b0;
				ar_push = 1'b0;
				if (lock_ar_valid_q) begin
					ar_valid = 1'b1;
					if (ar_ready) begin
						slv_ar_ready = 1'b1;
						ar_push = 1'b1;
						lock_ar_valid_d = 1'b0;
						load_ar_lock = 1'b1;
					end
				end
				else if (!ar_id_cnt_full)
					if (slv_ar_valid && (!ar_select_occupied || (slv_ar_select == lookup_ar_select))) begin
						ar_valid = 1'b1;
						if (ar_ready) begin
							slv_ar_ready = 1'b1;
							ar_push = 1'b1;
						end
						else begin
							lock_ar_valid_d = 1'b1;
							load_ar_lock = 1'b1;
						end
					end
			end
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					lock_ar_valid_q <= 1'sb0;
				else if (load_ar_lock)
					lock_ar_valid_q <= lock_ar_valid_d;
			if (UniqueIds) begin : gen_unique_ids_ar
				assign lookup_ar_select = slv_ar_select;
				assign ar_select_occupied = 1'b0;
				assign ar_id_cnt_full = 1'b0;
			end
			else begin : gen_ar_id_counter
				axi_demux_id_counters_62B1B_828D5 #(
					.mst_port_select_t_SelectWidth(SelectWidth),
					.AxiIdBits(AxiLookBits),
					.CounterWidth(IdCounterWidth)
				) i_ar_id_counter(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.lookup_axi_id_i(slv_ar_chan.id[0+:AxiLookBits]),
					.lookup_mst_select_o(lookup_ar_select),
					.lookup_mst_select_occupied_o(ar_select_occupied),
					.full_o(ar_id_cnt_full),
					.inject_axi_id_i(slv_aw_chan.id[0+:AxiLookBits]),
					.inject_i(atop_inject),
					.push_axi_id_i(slv_ar_chan.id[0+:AxiLookBits]),
					.push_mst_select_i(slv_ar_select),
					.push_i(ar_push),
					.pop_axi_id_i(slv_r_chan.id[0+:AxiLookBits]),
					.pop_i((slv_r_valid & slv_r_ready) & slv_r_chan.last)
				);
			end
			spill_register_F2424 #(.Bypass(~SpillR)) i_r_spill_reg(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.valid_i(slv_r_valid),
				.ready_o(slv_r_ready),
				.data_i(slv_r_chan),
				.valid_o(slv_resp_o.r_valid),
				.ready_i(slv_req_i.r_ready),
				.data_o(slv_resp_o.r)
			);
			localparam [31:0] sv2v_uu_i_r_mux_NumIn = NoMstPorts;
			localparam [31:0] sv2v_uu_i_r_mux_IdxWidth = (sv2v_uu_i_r_mux_NumIn > 32'd1 ? $unsigned($clog2(sv2v_uu_i_r_mux_NumIn)) : 32'd1);
			localparam [sv2v_uu_i_r_mux_IdxWidth - 1:0] sv2v_uu_i_r_mux_ext_rr_i_0 = 1'sb0;
			rr_arb_tree_25AF9 #(
				.NumIn(NoMstPorts),
				.AxiVldRdy(1'b1),
				.LockIn(1'b1)
			) i_r_mux(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.flush_i(1'b0),
				.rr_i(sv2v_uu_i_r_mux_ext_rr_i_0),
				.req_i(mst_r_valids),
				.gnt_o(mst_r_readies),
				.data_i(mst_r_chans),
				.gnt_i(slv_r_ready),
				.req_o(slv_r_valid),
				.data_o(slv_r_chan)
			);
			assign ar_ready = ar_valid & mst_resps_i[slv_ar_select].ar_ready;
			assign aw_ready = aw_valid & mst_resps_i[slv_aw_select].aw_ready;
			always @(*) begin
				mst_reqs_o = 1'sb0;
				slv_w_ready = 1'b0;
				w_cnt_down = 1'b0;
				begin : sv2v_autoblock_1
					reg [31:0] i;
					for (i = 0; i < NoMstPorts; i = i + 1)
						begin
							mst_reqs_o[i].aw = slv_aw_chan;
							mst_reqs_o[i].aw_valid = 1'b0;
							if (aw_valid && (slv_aw_select == i))
								mst_reqs_o[i].aw_valid = 1'b1;
							mst_reqs_o[i].w = slv_w_chan;
							mst_reqs_o[i].w_valid = 1'b0;
							if (w_select_valid && (w_select == i)) begin
								mst_reqs_o[i].w_valid = slv_w_valid;
								slv_w_ready = mst_resps_i[i].w_ready;
								w_cnt_down = (slv_w_valid & mst_resps_i[i].w_ready) & slv_w_chan.last;
							end
							mst_reqs_o[i].b_ready = mst_b_readies[i];
							mst_reqs_o[i].ar = slv_ar_chan;
							mst_reqs_o[i].ar_valid = 1'b0;
							if (ar_valid && (slv_ar_select == i))
								mst_reqs_o[i].ar_valid = 1'b1;
							mst_reqs_o[i].r_ready = mst_r_readies[i];
						end
				end
			end
			genvar i;
			for (i = 0; i < NoMstPorts; i = i + 1) begin : gen_b_channels
				assign mst_b_chans[i] = mst_resps_i[i].b;
				assign mst_b_valids[i] = mst_resps_i[i].b_valid;
				assign mst_r_chans[i] = mst_resps_i[i].r;
				assign mst_r_valids[i] = mst_resps_i[i].r_valid;
			end
		end
	endgenerate
endmodule
module axi_demux_id_counters_62B1B_828D5 (
	clk_i,
	rst_ni,
	lookup_axi_id_i,
	lookup_mst_select_o,
	lookup_mst_select_occupied_o,
	full_o,
	push_axi_id_i,
	push_mst_select_i,
	push_i,
	inject_axi_id_i,
	inject_i,
	pop_axi_id_i,
	pop_i
);
	parameter [31:0] mst_port_select_t_SelectWidth = 0;
	parameter [31:0] AxiIdBits = 2;
	parameter [31:0] CounterWidth = 4;
	input clk_i;
	input rst_ni;
	input wire [AxiIdBits - 1:0] lookup_axi_id_i;
	output wire [mst_port_select_t_SelectWidth - 1:0] lookup_mst_select_o;
	output wire lookup_mst_select_occupied_o;
	output wire full_o;
	input wire [AxiIdBits - 1:0] push_axi_id_i;
	input wire [mst_port_select_t_SelectWidth - 1:0] push_mst_select_i;
	input wire push_i;
	input wire [AxiIdBits - 1:0] inject_axi_id_i;
	input wire inject_i;
	input wire [AxiIdBits - 1:0] pop_axi_id_i;
	input wire pop_i;
	localparam [31:0] NoCounters = 2 ** AxiIdBits;
	reg [(NoCounters * mst_port_select_t_SelectWidth) - 1:0] mst_select_q;
	wire [NoCounters - 1:0] push_en;
	wire [NoCounters - 1:0] inject_en;
	wire [NoCounters - 1:0] pop_en;
	wire [NoCounters - 1:0] occupied;
	wire [NoCounters - 1:0] cnt_full;
	assign lookup_mst_select_o = mst_select_q[lookup_axi_id_i * mst_port_select_t_SelectWidth+:mst_port_select_t_SelectWidth];
	assign lookup_mst_select_occupied_o = occupied[lookup_axi_id_i];
	assign push_en = (push_i ? 1 << push_axi_id_i : {NoCounters {1'sb0}});
	assign inject_en = (inject_i ? 1 << inject_axi_id_i : {NoCounters {1'sb0}});
	assign pop_en = (pop_i ? 1 << pop_axi_id_i : {NoCounters {1'sb0}});
	assign full_o = |cnt_full;
	genvar i;
	function automatic [CounterWidth - 1:0] sv2v_cast_6B650;
		input reg [CounterWidth - 1:0] inp;
		sv2v_cast_6B650 = inp;
	endfunction
	generate
		for (i = 0; i < NoCounters; i = i + 1) begin : gen_counters
			reg cnt_en;
			reg cnt_down;
			wire overflow;
			reg [CounterWidth - 1:0] cnt_delta;
			wire [CounterWidth - 1:0] in_flight;
			always @(*)
				case ({push_en[i], inject_en[i], pop_en[i]})
					3'b001: begin
						cnt_en = 1'b1;
						cnt_down = 1'b1;
						cnt_delta = sv2v_cast_6B650(1);
					end
					3'b010: begin
						cnt_en = 1'b1;
						cnt_down = 1'b0;
						cnt_delta = sv2v_cast_6B650(1);
					end
					3'b100: begin
						cnt_en = 1'b1;
						cnt_down = 1'b0;
						cnt_delta = sv2v_cast_6B650(1);
					end
					3'b110: begin
						cnt_en = 1'b1;
						cnt_down = 1'b0;
						cnt_delta = sv2v_cast_6B650(2);
					end
					3'b111: begin
						cnt_en = 1'b1;
						cnt_down = 1'b0;
						cnt_delta = sv2v_cast_6B650(1);
					end
					default: begin
						cnt_en = 1'b0;
						cnt_down = 1'b0;
						cnt_delta = sv2v_cast_6B650(0);
					end
				endcase
			delta_counter #(
				.WIDTH(CounterWidth),
				.STICKY_OVERFLOW(1'b0)
			) i_in_flight_cnt(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.clear_i(1'b0),
				.en_i(cnt_en),
				.load_i(1'b0),
				.down_i(cnt_down),
				.delta_i(cnt_delta),
				.d_i(1'sb0),
				.q_o(in_flight),
				.overflow_o(overflow)
			);
			assign occupied[i] = |in_flight;
			assign cnt_full[i] = overflow | &in_flight;
			always @(posedge clk_i or negedge rst_ni)
				if (!rst_ni)
					mst_select_q[i * mst_port_select_t_SelectWidth+:mst_port_select_t_SelectWidth] <= 1'sb0;
				else if (push_en[i])
					mst_select_q[i * mst_port_select_t_SelectWidth+:mst_port_select_t_SelectWidth] <= push_mst_select_i;
		end
	endgenerate
endmodule
