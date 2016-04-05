module vnu(l, r, q, dec);
parameter data_w = 8;
parameter idx_w = 8;
parameter D=5;

input 	[data_w-1:0] l;
input	[data_w*D-1:0] r;
output	[data_w*D-1:0] q;
output	dec;

reg 	[data_w-1:0] t;

genvar i;
integer j;

always @(*) begin
	t = l;
	for(j=0; j<D; j=j+1)
		t  = t + r[j*data_w +:data_w];
end

generate
for(i=0; i<D; i=i+1)begin :calc_q
	assign q[i*data_w +:data_w] = t - r[i*data_w +:data_w];
end
endgenerate

assign dec = t[data_w-1];

endmodule

