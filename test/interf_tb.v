`define SIMULATION

module tb;
reg clk, rst;
wire [11:0] errs;
localparam ClkPeriod = 10;

interf U(
    .clk(clk),
    .rst(rst),
    .errs(errs)
);

initial begin
    clk <= 1'b0;
    forever #(ClkPeriod/2) clk = ~clk;
end

initial begin
    rst <= 1'b1;
    #(ClkPeriod*2) rst = 1'b0;
end

endmodule

