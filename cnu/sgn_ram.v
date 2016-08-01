(* bram_map="yes" *)

module sgn_ram(en, clk, rst, qsgn, rsgn, qsgn2);
parameter D=8;
input clk, rst, en;
input [D-1:0] qsgn;
output reg rsgn;
output reg [D-1:0] qsgn2;

always @(posedge clk) begin
	if(rst) begin
		rsgn <= 0;
		qsgn2 <= 0;
	end else if(en) begin
		rsgn <= ^qsgn;
		qsgn2 <= qsgn;
	end
end

endmodule
