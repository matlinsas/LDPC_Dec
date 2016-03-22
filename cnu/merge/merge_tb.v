module tb;
  parameter data_w = 8;
  parameter D =22;
  reg [data_w*D-1:0] n;
  wire [data_w-1:0] f1,f2;
  reg clk, rst;
  reg [8:0] cnt;
  
  merge_ppl #(.D(D)) MP (clk, rst, n, f1, f2);
  
  initial begin
    clk = 0;
    cnt = 0;
    rst = 1;
    #10 rst = 0;
    n = 0;
    #10 n={8'h83,8'hdf,8'h79,8'hfb,8'h96,8'h75,8'he0,8'hcb,8'h11,8'ha4,8'hf8,8'heb,8'h21,8'h37,8'h30,8'h79,8'h22,8'h2d,8'ha7,8'hf1,8'h62,8'h6b,8'h03};
    //#10 n={8'd36,8'd14,8'd54,8'd34,8'd34,8'd92,8'd233};//,8'd1};
    //#10 n={8'd85,8'd33,8'd58,8'd37,8'd20,8'd65,8'd54};//,8'd23};
 //   #10 n = {8'd123,8'd0,8'd25,8'd15,8'd22,8'd11,8'd4,8'd2,8'd3,8'd1};
   // #10 n = {8'd123,8'd0,8'd22,8'd11,8'd25,8'd15,8'd9,8'd6,8'd3,8'd2};
    //#10 n = {8'd123,8'd0,8'd25,8'd15,8'd22,8'd11,8'd22,8'd11,8'd25,8'd15};
    //#10 n = {8'd123,8'd0,8'd22,8'd11,8'd25,8'd15,8'd88,8'd77,8'd99,8'd66};
    #80 $finish;
  end
  
  always
    #5 clk <= !clk;
  
  always
    #10 cnt = cnt + 1;
 
  initial  begin
    $dumpfile ("merge_N.vcd"); 
    $dumpvars; 
    $display("\t\ttime,\tcnt,\tclk,\trst,\tf5,\tf4,\tf3,\tf2,\tf1,\tf0"); 
    //$monitor("%d,\t%b,\t%b,\t%d,\t%d,\t%d,\t%d,\t%d,\t%d",$time,clk,rst,f[47:40],f[39:32],f[31:24],f[23:16],f[15:8], f[7:0]); 
    $monitor("%d,\t%d,\t%b,\t%b,\t%h,\t%h",$time,cnt,clk,rst,f1,f2); 
  end 
  
endmodule