`define SIMULATION

module tb;
reg clk, rst;
wire [11:0] errs;

interf U(
    .clk(clk),
    .rst(rst),
    .errs(errs)
);

initial begin
    clk = 1'b0;
    rst = 1'b0;
    #50 rst = 1'b1;
    #50 rst = 1'b0;
end
forever #10 clk <= ~clk;

endmodule

