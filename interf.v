`ifdef SIMULATION
    //`include "core.v"
    `include "test/test_core.v"
    `include "quant.v"
`endif

module interf(clk, rst, errs);
parameter data_w = 5;
parameter mtx_w = 8;
parameter R = 24;
parameter C = 12;
parameter D = 96;
parameter N = 6;
localparam dim=R*D;
localparam len=dim*data_w;

input clk, rst;
output [11:0] errs;

wire [C*R*mtx_w-1:0] mtx;
wire valid_out;
wire signed [15:0] data_out;
wire signed [data_w-1:0] llr;
wire [dim-1:0] res;
wire term;
wire ldpc_en;

reg [len:0] buff;
reg [3:0] snr_idx;
reg signed [4:0] frac_w;

gng u_gng(
    .clk(clk), 
    .rstn(~rst), 
    .ce(~buff[len]), 
    .valid_out(valid_out), 
    .data_out(data_out)
);

ldpc_core #(
    .C(C), .R(R), 
    .D(D), .N(N), 
    .data_w(data_w), 
    .mtx_w(mtx_w)
) LDPC(
    .en(ldpc_en), 
    .clk(clk), 
    .rst(rst), 
    .sig(buff[len-1:0]), 
    .mtx(mtx), 
    .res(res), 
    .term(term)
);

quant #(.data_w(data_w)) QNT (
    .snr_idx(snr_idx),
    .frac_w(frac_w),
    .data_in(data_out),
    .llr(llr)
);


always @(posedge clk) begin
    if(rst) begin
        buff <= 1;
    end
    else begin
        if(valid_out) begin
            buff <= (buff<<data_w) | llr;
        end
        if(buff[len] & term) begin
            buff <= 1;
        end
    end
end

always @* begin
    snr_idx <= 4'd10;
    frac_w <= -5'd1;
end

assign ldpc_en = buff[len] | ~term;
assign mtx={
    8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd7,8'd26,-8'd1,-8'd1,-8'd1,8'd41,-8'd1,8'd66,-8'd1,-8'd1,-8'd1,-8'd1,8'd43,
    8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd49,8'd39,-8'd1,-8'd1,-8'd1,-8'd1,8'd65,8'd7,-8'd1,-8'd1,
    -8'd1,8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd72,8'd70,-8'd1,-8'd1,8'd59,-8'd1,8'd94,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,
    -8'd1,-8'd1,8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd51,-8'd1,-8'd1,-8'd1,8'd43,-8'd1,8'd24,8'd83,-8'd1,-8'd1,-8'd1,8'd12,
    -8'd1,-8'd1,-8'd1,8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd47,-8'd1,-8'd1,8'd2,-8'd1,-8'd1,-8'd1,8'd73,8'd11,-8'd1,
    -8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd18,8'd14,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd53,8'd95,-8'd1,-8'd1,
    -8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd79,-8'd1,-8'd1,-8'd1,8'd82,-8'd1,8'd40,8'd46,-8'd1,-8'd1,-8'd1,-8'd1,
    -8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd72,8'd41,-8'd1,-8'd1,8'd84,-8'd1,-8'd1,-8'd1,8'd39,-8'd1,-8'd1,
    -8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd0,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd25,8'd65,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd47,-8'd1,8'd61,
    -8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd0,-8'd1,-8'd1,8'd0,-8'd1,-8'd1,-8'd1,8'd33,-8'd1,8'd81,8'd22,8'd24,-8'd1,-8'd1,-8'd1,
    -8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd0,-8'd1,8'd12,-8'd1,-8'd1,-8'd1,8'd9,8'd79,8'd22,-8'd1,-8'd1,-8'd1,8'd27,-8'd1,
    -8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd0,8'd7,-8'd1,-8'd1,8'd83,8'd55,-8'd1,-8'd1,-8'd1,-8'd1,-8'd1,8'd73,8'd94,-8'd1
};

//-------test---------
initial begin
    $monitor("%d\t%d\t%b\n", data_out, llr, buff);
end

endmodule

