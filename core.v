`include "cnu.v"
`include "vnu.v"
`include "check.v"
`include "cyc_shift.v"

module ldpc_core(en, clk, rst, sig, mtx, res, status);
parameter data_w = 8;
parameter R = 24;
parameter C = 12;
parameter D = 24;

input clk, rst, en;
input [R*D*data_w-1:0] sig;
input [C*R*data_w-1:0] mtx;
output reg [1:0] status;
output reg [R*D-1:0] res;

reg term;
reg [R*D*data_w-1:0] l;
reg [data_w:0] count;

wire check;
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
			.shift(mtx[(i*R+j)*data_w +:data_w]),
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
        .en(en),
		.clk(clk),
		.rst(rst | term),
		.q(c_ibus[i]),
		.r(c_obus[i])
	);
end

for(i=0; i<R*D; i=i+1) begin :vnu_array
	vnu #(.data_w(data_w), .D(C)) VNU (
		.l(l[i*data_w +:data_w]),
		.r(v_ibus[i]),
		.q(v_obus[i]),
		.dec(dec[i])
	);
end
endgenerate

check #(.data_w(data_w), .C(C), .R(R), .D(D)) CH (.dec(dec), .mtx(mtx), .res(check));

always @(posedge clk or posedge rst or posedge term) begin
	if(rst) begin
		l <= sig;
		res <= 0;
		count <= 0;
		term <= 1'b0;
		status <= 2'b0;
	end else if(term)begin
        if(en) begin
            l <= sig;
            count <= 0;
            term <= 1'b0;
        end
	end else begin
        if(en) begin
            count <= count + 1'b1;
            status <= {count[data_w], ~check};
            if(count[data_w] || ~check) begin
                res <= dec;
                term <= 1'b1;
            end
        end
    end
end
endmodule

