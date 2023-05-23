module axi_id_prepend_D1C46 (
	pre_id_i,
	slv_aw_chans_i,
	slv_aw_valids_i,
	slv_aw_readies_o,
	slv_w_chans_i,
	slv_w_valids_i,
	slv_w_readies_o,
	slv_b_chans_o,
	slv_b_valids_o,
	slv_b_readies_i,
	slv_ar_chans_i,
	slv_ar_valids_i,
	slv_ar_readies_o,
	slv_r_chans_o,
	slv_r_valids_o,
	slv_r_readies_i,
	mst_aw_chans_o,
	mst_aw_valids_o,
	mst_aw_readies_i,
	mst_w_chans_o,
	mst_w_valids_o,
	mst_w_readies_i,
	mst_b_chans_i,
	mst_b_valids_i,
	mst_b_readies_o,
	mst_ar_chans_o,
	mst_ar_valids_o,
	mst_ar_readies_i,
	mst_r_chans_i,
	mst_r_valids_i,
	mst_r_readies_o
);
	parameter [31:0] NoBus = 1;
	parameter [31:0] AxiIdWidthSlvPort = 4;
	parameter [31:0] AxiIdWidthMstPort = 6;
	parameter [31:0] PreIdWidth = AxiIdWidthMstPort - AxiIdWidthSlvPort;
	input wire [PreIdWidth - 1:0] pre_id_i;
	input wire [NoBus - 1:0] slv_aw_chans_i;
	input wire [NoBus - 1:0] slv_aw_valids_i;
	output wire [NoBus - 1:0] slv_aw_readies_o;
	input wire [NoBus - 1:0] slv_w_chans_i;
	input wire [NoBus - 1:0] slv_w_valids_i;
	output wire [NoBus - 1:0] slv_w_readies_o;
	output wire [NoBus - 1:0] slv_b_chans_o;
	output wire [NoBus - 1:0] slv_b_valids_o;
	input wire [NoBus - 1:0] slv_b_readies_i;
	input wire [NoBus - 1:0] slv_ar_chans_i;
	input wire [NoBus - 1:0] slv_ar_valids_i;
	output wire [NoBus - 1:0] slv_ar_readies_o;
	output wire [NoBus - 1:0] slv_r_chans_o;
	output wire [NoBus - 1:0] slv_r_valids_o;
	input wire [NoBus - 1:0] slv_r_readies_i;
	output reg [NoBus - 1:0] mst_aw_chans_o;
	output wire [NoBus - 1:0] mst_aw_valids_o;
	input wire [NoBus - 1:0] mst_aw_readies_i;
	output wire [NoBus - 1:0] mst_w_chans_o;
	output wire [NoBus - 1:0] mst_w_valids_o;
	input wire [NoBus - 1:0] mst_w_readies_i;
	input wire [NoBus - 1:0] mst_b_chans_i;
	input wire [NoBus - 1:0] mst_b_valids_i;
	output wire [NoBus - 1:0] mst_b_readies_o;
	output reg [NoBus - 1:0] mst_ar_chans_o;
	output wire [NoBus - 1:0] mst_ar_valids_o;
	input wire [NoBus - 1:0] mst_ar_readies_i;
	input wire [NoBus - 1:0] mst_r_chans_i;
	input wire [NoBus - 1:0] mst_r_valids_i;
	output wire [NoBus - 1:0] mst_r_readies_o;
	genvar i;
	generate
		for (i = 0; i < NoBus; i = i + 1) begin : gen_id_prepend
			if (PreIdWidth == 0) begin : gen_no_prepend
				wire [1:1] sv2v_tmp_325D9;
				assign sv2v_tmp_325D9 = slv_aw_chans_i[i];
				always @(*) mst_aw_chans_o[i] = sv2v_tmp_325D9;
				wire [1:1] sv2v_tmp_E5319;
				assign sv2v_tmp_E5319 = slv_ar_chans_i[i];
				always @(*) mst_ar_chans_o[i] = sv2v_tmp_E5319;
			end
			else begin : gen_prepend
				always @(*) begin
					mst_aw_chans_o[i] = slv_aw_chans_i[i];
					mst_ar_chans_o[i] = slv_ar_chans_i[i];
					mst_aw_chans_o[i].id = {pre_id_i, slv_aw_chans_i[i].id[AxiIdWidthSlvPort - 1:0]};
					mst_ar_chans_o[i].id = {pre_id_i, slv_ar_chans_i[i].id[AxiIdWidthSlvPort - 1:0]};
				end
			end
			assign slv_b_chans_o[i] = mst_b_chans_i[i];
			assign slv_r_chans_o[i] = mst_r_chans_i[i];
		end
	endgenerate
	assign mst_w_chans_o = slv_w_chans_i;
	assign mst_aw_valids_o = slv_aw_valids_i;
	assign slv_aw_readies_o = mst_aw_readies_i;
	assign mst_w_valids_o = slv_w_valids_i;
	assign slv_w_readies_o = mst_w_readies_i;
	assign slv_b_valids_o = mst_b_valids_i;
	assign mst_b_readies_o = slv_b_readies_i;
	assign mst_ar_valids_o = slv_ar_valids_i;
	assign slv_ar_readies_o = mst_ar_readies_i;
	assign slv_r_valids_o = mst_r_valids_i;
	assign mst_r_readies_o = slv_r_readies_i;
endmodule
