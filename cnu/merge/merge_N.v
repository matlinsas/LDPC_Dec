module merge_N(clk, rst, in, idx_in, out, idx_out);
parameter data_w = 8;
parameter idx_w = 8;
parameter Pin = 3;
localparam Pout = (Pin >> 1)+(Pin & 1);

input clk, rst;
input [data_w*2*Pin-1:0] in;
input [idx_w*2*Pin-1:0] idx_in;
output [data_w*2*Pout-1:0] out;
output [idx_w*2*Pout-1:0] idx_out;

wire [data_w*2-1:0] ans [Pout-1:0];
wire [idx_w*2-1:0] m_idx [Pout-1:0];

genvar i;

generate
for(i=0; (i+1)*2<=Pin; i=i+1) begin :merge_pairs
	merge M (
		.clk(clk),
		.rst(rst),
		.in(in[data_w*4*i +:data_w*4]),
		.idx_in(idx_in[idx_w*4*i +:idx_w*4]),
		.out(ans[i]),
		.idx_out(m_idx[i])
	);
end 
endgenerate

generate
if((Pin & 1)==1) begin
	reg [data_w*2-1:0] sgl;
	reg [idx_w*2-1:0] sgl_idx;
	assign ans[Pout-1] = sgl;
	assign m_idx[Pout-1] = sgl_idx;
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			sgl <= 0;
			sgl_idx <= 0;
		end else begin
			sgl <= in[data_w*2*(Pin-1) +:data_w*2];
			sgl_idx <= idx_in[idx_w*2*(Pin-1) +:idx_w*2];
		end
	end
end 
endgenerate

generate
for(i=0;i<Pout;i=i+1) begin :combine_bus
	assign out[data_w*2*i +:data_w*2] = ans[i];
	assign idx_out[idx_w*2*i +:idx_w*2] = m_idx[i];
end
endgenerate

endmodule

