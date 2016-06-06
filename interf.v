module interf(clk, rst, mtx, snr_idx, frac_w);
  parameter data_w = 5;
  parameter mtx_w = 8;
  parameter R = 24;
  parameter C = 12;
  parameter D = 96;
  parameter N = 6;
  localparam dim=R*D;
  localparam len=dim*data_w;
  
  input clk, rst;
  input [3:0] snr_idx;
  input [4:0] frac_w;
  input [C*R*mtx_w-1:0] mtx;
  wire valid_out;
  wire [15:0] data_out;
  wire [data_w-1:0] llr;
  wire [dim-1:0] res;
  wire term;
  wire ldpc_en;
  reg [len:0] buff;
  
  gng u_gng(
    .clk(clk), 
    .rstn(~rst), 
    .ce(~buff[len]), 
    .valid_out(valid_out), 
    .data_out(data_out)
  );
  
  dpc_core #(
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
  
  assign ldpc_en = buff[len] | ~term;
  
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
endmodule

