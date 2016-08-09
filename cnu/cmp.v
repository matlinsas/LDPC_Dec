module compare(in, idx_in, out, idx_out);
parameter data_w = 9;
parameter idx_w = 3;

input [data_w*4-1:0] in;
input [idx_w*4-1:0] idx_in;
output reg [data_w*2-1:0] out;
output reg [idx_w*2-1:0] idx_out;

//reg [data_w-1:0] res [1:0];
//reg [idx_w-1:0] res_idx [1:0];

wire [2:0] cc;

//assign out = {res[1], res[0]};
//assign idx_out = {res_idx[1], res_idx[0]};
//-------------

assign cc[0] = (in[0 +:data_w]<in[2*data_w +:data_w]);
assign cc[1] = (in[data_w +:data_w]<in[2*data_w +:data_w]) & cc[0];
assign cc[2] = (in[0 +:data_w]<in[3*data_w +:data_w]) | cc[0];

always @(*) begin
    case (cc)
        3'b111: begin
                    out = {in[data_w +:data_w], in[0 +:data_w]};
                    idx_out = {idx_in[idx_w +:idx_w], idx_in[0 +:idx_w]};
                end
        3'b101: begin
                    out = {in[2*data_w +:data_w], in[0 +:data_w]};
                    idx_out = {idx_in[2*idx_w +:idx_w], idx_in[0 +:idx_w]};
                end
        3'b100: begin
                    out = {in[0 +:data_w], in[2*data_w +:data_w]};
                    idx_out = {idx_in[0 +:idx_w], idx_in[2*idx_w +:idx_w]};
                end
        default: begin
                    out = {in[3*data_w +:data_w], in[2*data_w +:data_w]};
                    idx_out = {idx_in[3*idx_w +:idx_w], idx_in[2*idx_w +:idx_w]};
                end
    endcase
end
//-------------
/*
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
*/
endmodule
