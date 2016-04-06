module cnu(clk, rst, q, r);
parameter data_w = 8;
parameter idx_w = 8;
parameter D=8;

input	clk, rst;
input	[data_w*D-1:0] q;
output reg [data_w*D-1:0] r;

wire	[data_w-1:0] min, min2;
wire	rsgn;

wire	[data_w*D-1:0] qmag;
wire	[idx_w-1:0] min_idx;
wire	[D-1:0] qsgn;

genvar i;

//-----------

generate
for(i=0; i<D; i=i+1) begin :get_abs
	abs #(.data_w(data_w)) AQ (.x(q[i*data_w +:data_w]), .xsgn(qsgn[i]), .xmag(qmag[i*data_w +:data_w]));
end
endgenerate

cmp_tree #(.D(D), .data_w(data_w), .idx_w(idx_w)) CPT (
	.clk(clk),
	.rst(rst), 
	.in(qmag), 
	.min(min), 
	.min2(min2), 
	.min_idx(min_idx)
);
assign rsgn = ^qsgn;

generate
for(i=0; i<D; i=i+1) begin :calc_r
	always @(*) begin
		if(min_idx == i) begin
			if(rsgn^qsgn[i])
				r[i*data_w +:data_w]<=-(((min2<<1)+min2)>>2);
			else
				r[i*data_w +:data_w]<=(((min2<<1)+min2)>>2);
		end else begin
			if(rsgn^qsgn[i])
				r[i*data_w +:data_w]<=-(((min<<1)+min)>>2);
			else
				r[i*data_w +:data_w]<=(((min<<1)+min)>>2);
		end
	end
end
endgenerate

endmodule

