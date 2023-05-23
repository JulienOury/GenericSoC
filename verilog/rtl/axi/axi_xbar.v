module axi_xbar (
	clk_i,
	rst_ni,
	test_i,
	slv_ports_req_i,
	slv_ports_resp_o,
	mst_ports_req_o,
	mst_ports_resp_i,
	addr_map_i,
	en_default_mst_port_i,
	default_mst_port_i
);
	localparam [9:0] axi_pkg_DemuxAr = 64;
	localparam [9:0] axi_pkg_DemuxAw = 512;
	localparam [9:0] axi_pkg_DemuxB = 128;
	localparam [9:0] axi_pkg_DemuxR = 32;
	localparam [9:0] axi_pkg_DemuxW = 256;
	localparam [9:0] axi_pkg_MuxAr = 2;
	localparam [9:0] axi_pkg_MuxAw = 16;
	localparam [9:0] axi_pkg_MuxB = 4;
	localparam [9:0] axi_pkg_MuxR = 1;
	localparam [9:0] axi_pkg_MuxW = 8;
	parameter [331:0] Cfg = 1'sb0;
	parameter [0:0] ATOPs = 1'b1;
	parameter [(Cfg[331-:32] * Cfg[299-:32]) - 1:0] Connectivity = 1'sb1;
	input wire clk_i;
	input wire rst_ni;
	input wire test_i;
	input wire [Cfg[331-:32] - 1:0] slv_ports_req_i;
	output wire [Cfg[331-:32] - 1:0] slv_ports_resp_o;
	output wire [Cfg[299-:32] - 1:0] mst_ports_req_o;
	input wire [Cfg[299-:32] - 1:0] mst_ports_resp_i;
	input wire [(Cfg[31-:32] * 160) - 1:0] addr_map_i;
	input wire [Cfg[331-:32] - 1:0] en_default_mst_port_i;
	function automatic [31:0] cf_math_pkg_idx_width;
		input reg [31:0] num_idx;
		cf_math_pkg_idx_width = (num_idx > 32'd1 ? $unsigned($clog2(num_idx)) : 32'd1);
	endfunction
	input wire [(Cfg[331-:32] * cf_math_pkg_idx_width(Cfg[299-:32])) - 1:0] default_mst_port_i;
	wire [(Cfg[299-:32] >= 0 ? (Cfg[331-:32] * (Cfg[299-:32] + 1)) - 1 : (Cfg[331-:32] * (1 - Cfg[299-:32])) + (Cfg[299-:32] - 1)):(Cfg[299-:32] >= 0 ? 0 : Cfg[299-:32] + 0)] slv_reqs;
	wire [(Cfg[299-:32] >= 0 ? (Cfg[331-:32] * (Cfg[299-:32] + 1)) - 1 : (Cfg[331-:32] * (1 - Cfg[299-:32])) + (Cfg[299-:32] - 1)):(Cfg[299-:32] >= 0 ? 0 : Cfg[299-:32] + 0)] slv_resps;
	localparam [31:0] cfg_NoMstPorts = Cfg[299-:32];
	wire [(Cfg[299-:32] * Cfg[331-:32]) - 1:0] mst_reqs;
	wire [(Cfg[299-:32] * Cfg[331-:32]) - 1:0] mst_resps;
	genvar i;
	localparam axi_pkg_RESP_DECERR = 2'b11;
	function automatic [cf_math_pkg_idx_width(Cfg[299-:32] + 1) - 1:0] sv2v_cast_423F7;
		input reg [cf_math_pkg_idx_width(Cfg[299-:32] + 1) - 1:0] inp;
		sv2v_cast_423F7 = inp;
	endfunction
	generate
		for (i = 0; i < Cfg[331-:32]; i = i + 1) begin : gen_slv_port_demux
			wire [cf_math_pkg_idx_width(Cfg[299-:32]) - 1:0] dec_aw;
			wire [cf_math_pkg_idx_width(Cfg[299-:32]) - 1:0] dec_ar;
			wire [cf_math_pkg_idx_width(Cfg[299-:32] + 1) - 1:0] slv_aw_select;
			wire [cf_math_pkg_idx_width(Cfg[299-:32] + 1) - 1:0] slv_ar_select;
			wire dec_aw_valid;
			wire dec_aw_error;
			wire dec_ar_valid;
			wire dec_ar_error;
			addr_decode_160C3_6EDEE #(
				.addr_t_Cfg(Cfg),
				.NoIndices(Cfg[299-:32]),
				.NoRules(Cfg[31-:32])
			) i_axi_aw_decode(
				.addr_i(slv_ports_req_i[i].aw.addr),
				.addr_map_i(addr_map_i),
				.idx_o(dec_aw),
				.dec_valid_o(dec_aw_valid),
				.dec_error_o(dec_aw_error),
				.en_default_idx_i(en_default_mst_port_i[i]),
				.default_idx_i(default_mst_port_i[i * cf_math_pkg_idx_width(Cfg[299-:32])+:cf_math_pkg_idx_width(Cfg[299-:32])])
			);
			addr_decode_160C3_6EDEE #(
				.addr_t_Cfg(Cfg),
				.NoIndices(Cfg[299-:32]),
				.NoRules(Cfg[31-:32])
			) i_axi_ar_decode(
				.addr_i(slv_ports_req_i[i].ar.addr),
				.addr_map_i(addr_map_i),
				.idx_o(dec_ar),
				.dec_valid_o(dec_ar_valid),
				.dec_error_o(dec_ar_error),
				.en_default_idx_i(en_default_mst_port_i[i]),
				.default_idx_i(default_mst_port_i[i * cf_math_pkg_idx_width(Cfg[299-:32])+:cf_math_pkg_idx_width(Cfg[299-:32])])
			);
			assign slv_aw_select = (dec_aw_error ? sv2v_cast_423F7(Cfg[299-:32]) : sv2v_cast_423F7(dec_aw));
			assign slv_ar_select = (dec_ar_error ? sv2v_cast_423F7(Cfg[299-:32]) : sv2v_cast_423F7(dec_ar));
			axi_demux_B794D #(
				.AxiIdWidth(Cfg[160-:32]),
				.AtopSupport(ATOPs),
				.NoMstPorts(Cfg[299-:32] + 1),
				.MaxTrans(Cfg[267-:32]),
				.AxiLookBits(Cfg[128-:32]),
				.UniqueIds(Cfg[96]),
				.SpillAw(Cfg[202]),
				.SpillW(Cfg[201]),
				.SpillB(Cfg[200]),
				.SpillAr(Cfg[199]),
				.SpillR(Cfg[198])
			) i_axi_demux(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_i(test_i),
				.slv_req_i(slv_ports_req_i[i]),
				.slv_aw_select_i(slv_aw_select),
				.slv_ar_select_i(slv_ar_select),
				.slv_resp_o(slv_ports_resp_o[i]),
				.mst_reqs_o(slv_reqs[(Cfg[299-:32] >= 0 ? 0 : Cfg[299-:32]) + (i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32]))+:(Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])]),
				.mst_resps_i(slv_resps[(Cfg[299-:32] >= 0 ? 0 : Cfg[299-:32]) + (i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32]))+:(Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])])
			);
			axi_err_slv_EBC58 #(
				.AxiIdWidth(Cfg[160-:32]),
				.Resp(axi_pkg_RESP_DECERR),
				.ATOPs(ATOPs),
				.MaxTrans(4)
			) i_axi_err_slv(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_i(test_i),
				.slv_req_i(slv_reqs[(i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])) + (Cfg[299-:32] >= 0 ? Cfg[299-:32] : Cfg[299-:32] - Cfg[299-:32])]),
				.slv_resp_o(slv_resps[(i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])) + (Cfg[299-:32] >= 0 ? cfg_NoMstPorts : Cfg[299-:32] - cfg_NoMstPorts)])
			);
		end
		for (i = 0; i < Cfg[331-:32]; i = i + 1) begin : gen_xbar_slv_cross
			genvar j;
			for (j = 0; j < Cfg[299-:32]; j = j + 1) begin : gen_xbar_mst_cross
				if (Connectivity[(i * Cfg[299-:32]) + j]) begin : gen_connection
					axi_multicut_407D8 #(.NoCuts(Cfg[192-:32])) i_axi_multicut_xbar_pipeline(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.slv_req_i(slv_reqs[(i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])) + (Cfg[299-:32] >= 0 ? j : Cfg[299-:32] - j)]),
						.slv_resp_o(slv_resps[(i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])) + (Cfg[299-:32] >= 0 ? j : Cfg[299-:32] - j)]),
						.mst_req_o(mst_reqs[(j * Cfg[331-:32]) + i]),
						.mst_resp_i(mst_resps[(j * Cfg[331-:32]) + i])
					);
				end
				else begin : gen_no_connection
					assign mst_reqs[(j * Cfg[331-:32]) + i] = 1'sb0;
					axi_err_slv_EBC58 #(
						.AxiIdWidth(Cfg[160-:32]),
						.Resp(axi_pkg_RESP_DECERR),
						.ATOPs(ATOPs),
						.MaxTrans(1)
					) i_axi_err_slv(
						.clk_i(clk_i),
						.rst_ni(rst_ni),
						.test_i(test_i),
						.slv_req_i(slv_reqs[(i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])) + (Cfg[299-:32] >= 0 ? j : Cfg[299-:32] - j)]),
						.slv_resp_o(slv_resps[(i * (Cfg[299-:32] >= 0 ? Cfg[299-:32] + 1 : 1 - Cfg[299-:32])) + (Cfg[299-:32] >= 0 ? j : Cfg[299-:32] - j)])
					);
				end
			end
		end
		for (i = 0; i < Cfg[299-:32]; i = i + 1) begin : gen_mst_port_mux
			axi_mux_621CA #(
				.SlvAxiIDWidth(Cfg[160-:32]),
				.NoSlvPorts(Cfg[331-:32]),
				.MaxWTrans(Cfg[235-:32]),
				.FallThrough(Cfg[203]),
				.SpillAw(Cfg[197]),
				.SpillW(Cfg[196]),
				.SpillB(Cfg[195]),
				.SpillAr(Cfg[194]),
				.SpillR(Cfg[193])
			) i_axi_mux(
				.clk_i(clk_i),
				.rst_ni(rst_ni),
				.test_i(test_i),
				.slv_reqs_i(mst_reqs[i * Cfg[331-:32]+:Cfg[331-:32]]),
				.slv_resps_o(mst_resps[i * Cfg[331-:32]+:Cfg[331-:32]]),
				.mst_req_o(mst_ports_req_o[i]),
				.mst_resp_i(mst_ports_resp_i[i])
			);
		end
	endgenerate
endmodule
