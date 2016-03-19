module abs(x, xmag, xsgn);
parameter data_w = 8;

input [data_w-1:0] x;
output [data_w-1:0] xmag;
output xsgn;

reg [data_w-1:0] xmag;
reg xsgn;

always @(x) begin
xsgn<=x[data_w-1];
if(x[data_w-1]==1)
xmag<=-x;
else
xmag<=x;

end

endmodule
