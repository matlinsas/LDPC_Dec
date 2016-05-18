module sat (sat_in, sat_out);
parameter IN_SIZE = 10; 
parameter OUT_SIZE = 8;

input [IN_SIZE:0] sat_in;
output [OUT_SIZE:0] sat_out;

wire[OUT_SIZE:0] max_pos={1'b0,{OUT_SIZE{1'b1}}};
wire[OUT_SIZE:0] max_neg={1'b1,{OUT_SIZE{1'b0}}};

assign sat_out =
	((sat_in[IN_SIZE:OUT_SIZE]=={IN_SIZE-OUT_SIZE+1{1'b0}}) ||
	(sat_in[IN_SIZE:OUT_SIZE]=={IN_SIZE-OUT_SIZE+1{1'b1}}))?
	sat_in[OUT_SIZE:0]:((sat_in[IN_SIZE])?max_neg:max_pos);
endmodule
