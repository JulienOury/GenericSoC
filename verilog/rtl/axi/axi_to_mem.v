module axi_to_mem (
	clk_i,
	rst_ni,
	busy_o,
	axi_req_i,
	axi_resp_o,
	mem_req_o,
	mem_gnt_i,
	mem_addr_o,
	mem_wdata_o,
	mem_strb_o,
	mem_atop_o,
	mem_we_o,
	mem_rvalid_i,
	mem_rdata_i
);
	parameter [31:0] AddrWidth = 0;
	parameter [31:0] DataWidth = 0;
	parameter [31:0] IdWidth = 0;
	parameter [31:0] NumBanks = 0;
	parameter [31:0] BufDepth = 1;
	parameter [0:0] HideStrb = 1'b0;
	parameter [31:0] OutFifoDepth = 1;
	input wire clk_i;
	input wire rst_ni;
	output wire busy_o;
	input wire axi_req_i;
	output reg axi_resp_o;
	output wire [NumBanks - 1:0] mem_req_o;
	input wire [NumBanks - 1:0] mem_gnt_i;
	output wire [(NumBanks * AddrWidth) - 1:0] mem_addr_o;
	output wire [(NumBanks * (DataWidth / NumBanks)) - 1:0] mem_wdata_o;
	output wire [(NumBanks * ((DataWidth / NumBanks) / 8)) - 1:0] mem_strb_o;
	localparam [31:0] axi_pkg_AtopWidth = 32'd6;
	output wire [(NumBanks * axi_pkg_AtopWidth) - 1:0] mem_atop_o;
	output wire [NumBanks - 1:0] mem_we_o;
	input wire [NumBanks - 1:0] mem_rvalid_i;
	input wire [(NumBanks * (DataWidth / NumBanks)) - 1:0] mem_rdata_i;
	localparam [31:0] axi_pkg_QosWidth = 32'd4;
	localparam [31:0] axi_pkg_SizeWidth = 32'd3;
	wire [DataWidth - 1:0] mem_rdata;
	wire [DataWidth - 1:0] m2s_resp;
	localparam [31:0] axi_pkg_LenWidth = 32'd8;
	reg [7:0] r_cnt_d;
	reg [7:0] r_cnt_q;
	reg [7:0] w_cnt_d;
	reg [7:0] w_cnt_q;
	wire arb_valid;
	wire arb_ready;
	reg rd_valid;
	wire rd_ready;
	reg wr_valid;
	wire wr_ready;
	wire sel_b;
	wire sel_buf_b;
	wire sel_r;
	wire sel_buf_r;
	wire sel_valid;
	wire sel_ready;
	wire sel_buf_valid;
	wire sel_buf_ready;
	reg sel_lock_d;
	reg sel_lock_q;
	wire meta_valid;
	wire meta_ready;
	wire meta_buf_valid;
	wire meta_buf_ready;
	reg meta_sel_d;
	reg meta_sel_q;
	wire m2s_req_valid;
	wire m2s_req_ready;
	wire m2s_resp_valid;
	wire m2s_resp_ready;
	wire mem_req_valid;
	wire mem_req_ready;
	wire mem_rvalid;
	wire [(((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 0:0] m2s_req;
	wire [(((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 0:0] mem_req;
	reg [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] rd_meta;
	reg [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] rd_meta_d;
	reg [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] rd_meta_q;
	reg [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] wr_meta;
	reg [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] wr_meta_d;
	reg [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] wr_meta_q;
	wire [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] meta;
	wire [(((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0:0] meta_buf;
	assign busy_o = (((((axi_req_i.aw_valid | axi_req_i.ar_valid) | axi_req_i.w_valid) | axi_resp_o.b_valid) | axi_resp_o.r_valid) | (r_cnt_q > 0)) | (w_cnt_q > 0);
	function automatic [127:0] axi_pkg_aligned_addr;
		input reg [127:0] addr;
		input reg [2:0] size;
		axi_pkg_aligned_addr = (addr >> size) << size;
	endfunction
	function automatic [15:0] axi_pkg_num_bytes;
		input reg [2:0] size;
		axi_pkg_num_bytes = 1 << size;
	endfunction
	function automatic [AddrWidth - 1:0] sv2v_cast_F41A1;
		input reg [AddrWidth - 1:0] inp;
		sv2v_cast_F41A1 = inp;
	endfunction
	function automatic [5:0] sv2v_cast_62BA0;
		input reg [5:0] inp;
		sv2v_cast_62BA0 = inp;
	endfunction
	function automatic [IdWidth - 1:0] sv2v_cast_C3AB5;
		input reg [IdWidth - 1:0] inp;
		sv2v_cast_C3AB5 = inp;
	endfunction
	function automatic [3:0] sv2v_cast_6E6B6;
		input reg [3:0] inp;
		sv2v_cast_6E6B6 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_7FEA9;
		input reg [2:0] inp;
		sv2v_cast_7FEA9 = inp;
	endfunction
	function automatic [((((AddrWidth + 32'd6) + IdWidth) + 8) >= 0 ? (((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 1 : 1 - ((((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0)) - 1:0] sv2v_cast_31BA3;
		input reg [((((AddrWidth + 32'd6) + IdWidth) + 8) >= 0 ? (((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 1 : 1 - ((((((AddrWidth + axi_pkg_AtopWidth) + IdWidth) + 1) + axi_pkg_QosWidth) + axi_pkg_SizeWidth) + 0)) - 1:0] inp;
		sv2v_cast_31BA3 = inp;
	endfunction
	function automatic [AddrWidth - 1:0] sv2v_cast_86DB8;
		input reg [AddrWidth - 1:0] inp;
		sv2v_cast_86DB8 = inp;
	endfunction
	function automatic [IdWidth - 1:0] sv2v_cast_809CC;
		input reg [IdWidth - 1:0] inp;
		sv2v_cast_809CC = inp;
	endfunction
	function automatic [3:0] sv2v_cast_A1051;
		input reg [3:0] inp;
		sv2v_cast_A1051 = inp;
	endfunction
	function automatic [2:0] sv2v_cast_004D0;
		input reg [2:0] inp;
		sv2v_cast_004D0 = inp;
	endfunction
	always @(*) begin
		axi_resp_o.ar_ready = 1'b0;
		rd_meta_d = rd_meta_q;
		rd_meta = sv2v_cast_31BA3({sv2v_cast_F41A1(1'sb0), sv2v_cast_62BA0(1'sb0), sv2v_cast_C3AB5(1'sb0), 1'b0, sv2v_cast_6E6B6(1'sb0), sv2v_cast_7FEA9(1'sb0), 1'b0});
		rd_valid = 1'b0;
		r_cnt_d = r_cnt_q;
		if (r_cnt_q > {8 {1'sb0}}) begin
			rd_meta_d[8] = r_cnt_q == 8'd1;
			rd_meta = rd_meta_d;
			rd_meta[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] = rd_meta_q[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] + axi_pkg_num_bytes(rd_meta_q[3-:3]);
			rd_valid = 1'b1;
			if (rd_ready) begin
				r_cnt_d = r_cnt_d - 1;
				rd_meta_d[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] = rd_meta[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)];
			end
		end
		else if (axi_req_i.ar_valid) begin
			rd_meta_d = {sv2v_cast_86DB8(axi_pkg_aligned_addr(axi_req_i.ar.addr, axi_req_i.ar.size)), sv2v_cast_62BA0(1'sb0), sv2v_cast_809CC(axi_req_i.ar.id), axi_req_i.ar.len == 1'b0, sv2v_cast_A1051(axi_req_i.ar.qos), sv2v_cast_004D0(axi_req_i.ar.size), 1'b0};
			rd_meta = rd_meta_d;
			rd_meta[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] = sv2v_cast_86DB8(axi_req_i.ar.addr);
			rd_valid = 1'b1;
			if (rd_ready) begin
				r_cnt_d = axi_req_i.ar.len;
				axi_resp_o.ar_ready = 1'b1;
			end
		end
	end
	function automatic [5:0] sv2v_cast_27381;
		input reg [5:0] inp;
		sv2v_cast_27381 = inp;
	endfunction
	always @(*) begin
		axi_resp_o.aw_ready = 1'b0;
		axi_resp_o.w_ready = 1'b0;
		wr_meta_d = wr_meta_q;
		wr_meta = sv2v_cast_31BA3({sv2v_cast_F41A1(1'sb0), sv2v_cast_62BA0(1'sb0), sv2v_cast_C3AB5(1'sb0), 1'b0, sv2v_cast_6E6B6(1'sb0), sv2v_cast_7FEA9(1'sb0), 1'b0});
		wr_valid = 1'b0;
		w_cnt_d = w_cnt_q;
		if (w_cnt_q > {8 {1'sb0}}) begin
			wr_meta_d[8] = w_cnt_q == 8'd1;
			wr_meta = wr_meta_d;
			wr_meta[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] = wr_meta_q[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] + axi_pkg_num_bytes(wr_meta_q[3-:3]);
			if (axi_req_i.w_valid) begin
				wr_valid = 1'b1;
				if (wr_ready) begin
					axi_resp_o.w_ready = 1'b1;
					w_cnt_d = w_cnt_d - 1;
					wr_meta_d[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] = wr_meta[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)];
				end
			end
		end
		else if (axi_req_i.aw_valid && axi_req_i.w_valid) begin
			wr_meta_d = {sv2v_cast_86DB8(axi_pkg_aligned_addr(axi_req_i.aw.addr, axi_req_i.aw.size)), sv2v_cast_27381(axi_req_i.aw.atop), sv2v_cast_809CC(axi_req_i.aw.id), axi_req_i.aw.len == 1'b0, sv2v_cast_A1051(axi_req_i.aw.qos), sv2v_cast_004D0(axi_req_i.aw.size), 1'b1};
			wr_meta = wr_meta_d;
			wr_meta[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)] = sv2v_cast_86DB8(axi_req_i.aw.addr);
			wr_valid = 1'b1;
			if (wr_ready) begin
				w_cnt_d = axi_req_i.aw.len;
				axi_resp_o.aw_ready = 1'b1;
				axi_resp_o.w_ready = 1'b1;
			end
		end
	end
	stream_mux_9AE06_1B052 #(
		.DATA_T_AddrWidth(AddrWidth),
		.DATA_T_IdWidth(IdWidth),
		.DATA_T_axi_pkg_AtopWidth(axi_pkg_AtopWidth),
		.DATA_T_axi_pkg_QosWidth(axi_pkg_QosWidth),
		.DATA_T_axi_pkg_SizeWidth(axi_pkg_SizeWidth),
		.N_INP(32'd2)
	) i_ax_mux(
		.inp_data_i({wr_meta, rd_meta}),
		.inp_valid_i({wr_valid, rd_valid}),
		.inp_ready_o({wr_ready, rd_ready}),
		.inp_sel_i(meta_sel_d),
		.oup_data_o(meta),
		.oup_valid_o(arb_valid),
		.oup_ready_i(arb_ready)
	);
	always @(*) begin
		meta_sel_d = meta_sel_q;
		sel_lock_d = sel_lock_q;
		if (sel_lock_q) begin
			meta_sel_d = meta_sel_q;
			if (arb_valid && arb_ready)
				sel_lock_d = 1'b0;
		end
		else begin
			if (wr_valid ^ rd_valid)
				meta_sel_d = wr_valid;
			else if (wr_valid && rd_valid)
				if (wr_meta[7-:4] > rd_meta[7-:4])
					meta_sel_d = 1'b1;
				else if (rd_meta[7-:4] > wr_meta[7-:4])
					meta_sel_d = 1'b0;
				else if (wr_meta[7-:4] == rd_meta[7-:4])
					if (wr_meta[8] && !rd_meta[8])
						meta_sel_d = 1'b1;
					else if (w_cnt_q > {8 {1'sb0}})
						meta_sel_d = 1'b1;
					else if (r_cnt_q > {8 {1'sb0}})
						meta_sel_d = 1'b0;
					else
						meta_sel_d = ~meta_sel_q;
			if (arb_valid && !arb_ready)
				sel_lock_d = 1'b1;
		end
	end
	stream_fork #(.N_OUP(32'd3)) i_fork(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(arb_valid),
		.ready_o(arb_ready),
		.valid_o({sel_valid, meta_valid, m2s_req_valid}),
		.ready_i({sel_ready, meta_ready, m2s_req_ready})
	);
	assign sel_b = meta[0] & meta[8];
	assign sel_r = ~meta[0] | meta[axi_pkg_AtopWidth + (IdWidth + 8)];
	stream_fifo_11687 #(
		.FALL_THROUGH(1'b1),
		.DEPTH(32'd1 + BufDepth)
	) i_sel_buf(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'b0),
		.testmode_i(1'b0),
		.data_i({sel_b, sel_r}),
		.valid_i(sel_valid),
		.ready_o(sel_ready),
		.data_o({sel_buf_b, sel_buf_r}),
		.valid_o(sel_buf_valid),
		.ready_i(sel_buf_ready),
		.usage_o()
	);
	stream_fifo_7C663_CFFCF #(
		.T_AddrWidth(AddrWidth),
		.T_IdWidth(IdWidth),
		.T_axi_pkg_AtopWidth(axi_pkg_AtopWidth),
		.T_axi_pkg_QosWidth(axi_pkg_QosWidth),
		.T_axi_pkg_SizeWidth(axi_pkg_SizeWidth),
		.FALL_THROUGH(1'b1),
		.DEPTH(32'd1 + BufDepth)
	) i_meta_buf(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.flush_i(1'b0),
		.testmode_i(1'b0),
		.data_i(meta),
		.valid_i(meta_valid),
		.ready_o(meta_ready),
		.data_o(meta_buf),
		.valid_o(meta_buf_valid),
		.ready_i(meta_buf_ready),
		.usage_o()
	);
	function automatic [(DataWidth / 8) - 1:0] sv2v_cast_79510;
		input reg [(DataWidth / 8) - 1:0] inp;
		sv2v_cast_79510 = inp;
	endfunction
	function automatic [DataWidth - 1:0] sv2v_cast_4AF59;
		input reg [DataWidth - 1:0] inp;
		sv2v_cast_4AF59 = inp;
	endfunction
	function automatic [(((((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 0) >= 0 ? (((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 1 : 1 - ((((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 0)) - 1:0] sv2v_cast_9AC1C;
		input reg [(((((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 0) >= 0 ? (((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 1 : 1 - ((((AddrWidth + axi_pkg_AtopWidth) + (DataWidth / 8)) + DataWidth) + 0)) - 1:0] inp;
		sv2v_cast_9AC1C = inp;
	endfunction
	assign m2s_req = sv2v_cast_9AC1C({sv2v_cast_86DB8(meta[AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))-:((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) >= (axi_pkg_AtopWidth + (IdWidth + 9)) ? ((AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8))) - (axi_pkg_AtopWidth + (IdWidth + 9))) + 1 : ((axi_pkg_AtopWidth + (IdWidth + 9)) - (AddrWidth + (axi_pkg_AtopWidth + (IdWidth + 8)))) + 1)]), sv2v_cast_27381(meta[axi_pkg_AtopWidth + (IdWidth + 8)-:((axi_pkg_AtopWidth + (IdWidth + 8)) >= (IdWidth + 9) ? ((axi_pkg_AtopWidth + (IdWidth + 8)) - (IdWidth + 9)) + 1 : ((IdWidth + 9) - (axi_pkg_AtopWidth + (IdWidth + 8))) + 1)]), sv2v_cast_79510(axi_req_i.w.strb), sv2v_cast_4AF59(axi_req_i.w.data), meta[0]});
	stream_to_mem_0A6AF_F414E #(
		.mem_req_t_AddrWidth(AddrWidth),
		.mem_req_t_DataWidth(DataWidth),
		.mem_req_t_axi_pkg_AtopWidth(axi_pkg_AtopWidth),
		.mem_resp_t_DataWidth(DataWidth),
		.BufDepth(BufDepth)
	) i_stream_to_mem(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(m2s_req),
		.req_valid_i(m2s_req_valid),
		.req_ready_o(m2s_req_ready),
		.resp_o(m2s_resp),
		.resp_valid_o(m2s_resp_valid),
		.resp_ready_i(m2s_resp_ready),
		.mem_req_o(mem_req),
		.mem_req_valid_o(mem_req_valid),
		.mem_req_ready_i(mem_req_ready),
		.mem_resp_i(mem_rdata),
		.mem_resp_valid_i(mem_rvalid)
	);
	mem_to_banks_9C261_D0161 #(
		.atop_t_axi_pkg_AtopWidth(axi_pkg_AtopWidth),
		.AddrWidth(AddrWidth),
		.DataWidth(DataWidth),
		.NumBanks(NumBanks),
		.HideStrb(HideStrb),
		.MaxTrans(BufDepth),
		.FifoDepth(OutFifoDepth)
	) i_mem_to_banks(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.req_i(mem_req_valid),
		.gnt_o(mem_req_ready),
		.addr_i(mem_req[AddrWidth + (axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0)))-:((AddrWidth + (axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0)))) >= (axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 1))) ? ((AddrWidth + (axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0)))) - (axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 1)))) + 1 : ((axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 1))) - (AddrWidth + (axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0))))) + 1)]),
		.wdata_i(mem_req[DataWidth + 0-:((DataWidth + 0) >= 1 ? DataWidth + 0 : 2 - (DataWidth + 0))]),
		.strb_i(mem_req[(DataWidth / 8) + (DataWidth + 0)-:(((DataWidth / 8) + (DataWidth + 0)) >= (DataWidth + 1) ? (((DataWidth / 8) + (DataWidth + 0)) - (DataWidth + 1)) + 1 : ((DataWidth + 1) - ((DataWidth / 8) + (DataWidth + 0))) + 1)]),
		.atop_i(mem_req[axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0))-:((axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0))) >= ((DataWidth / 8) + (DataWidth + 1)) ? ((axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0))) - ((DataWidth / 8) + (DataWidth + 1))) + 1 : (((DataWidth / 8) + (DataWidth + 1)) - (axi_pkg_AtopWidth + ((DataWidth / 8) + (DataWidth + 0)))) + 1)]),
		.we_i(mem_req[0]),
		.rvalid_o(mem_rvalid),
		.rdata_o(mem_rdata),
		.bank_req_o(mem_req_o),
		.bank_gnt_i(mem_gnt_i),
		.bank_addr_o(mem_addr_o),
		.bank_wdata_o(mem_wdata_o),
		.bank_strb_o(mem_strb_o),
		.bank_atop_o(mem_atop_o),
		.bank_we_o(mem_we_o),
		.bank_rvalid_i(mem_rvalid_i),
		.bank_rdata_i(mem_rdata_i)
	);
	wire mem_join_valid;
	wire mem_join_ready;
	stream_join #(.N_INP(32'd2)) i_join(
		.inp_valid_i({m2s_resp_valid, meta_buf_valid}),
		.inp_ready_o({m2s_resp_ready, meta_buf_ready}),
		.oup_valid_o(mem_join_valid),
		.oup_ready_i(mem_join_ready)
	);
	stream_fork_dynamic #(.N_OUP(32'd2)) i_fork_dynamic(
		.clk_i(clk_i),
		.rst_ni(rst_ni),
		.valid_i(mem_join_valid),
		.ready_o(mem_join_ready),
		.sel_i({sel_buf_b, sel_buf_r}),
		.sel_valid_i(sel_buf_valid),
		.sel_ready_o(sel_buf_ready),
		.valid_o({axi_resp_o.b_valid, axi_resp_o.r_valid}),
		.ready_i({axi_req_i.b_ready, axi_req_i.r_ready})
	);
	localparam axi_pkg_RESP_OKAY = 2'b00;
	always @(*) axi_resp_o.b = '{
		id: meta_buf[IdWidth + 8-:((IdWidth + 8) >= 9 ? IdWidth : 10 - (IdWidth + 8))],
		resp: axi_pkg_RESP_OKAY,
		user: 1'sb0
	};
	wire [$bits(type(axi_resp_o.r)):1] sv2v_tmp_CEFEC;
	assign sv2v_tmp_CEFEC = '{
		data: m2s_resp,
		id: meta_buf[IdWidth + 8-:((IdWidth + 8) >= 9 ? IdWidth : 10 - (IdWidth + 8))],
		last: meta_buf[8],
		resp: axi_pkg_RESP_OKAY,
		user: 1'sb0
	};
	always @(*) axi_resp_o.r = sv2v_tmp_CEFEC;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			meta_sel_q <= 1'b0;
		else
			meta_sel_q <= meta_sel_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			sel_lock_q <= 1'b0;
		else
			sel_lock_q <= sel_lock_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			rd_meta_q <= sv2v_cast_31BA3({sv2v_cast_F41A1(1'sb0), sv2v_cast_62BA0(1'sb0), sv2v_cast_C3AB5(1'sb0), 1'b0, sv2v_cast_6E6B6(1'sb0), sv2v_cast_7FEA9(1'sb0), 1'b0});
		else
			rd_meta_q <= rd_meta_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			wr_meta_q <= sv2v_cast_31BA3({sv2v_cast_F41A1(1'sb0), sv2v_cast_62BA0(1'sb0), sv2v_cast_C3AB5(1'sb0), 1'b0, sv2v_cast_6E6B6(1'sb0), sv2v_cast_7FEA9(1'sb0), 1'b0});
		else
			wr_meta_q <= wr_meta_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			r_cnt_q <= 1'sb0;
		else
			r_cnt_q <= r_cnt_d;
	always @(posedge clk_i or negedge rst_ni)
		if (!rst_ni)
			w_cnt_q <= 1'sb0;
		else
			w_cnt_q <= w_cnt_d;
endmodule
