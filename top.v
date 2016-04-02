module top(clk, rst, l_in, mtx_in, dec);
parameter data_w = 8;
parameter R = 32;
parameter C = 16;
parameter D = 64;

input clk, rst;
input [R*D-1:0] l_in;
input [data_w*C*R-1:0] mtx_in;
output [R*D-1:0] dec;

wire [R*D-1:0] dec;
wire [data_w*D-1:0] ctv [C-1:0][R-1:0];
wire [data_w*D-1:0] vtc [C-1:0][R-1:0];
wire [data_w*D-1:0] v [C-1:0][R-1:0];
wire [data_w*D-1:0] c [C-1:0][R-1:0];
wire [data_w*R-1:0] c_ibus [C*D-1:0];
wire [data_w*R-1:0] c_obus [C*D-1:0];
wire [data_w*C-1:0] v_ibus [R*D-1:0];
wire [data_w*C-1:0] v_obus [R*D-1:0];

reg set;
reg [R*D-1:0] l;
reg [data_w-1:0] mtx [C-1:0][R-1:0];

genvar i,j,k;

integer it_i, it_j;

always @(posedge rst) begin
	set <= 1;
end

always @(posedge set) begin
l <= l_in;
for(it_i=0; it_i<C; it_i=it_i+1) begin
	for(it_j=0; it_j<R; it_j=it_j+1) begin
		mtx[it_i][it_j] <= mtx_in[it_i*R+it_j +:data_w];
	end
end
end

generate
for(i=0; i<C; i=i+1) begin :column
    for(j=0; j<R; j=j+1) begin :row
		cyc_shift #(.D(D), .data_w(data_w)) CYC(
			.shift(8'b0),//mtx[i][j]),
			.vtc(vtc[i][j]),
			.c(c[i][j]),
			.ctv(ctv[i][j]),
			.v(v[i][j])
		);

		for(k=0; k<D; k=k+1) begin :bus_mapping
			assign vtc[i][j][k*data_w +:data_w] = v_obus[j*D+k][i*data_w +:data_w];
			assign v_ibus[j*D+k][i*data_w +:data_w] = v[i][j][k*data_w +:data_w];
			assign ctv[i][j][k*data_w +:data_w] = c_obus[i*D+k][j*data_w +:data_w];
			assign c_ibus[i*D+k][j*data_w +:data_w] = c[i][j][k*data_w +:data_w];
		end
    end
end

for(i=0; i<C*D; i=i+1) begin :cnu_array
	cnu #(.data_w(data_w), .D(R)) CNU (
		.clk(clk),
		.rst(rst),
		.q(c_ibus[i]),
		.r(c_obus[i])
	);
end

for(i=0; i<R*D; i=i+1) begin :vnu_array
	vnu #(.data_w(data_w), .D(C)) VNU (
		.l(1'b0),//l[i]),
		.r(v_ibus[i]),
		.q(v_obus[i]),
		.dec(dec[i])
	);
end
endgenerate

endmodule
