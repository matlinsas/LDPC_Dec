`ifdef SIMULATION
    `include "cnu/cnu.v"
    `include "vnu/vnu.v"
    `include "cyc_shift.v"
    `include "check.v"
`endif

module ldpc_core(en, clk, rst, l, mtx, res, term, err);
parameter data_w = 5;
parameter mtx_w = 8;
parameter R = 24;
parameter C = 12;
parameter D = 96;
parameter N = 6;
localparam ext_w = log2(N);
localparam idx_w = log2(R);
localparam temp_w = data_w + ext_w;
localparam count_w = 6;

input clk, rst, en;
input [R*D*data_w-1:0] l;
input [C*R*mtx_w-1:0] mtx;
output reg term;
output reg err;
output reg [R*D-1:0] res;

reg [count_w-1:0] count;

wire check;
wire [R*D-1:0] dec;
wire [data_w*D-1:0] ctv [C-1:0][R-1:0];
wire [temp_w*D-1:0] vtc [C-1:0][R-1:0];
wire [data_w*D-1:0] v [C-1:0][R-1:0];
wire [temp_w*D-1:0] c [C-1:0][R-1:0];
wire [temp_w*R-1:0] c_ibus [C*D-1:0];
wire [data_w*R-1:0] c_obus [C*D-1:0];
wire [data_w*C-1:0] v_ibus [R*D-1:0];
wire [temp_w*C-1:0] v_obus [R*D-1:0];
//wire signed [temp_w-1:0] test_bus[R*D-1:0];

genvar i,j,k;

generate
for(i=0; i<C; i=i+1) begin :column
	for(j=0; j<R; j=j+1) begin :row
		cyc_shift #(.D(D), .data_w(data_w), .ext_w(ext_w), .mtx_w(mtx_w)) CYC(
			.shift(mtx[(i*R+j)*mtx_w +:mtx_w]),
			.vtc(vtc[i][j]),
			.c(c[i][j]),
			.ctv(ctv[i][j]),
			.v(v[i][j])
		);

		for(k=0; k<D; k=k+1) begin :bus_mapping
			assign vtc[i][j][k*temp_w +:temp_w] = v_obus[j*D+k][i*temp_w +:temp_w];
			assign v_ibus[j*D+k][i*data_w +:data_w] = v[i][j][k*data_w +:data_w];
			assign ctv[i][j][k*data_w +:data_w] = c_obus[i*D+k][j*data_w +:data_w];
			assign c_ibus[i*D+k][j*temp_w +:temp_w] = c[i][j][k*temp_w +:temp_w];
		end
	end
end

for(j=0; j<C*D; j=j+1024) begin :iter0
	for(i=j; i<( (j+1024<C*D)?(j+1024):(C*D) ); i=i+1) begin :cnu_array
		cnu #(.res_w(data_w), .ext_w(ext_w), .D(R), .idx_w(idx_w)) CNU (
			.en(en),
			.clk(clk),
			.rst(rst),
			.q(c_ibus[i]),
			.r(c_obus[i])
		);
	end
end

for(j=0; j<R*D; j=j+1024) begin :iter1
	for(i=j; i<( (j+1024<R*D)?(j+1024):(R*D) ); i=i+1) begin :vnu_array
		vnu #(.data_w(data_w), .D(C), .N(N), .ext_w(ext_w)) VNU (
			.l(l[i*data_w +:data_w]),
			.r(v_ibus[i]),
			.q(v_obus[i]),
			.dec(dec[i])
            //.test(test_bus[i])
		);
	end
end
endgenerate

check #(.mtx_w(mtx_w), .C(C), .R(R), .D(D)) CH (.dec(dec), .mtx(mtx), .res(check));

always @(posedge clk) begin
	if(rst) begin
		res <= 0;
		err <= 0;
		count <= 0;
		term <= 1'b0;
    end else begin
        if(en) begin
            count <= count + 1'b1;
            if(count[count_w-1] || ~check) begin
                res <= dec;
				err <= check;
                term <= 1'b1;
            end
        end
    end
end

//------------------------------------------

function integer log2;
    input integer x;
    begin
        log2 = 0;
        while (x) begin
            log2 = log2 + 1;
            x = x>>1;
        end
    end
endfunction

//---------------- TEST -----------------------
/*
integer ones, idx, f1;
initial begin
    f1 = $fopen("vnu_out.txt","w");
end
always @* begin
    ones = 0;
    for (idx =0; idx < (D*R); idx = idx +1) begin
        ones = ones + dec[idx];
    end
end
always @(posedge clk) begin
    for (idx=0; idx < (D*R); idx = idx + 1) begin
        $fwrite(f1, "%d ", test_bus[idx]);
    end
    $fwrite(f1, "\n");
end
*/

endmodule

