module compare(in, idx_in, out, idx_out);
parameter data_w = 8;
parameter idx_w = 8;

input [data_w*4-1:0] in;
input [idx_w*4-1:0] idx_in;
output [data_w*2-1:0] out;
output [idx_w*2-1:0] idx_out;

reg [data_w-1:0] res [1:0];
reg [idx_w-1:0] res_idx [1:0];

wire [data_w-1:0] num [3:0];
wire [idx_w-1:0] index[3:0];
genvar i;

assign out = {res[1], res[0]};
assign idx_out = {res_idx[1], res_idx[0]};

generate
for (i=0; i<4; i=i+1) begin :split_bus
	assign num[i] = in[i*data_w +:data_w];
	assign index[i] = idx_in[i*idx_w +:idx_w];
end
endgenerate

always @* begin
	if(num[0]<num[2]) begin
		res[0] <= num[0];
		res_idx[0] <= index[0];
		if(num[1]<num[2]) begin
			res[1] <= num[1];
			res_idx[1] <= index[1];
		end
		else begin
			res[1] <= num[2];
			res_idx[1] <= index[2];
		end
	end
	else begin
		res[0] <= num[2];
		res_idx[0] <= index[2];
		if(num[0]<num[3])begin
			res[1] <= num[0];
			res_idx[1] <= index[0];
		end else begin
			res[1] <= num[3];
			res_idx[1] <= index[3];
		end
	end 
end
endmodule

