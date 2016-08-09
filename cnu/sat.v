module sat (sat_in, sat_out);
parameter IN_SIZE = 9; 
parameter OUT_SIZE = 6;

input [IN_SIZE:0] sat_in;
output [OUT_SIZE:0] sat_out;

wire[OUT_SIZE:0] max_pos={1'b0,{OUT_SIZE{1'b1}}};

assign sat_out = (sat_in[IN_SIZE:OUT_SIZE]=={IN_SIZE-OUT_SIZE+1{1'b0}})?sat_in[OUT_SIZE:0]:max_pos;

endmodule
