//fake core for test
module ldpc_core(en, clk, rst, sig, mtx, res, term);
parameter data_w = 5;
parameter mtx_w = 8;
parameter R = 24;
parameter C = 12;
parameter D = 96;
parameter N = 6;

input clk, rst, en;
input [R*D*data_w-1:0] sig;
input [C*R*mtx_w-1:0] mtx;
output reg  term;
output reg [R*D-1:0] res;

reg [3:0] count;

always @* begin
    res = 0;
end

always @(posedge clk or posedge rst) begin
    if(rst) begin
        term <= 1'b0;
        count <= 0;
    end else if (en) begin
        if(count[3]) begin
            count <= 0;
            term <= 1'b1;
        end else begin
            count <= count + 1'b1;
            term <= 1'b0;
        end
    end
end

endmodule
