module cyc_shift(shift, vtc, ctv, c ,v);
parameter data_w = 8;
parameter D = 5;

input [data_w-1:0] shift;
input [data_w*D-1:0] ctv, vtc;
output [data_w*D-1:0] c, v;

assign c = (vtc>>(shift*data_w)) | (vtc<<((D-shift)*data_w)) ;
assign v = (ctv>>(shift*data_w)) | (ctv<<((D-shift)*data_w)) ;

endmodule 
