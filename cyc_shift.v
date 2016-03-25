module cyc_shift(clk, rst, shift, vtc, ctv, c ,v);
parameter data_w = 8;
parameter D = 5;

input clk, rst;
input [data_w-1:0] shift;
input [data_w*D-1:0] ctv, vtc;
output [data_w*D-1:0] c, v;

genvar i;

generate
for(i=0; i<D; i=i+1) begin :match_CV
    assign c[i*data_w +:data_w] = vtc[data_w*((i+shift)%D) +: data_w];
    assign v[i*data_w +:data_w] = ctv[data_w*((i-shift)%D) +: data_w];
end 
endgenerate

endmodule 
