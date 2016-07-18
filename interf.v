`ifdef SIMULATION
    `include "core.v"
    //`include "test/test_core.v"
    `include "quant.v"
    `include "gng/gng.v"
`endif

module interf(clk, rst, errs);
parameter data_w = 5;
parameter mtx_w = 8;
parameter R = 24;
parameter C = 12;
parameter D = 96;
parameter N = 6;
parameter buff_len = 18;
parameter buff_num = 128;
localparam dim = R*D;
localparam len = buff_len*data_w;

input clk, rst;
output [11:0] errs;

wire [C*R*mtx_w-1:0] mtx;
wire [buff_num-1:0] valid_out;
wire signed [15:0] data_out [buff_num-1:0];
wire signed [data_w-1:0] llr [buff_num-1:0];
wire [dim-1:0] res;
wire term;
wire [dim*data_w-1:0] sig;
wire [buff_num-1:0] gen_term;

reg ldpc_en;
reg ldpc_rst;
reg [dim*data_w-1:0] llr_sig;
reg [len:0] buff [buff_num-1:0];
reg [3:0] snr_idx;
reg signed [4:0] frac_w;

genvar i;

ldpc_core #(
    .C(C), .R(R), 
    .D(D), .N(N), 
    .data_w(data_w), 
    .mtx_w(mtx_w)
) LDPC(
    .en(ldpc_en), 
    .clk(clk), 
    .rst(ldpc_rst), 
    .l(llr_sig), 
    .mtx(mtx), 
    .res(res), 
    .term(term)
);

generate
for(i=0; i<buff_num; i=i+1) begin:sig_gen
    gng u_gng(
        .clk(clk), 
        .rstn(~rst), 
        .ce(~buff[i][len]), 
        .valid_out(valid_out[i]), 
        .data_out(data_out[i])
    );

    quant #(.data_w(data_w)) QNT (
        .snr_idx(snr_idx),
        .frac_w(frac_w),
        .data_in(data_out[i]),
        .llr(llr[i])
    );

    always @(posedge clk or posedge rst) begin
        if(rst) begin
            buff[i] <= 1;
            ldpc_rst <= 1;
            llr_sig <= 0;
        end
        else begin
            if(valid_out[i] && ~buff[i][len]) begin
                buff[i] <= (buff[i]<<data_w) | llr[i];
            end

            if(term) begin
                if(&gen_term) begin
                    ldpc_rst <= 1'b1;
                    ldpc_en <= 1'b1;
                    llr_sig <= sig;
                    buff[i] <= 1;
                end
                else ldpc_en <= 1'b0;
            end
            else begin
                ldpc_rst <= 1'b0;
                ldpc_en <= 1'b1;
            end
        end
    end

    assign gen_term[i] = buff[i][len];
    assign sig[i*len +:len] = buff[i][len-1:0];

end
endgenerate

always @(clk) begin
    snr_idx <= 4'd10;
    frac_w <= -5'd1;
end

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
    //$monitor("%d\t%d", snr_idx, frac_w);
    $monitor("%b\t%d\t%b", data_out[0], llr[0], buff[0]);
end
always @(posedge term) begin
    #1000 $finish;
end

endmodule

