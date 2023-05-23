module axi_multicut_407D8 (
	clk_i,
	rst_ni,
	slv_req_i,
	slv_resp_o,
	mst_req_o,
	mst_resp_i
);
	parameter [31:0] NoCuts = 32'd1;
	input wire clk_i;
	input wire rst_ni;
	input wire slv_req_i;
	output wire slv_resp_o;
	output wire mst_req_o;
	input wire mst_resp_i;
	generate
		if (NoCuts == {32 {1'sb0}}) begin : gen_no_cut
			assign mst_req_o = slv_req_i;
			assign slv_resp_o = mst_resp_i;
		end
		else begin : gen_axi_cut
			wire [NoCuts:0] cut_req;
			wire [NoCuts:0] cut_resp;
			assign cut_req[0] = slv_req_i;
			assign slv_resp_o = cut_resp[0];
			genvar i;
			for (i = 0; i < NoCuts; i = i + 1) begin : gen_axi_cuts
				axi_cut_0380A #(.Bypass(1'b0)) i_cut(
					.clk_i(clk_i),
					.rst_ni(rst_ni),
					.slv_req_i(cut_req[i]),
					.slv_resp_o(cut_resp[i]),
					.mst_req_o(cut_req[i + 1]),
					.mst_resp_i(cut_resp[i + 1])
				);
			end
			assign mst_req_o = cut_req[NoCuts];
			assign cut_resp[NoCuts] = mst_resp_i;
		end
	endgenerate
endmodule
