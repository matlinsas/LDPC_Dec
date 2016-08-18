`ifdef SIMULATION
    `include "abs.v"
    `include "sat.v"
    `include "cmpx.v"
	`include "sgn_ram.v"
`endif
module cnu(en, clk, rst, q, r);
parameter D=7;
parameter idx_w = 3;
parameter res_w = 6;
parameter ext_w = 3;
localparam  data_w = res_w + ext_w;

input	clk, rst, en;
input [data_w*D-1:0] q;
output [res_w*D-1:0] r;

wire    [data_w-1:0] min, min2;
wire    [data_w+1:0] tmin, tmin2;
wire    [res_w-1:0] smin, smin2;

wire	[data_w*D-1:0] qmag;
wire	[idx_w-1:0] min_idx;
wire	[D-1:0] qsgn;
wire	[D-1:0] qsgn2;
wire	rsgn;

genvar i;

//-----------

generate
for(i=0; i<D; i=i+1) begin :get_abs
	abs #(.data_w(data_w)) AQ (.x(q[i*data_w +:data_w]), .xsgn(qsgn[i]), .xmag(qmag[i*data_w +:data_w]));
end
endgenerate

cmpx #(.D(D), .data_w(data_w)) CPX (
    .en(en),
	.clk(clk),
	.rst(rst), 
	.in(qmag), 
	.min(min), 
	.min2(min2), 
	.min_idx(min_idx)
);

sgn_ram #(.D(D)) SRAM(
	.en(en), .clk(clk), .rst(rst), .qsgn(qsgn),
	.rsgn(rsgn), .qsgn2(qsgn2)
);

assign tmin = ({2'b0, min}<<1)+min;
assign tmin2 = ({2'b0, min2}<<1)+min2;
sat #(.IN_SIZE(data_w-1), .OUT_SIZE(res_w-1)) SMIN ( .sat_in( tmin[2 +:data_w] ), .sat_out(smin) );
sat #(.IN_SIZE(data_w-1), .OUT_SIZE(res_w-1)) SMIN2 ( .sat_in( tmin2[2 +:data_w] ), .sat_out(smin2));

generate
for(i=0; i<D; i=i+1) begin :calc_r
    assign r[i*res_w +:res_w] = (min_idx == i)?( (rsgn^qsgn2[i])? -smin2:smin2 ):( (rsgn^qsgn2[i])? -smin:smin );
end
endgenerate

endmodule

