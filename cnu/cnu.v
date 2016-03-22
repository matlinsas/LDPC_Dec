module cnu(clk, rst, q, r);
parameter data_w = 8;
parameter idx_w = 8;
parameter D=8;

input	clk, rst;
input	[data_w*D-1:0] q;
output	[data_w*D-1:0] r;

wire	[data_w-1:0] min, min2;
reg	[data_w*D-1:0] r;
wire	rsgn;

wire	[data_w*D-1:0] qmag;
wire	[idx_w*D-1:0] min_idx;
wire	[D-1:0] qsgn;

genvar i;

//-----------

generate
for(i=0; i<D; i=i+1) begin :get_abs
	abs #(.data_w(data_w)) AQ (.x(q[i*data_w +:data_w]), .xsgn(qsgn[i]), .xmag(qmag[i*data_w +:data_w]));
end
endgenerate

merge_ppl #(.D(D), .data_w(data_w), .idx_w(idx_w)) MPL (
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
   always @(posedge clk or posedge rst) begin
	   if(rst==1)begin
		   r[(i+1)*data_w-1:i*data_w]<=0;
	   end else begin 
		   if(min_idx == i) begin
			   r[i*data_w +:data_w]<=(rsgn^qsgn[i])?-min2:min2;
		   end else begin
			   r[i*data_w +:data_w]<=(rsgn^qsgn[i])?-min:min;
		   end
	   end 
   end
end
endgenerate

endmodule

