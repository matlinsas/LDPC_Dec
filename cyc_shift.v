module cyc_shift(shift, vtc, ctv, c ,v);
parameter data_w = 8;
parameter ext_w = 3;
parameter mtx_w = 8;
parameter D = 5;
localparam temp_w = data_w + ext_w;

input [mtx_w-1:0] shift;
input [data_w*D-1:0] ctv;
input [temp_w*D-1:0] vtc;
output [data_w*D-1:0] v;
output [temp_w*D-1:0] c;

wire [mtx_w-1:0] temp;

assign temp = shift;//>>2;

assign c = (shift == {mtx_w{1'b1}})?
    ( {D{1'b0,{(temp_w-1){1'b1}}}} ):
    ( {vtc, vtc} >> (temp*temp_w) );

assign v = (shift == {mtx_w{1'b1}})?
    ( {D*data_w{1'b0}} ):
    ( {ctv, ctv} >> ((D-temp)*data_w) );

endmodule 

