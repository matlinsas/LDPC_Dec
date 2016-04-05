module cyc_shift(shift, vtc, ctv, c ,v);
parameter data_w = 8;
parameter D = 5;

input [data_w-1:0] shift;
input [data_w*D-1:0] ctv, vtc;
output [data_w*D-1:0] c, v;

reg [data_w*D-1:0] c, v;

always @(*) begin
	if(shift == {data_w{1'b1}})
	begin
		c <= {D{1'b0,{(data_w-1){1'b1}}}};
		v <= {D*data_w{1'b0}};
	end else begin
		c <= (vtc>>(shift*data_w)) | (vtc<<((D-shift)*data_w)) ;
		v <= (ctv>>(shift*data_w)) | (ctv<<((D-shift)*data_w)) ;
	end
end

endmodule 

