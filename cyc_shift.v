module cyc_shift(shift, vtc, ctv, c ,v);
parameter data_w = 8;
parameter ext_w = 3;
parameter mtx_w = 8;
parameter D = 5;
localparam temp_w = data_w + ext_w;

input [mtx_w-1:0] shift;
input [data_w*D-1:0] ctv;
input [temp_w*D-1:0] vtc;
output reg [data_w*D-1:0] v;
output reg [temp_w*D-1:0] c;

wire [data_w-1:0] temp;

assign temp = shift;//>>2;

always @(*) begin
	if(shift == {mtx_w{1'b1}})
	begin
		c <= {D{1'b0,{(temp_w-1){1'b1}}}};
		v <= {D*data_w{1'b0}};
	end else begin
		c <= (vtc>>(temp*temp_w)) | (vtc<<((D-temp)*temp_w)) ;
		v <= (ctv>>(temp*data_w)) | (ctv<<((D-temp)*data_w)) ;
	end
end

endmodule 

