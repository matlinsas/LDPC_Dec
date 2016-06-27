module sat (sat_in, sat_sgn, sat_out);
parameter IN_SIZE = 10; 
parameter OUT_SIZE = 8;

input sat_sgn;
input [IN_SIZE:0] sat_in;
output [OUT_SIZE:0] sat_out;

wire[OUT_SIZE:0] max_pos={1'b0,{OUT_SIZE{1'b1}}};
wire[OUT_SIZE:0] max_neg={1'b1,{OUT_SIZE{1'b0}}};
wire[IN_SIZE:0] temp;

assign temp = (sat_in>>2);//+sat_in[1];

assign sat_out = (temp[IN_SIZE:OUT_SIZE]=={IN_SIZE-OUT_SIZE+1{1'b0}})?
    ((sat_sgn)?-temp[OUT_SIZE:0]:temp[OUT_SIZE:0]):
    ((sat_sgn)?max_neg:max_pos);

endmodule
