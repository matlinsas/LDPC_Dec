module cmp3(in, out, idx);
parameter data_w = 9;
localparam idx_w = 3;

input [data_w*3-1:0] in;
output reg [data_w*2-1:0] out;
output reg [idx_w-1:0] idx;

wire c01, c02, c12;

assign c01 = in[0*data_w +:data_w]<in[1*data_w +:data_w];
assign c02 = in[0*data_w +:data_w]<in[2*data_w +:data_w];
assign c12 = in[1*data_w +:data_w]<in[2*data_w +:data_w];

always @(*) begin
	case({c01, c02, c12})
		3'b000:begin
			out = {in[1*data_w +:data_w], in[2*data_w +:data_w]};
			idx = 3'b100;
		end
		3'b001:begin
			out = {in[2*data_w +:data_w], in[1*data_w +:data_w]};
			idx = 3'b010;
		end
		3'b011:begin
			out = {in[0*data_w +:data_w], in[1*data_w +:data_w]};
			idx = 3'b010;
		end
		3'b100:begin
			out = {in[0*data_w +:data_w], in[2*data_w +:data_w]};
			idx = 3'b100;
		end
		3'b110:begin
			out = {in[2*data_w +:data_w], in[0*data_w +:data_w]};
			idx = 3'b001;
		end
		default:begin
			out = {in[1*data_w +:data_w], in[0*data_w +:data_w]};
			idx = 3'b001;
		end
	endcase
end

endmodule
