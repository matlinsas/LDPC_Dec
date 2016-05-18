module check(mtx, dec, res);
parameter mtx_w=8;
parameter C=8;
parameter R=4;
parameter D=8;

input [R*D-1:0] dec;
input [C*R*mtx_w-1:0] mtx;
output res;

wire [mtx_w-1:0] matrix [C-1:0][R-1:0];
wire [D-1:0] shifted [C-1:0][R-1:0];
wire [R-1:0] rotated [C*D-1:0];
wire [C*D-1:0] ans;

genvar i,j,k;

generate
for(i=0; i<C; i=i+1) begin :column
	for(j=0; j<R; j=j+1) begin :row
		assign matrix[i][j] = mtx[(i*R+j)*mtx_w +:mtx_w];
		assign shifted[i][j] = (matrix[i][j] == {mtx_w{1'b1}})?
			0:(dec[j*D +:D] >> matrix[i][j])|(dec[j*D +:D] << (D - matrix[i][j]));
		for(k=0; k<D; k=k+1) begin :rot
			assign rotated[i*D+k][j] = shifted[i][j][k];
			assign ans[i*D+k] = |rotated[i*D+k];
		end
	end
end
endgenerate

assign res = |ans;

endmodule

