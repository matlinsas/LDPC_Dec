module cnu(en, clk, rst, q, r);
parameter D=8;
parameter data_w = 8;
localparam idx_w = log2(D);

input	clk, rst, en;
input [data_w*D-1:0] q;
output [data_w*D-1:0] r;

wire	[data_w-1:0] min, min2;
wire	[data_w+1:0] tmin, tmin2;
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
    .en(en),
	.clk(clk),
	.rst(rst), 
	.in(qmag), 
	.min(min), 
	.min2(min2), 
	.min_idx(min_idx)
);
assign rsgn = ^qsgn;

assign tmin = {2'b0, min};
assign tmin2 = {2'b0, min2};

generate
for(i=0; i<D; i=i+1) begin :calc_r
	assign r[i*data_w +:data_w] = (min_idx == i)?
	((rsgn^qsgn[i])?(-(((tmin2<<1)+tmin2)>>2)):(((tmin2<<1)+tmin2)>>2)):
	((rsgn^qsgn[i])?(-(((tmin<<1)+tmin)>>2)):(((tmin<<1)+tmin)>>2));
end
endgenerate
//-----------
function integer log2;
	input integer x;
	begin
		log2 = 0;
		while (x) begin
			log2 = log2 + 1;
			x = x>>1;
		end
	end
endfunction

endmodule

