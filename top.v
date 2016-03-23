module top();
parameter data_w = 8;
parameter R = 5;
parameter C = 3;
parameter D = 8;

genvar i,j,k;

generate
for(j=0; j<C; j=j+1) begin :column
    for(i=0; i<R; i=i+1) begin :row
    end
end
endgenerate

endmodule
