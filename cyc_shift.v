module cyc_shift(shift, vtc, ctv, c ,v);
parameter data_w = 8;
parameter D = 5;

input [data_w-1:0] shift;
input [data_w*D-1:0] ctv, vtc;
output [data_w*D-1:0] c, v;

reg [data_w*D-1:0] c, v;
wire [data_w-1:0] temp;

assign temp = shift>>2;

always @(*) begin
	if(shift == {data_w{1'b1}})
	begin
		c <= {D{1'b0,{(data_w-1){1'b1}}}};
		v <= {D*data_w{1'b0}};
	end else begin
		c <= (vtc>>(temp*data_w)) | (vtc<<((D-temp)*data_w)) ;
		v <= (ctv>>(temp*data_w)) | (ctv<<((D-temp)*data_w)) ;
	end
end

endmodule 

