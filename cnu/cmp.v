module compare(in, idx_in, out, idx_out);
parameter data_w = 8;
parameter idx_w = 8;

input [data_w*4-1:0] in;
input [idx_w*4-1:0] idx_in;
output [data_w*2-1:0] out;
output [idx_w*2-1:0] idx_out;

reg [data_w-1:0] res [1:0];
reg [idx_w-1:0] res_idx [1:0];

assign out = {res[1], res[0]};
assign idx_out = {res_idx[1], res_idx[0]};

always @(*) begin
	if(in[0 +:data_w]<in[2*data_w +:data_w]) begin
		res[0] = in[0 +:data_w];
		res_idx[0] = idx_in[0 +:idx_w];
		if(in[data_w +:data_w]<in[2*data_w +:data_w]) begin
			res[1] = in[data_w +:data_w];
			res_idx[1] = idx_in[idx_w +:idx_w];
		end else begin
			res[1] = in[2*data_w +:data_w];
			res_idx[1] = idx_in[2*idx_w +:idx_w];
		end
	end else begin
		res[0] = in[2*data_w +:data_w];
		res_idx[0] = idx_in[2*idx_w +:idx_w];
		if(in[0 +:data_w]<in[3*data_w +:data_w])begin
			res[1] = in[0 +:data_w];
			res_idx[1] = idx_in[0 +:idx_w];
		end else begin
			res[1] = in[3*data_w +:data_w];
			res_idx[1] = idx_in[3*idx_w +:idx_w];
		end
	end 
end
endmodule

