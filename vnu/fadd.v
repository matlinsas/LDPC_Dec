module fadd(A, B, Ci, S, Co);
parameter data_w = 8;

input [data_w-1:0] A;
input [data_w-1:0] B;
input [data_w-1:0] Ci;
output [data_w-1:0] S;
output [data_w-1:0] Co;

wire [data_w-1:0] t;

assign t = A^B;
assign S = t^Ci;
assign Co = ((A & B) | (Ci & t)) << 1;

endmodule
