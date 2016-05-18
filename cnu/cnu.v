`ifdef SIMULATION
    `include "abs.v"
    `include "sat.v"
    `include "cmp_tree.v"
`endif
module cnu(en, clk, rst, q, r);
parameter D=8;
parameter res_w = 8;
parameter ext_w = 3;
parameter idx_w = 3;
localparam  data_w = res_w + ext_w;

input	clk, rst, en;
input [data_w*D-1:0] q;
output [res_w*D-1:0] r;

wire	[data_w-1:0] min, min2;
wire	[data_w+1:0] tmin, tmin2;

wire	[data_w*D-1:0] qmag;
wire	[idx_w-1:0] min_idx;
wire	[D-1:0] qsgn;
reg	[D-1:0] qsgn2;
reg	rsgn;

genvar i;

//-----------

generate
for(i=0; i<D; i=i+1) begin :get_abs
	abs #(.data_w(data_w)) AQ (.x(q[i*data_w +:data_w]), .xsgn(qsgn[i]), .xmag(qmag[i*data_w +:data_w]));
end
endgenerate

cmp_tree #(.D(D), .data_w(data_w), .idx_w(idx_w)) CPT (
    .en(en),
	.clk(clk),
	.rst(rst), 
	.in(qmag), 
	.min(min), 
	.min2(min2), 
	.min_idx(min_idx)
);

always @(posedge clk or posedge rst) begin
	if(rst) begin
		rsgn <= 0;
		qsgn2 <= 0;
	end else if(en) begin
		rsgn <= ^qsgn;
		qsgn2 <= qsgn;
	end
end

assign tmin = {2'b0, min};
assign tmin2 = {2'b0, min2};

generate
for(i=0; i<D; i=i+1) begin :calc_r
    sat #(.IN_SIZE(data_w+1), .OUT_SIZE(res_w-1)) SAT (
        .sat_in(
            (min_idx == i)?
            ((rsgn^qsgn2[i])?(-(((tmin2<<1)+tmin2)>>2)):(((tmin2<<1)+tmin2)>>2)):
            ((rsgn^qsgn2[i])?(-(((tmin<<1)+tmin)>>2)):(((tmin<<1)+tmin)>>2))
        ),
        .sat_out(r[i*res_w +:res_w])
    );
end
endgenerate

endmodule

