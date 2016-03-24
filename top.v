module top();
parameter data_w = 8;
parameter R = 5;
parameter C = 3;
parameter D = 8;

input clk, rst;

wire [R*D-1:0] dec;
wire [data_w*D-1:0] ctv [C-1:0][R-1:0];
wire [data_w*D-1:0] vtc [C-1:0][R-1:0];
wire [data_w*D-1:0] v [C-1:0][R-1:0];
wire [data_w*D-1:0] c [C-1:0][R-1:0];
wire [data_w*R-1:0] c_ibus [C*D-1:0];
wire [data_w*R-1:0] c_obus [C*D-1:0];
wire [data_w*C-1:0] v_ibus [R*D-1:0];
wire [data_w*C-1:0] v_obus [R*D-1:0];

genvar i,j,k;

generate
for(i=0; i<C; i=i+1) begin :column
    for(j=0; j<R; j=j+1) begin :row
		cyc_shift #(.D(D), .data_w(data_w)) CYC(
			.clk(clk),
			.rst(rst),
			.shift(mtx[i][j]),
			.vtc(vtc[i][j]),
			.c(c[i][j]),
			.ctv(ctv[i][j]),
			.v(v[i][j])
		);

		for(k=0; k<D; k=k+1) begin :bus_mapping
			assign vtc[i][j][k*data_w +:data_w] = v_obus[(j+1)*(k+1)-1][i*data_w +:data_w];
			assign v_ibus[(j+1)*(k+1)-1][i*data_w +:data_w] = v[i][j][k*data_w +:data_w];
			assign ctv[i][j][k*data_w +:data_w] = c_obus[(i+1)*(k+1)-1][j*data_w +:data_w];
			assign c_ibus[(i+1)*(k+1)-1][j*data_w +:data_w] = c[i][j][k*data_w +:data_w];
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

for(i=0; i<C*D; i=i+1) begin :vnu_array
	vnu #(.data_w(data_w), .D(C)) VNU (
		.clk(clk),
		.rst(rst),
		.l(),
		.r(v_obus[i]),
		.q(v_ibus[i]),
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

for(i=0; i<C*D; i=i+1) begin :vnu_array
	vnu #(.data_w(data_w), .D(C)) VNU (
		.clk(clk),
		.rst(rst),
		.l(),
		.r(v_obus[i]),
		.q(v_ibus[i]),
		.dec(dec[i])
	);
end

endgenerate

endmodule
