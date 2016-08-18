`ifdef SIMULATION
    `include "cmp3.v"
    `include "cmp4.v"
`endif

(* bram_map="yes" *)
module cmpx(en, clk, rst, in, min, min2, min_idx);
parameter data_w = 9;
parameter D = 7;
localparam idx_w = 3;

input clk, rst, en;
input [data_w*D-1:0] in;
output reg [data_w-1:0] min, min2;
output reg [D-1:0] min_idx;

reg [2*data_w-1:0] pair_res;
reg [D-1:0] idx_res;

wire [2*data_w-1:0] pair_a, pair_b, pair_c, pair_res;
wire [idx_w-1:0] idx_a, idx_b;
wire [2*idx_w-1:0] idx_c;
wire c0, c1;

cmp3 #(.data_w(data_w)) CP3A (.in(in[0*data_w +:3*data_w]), .out(pair_a), .idx(idx_a));
cmp3 #(.data_w(data_w)) CP3B (.in(in[3*data_w +:3*data_w]), .out(pair_b), .idx(idx_b));
cmp4 #(.data_w(data_w), .idx_w(idx_w)) CP4A (.in({pair_b, pair_a}), .idx_in({idx_b, idx_a}), .out(pair_c), .idx_out(idx_c));

generate
if(D == 6) begin
	always @(*) begin
		pair_res = pair_c;
		idx_res = idx_c;
	end
end

if(D == 7) begin
	assign c0 = pair_c[0*data_w +:data_w] < in[6*data_w +:data_w];
	assign c1 = pair_c[1*data_w +:data_w] < in[6*data_w +:data_w];
	always @(*) begin
		case({c0, c1})
			2'b00:begin
				pair_res = {pair_c[0*data_w +:data_w], in[6*data_w +:data_w]};
				idx_res = 7'b1000000;
			end
			2'b10:begin
				pair_res = {in[6*data_w +:data_w], pair_c[0*data_w +:data_w]};
				idx_res = {1'b0, idx_c};
			end
			default:begin
				pair_res = pair_c;
				idx_res = {1'b0, idx_c};
			end
		endcase
	end
end
endgenerate 

always @(posedge clk) begin
    if(rst)begin
        min <= 0;
        min2 <= 0;
        min_idx <= 0;
    end
    else if(en) begin
        min <= pair_res[0*data_w +:data_w];
        min2 <= pair_res[1*data_w +:data_w];
        min_idx <= idx_res;
    end
end

endmodule

