//fake core for test
module ldpc_core(en, clk, rst, sig, mtx, res, status);
parameter data_w = 5;
parameter mtx_w = 8;
parameter R = 24;
parameter C = 12;
parameter D = 96;
parameter N = 6;

input clk, rst, en;
input [R*D*data_w-1:0] sig;
input [C*R*mtx_w-1:0] mtx;
output reg [1:0] status;
output reg [R*D-1:0] res;

reg [10:0] count;

always @* begin
    res <= 0;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        status <= 2'd0;
        count <= 11'd0;
    end else begin
        if(count[10]) begin
            count <= 11'd0;
            status <= 2'd1;
        end else begin
            count <= count + 1'b1;
            status <= 2'd0;
        end
    end
end

endmodule
