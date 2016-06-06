module quant(snr_idx, frac_w, data_in, llr);
  parameter data_w = 6;
  
  input [3:0] snr_idx;
  input [4:0] frac_w;
  input [15:0] data_in;  // Qs5,11 -> Qs0,15
  output [data_w-1:0] llr;
  
  wire [25:0] noise;  // Qs0,25
  wire [17:0] one ={3'b0,{15{1'b1}}}; // Qs2,15 = 0.999..
  wire [17:0] rec; // Qs2,15
  wire [27:0] llr_temp; // Qs12,15
  wire [27:0] llr_pmax; // Qs12,15
  wire [27:0] llr_nmax; // Qs12,15
  wire [27:0] llr_sat; // Qs12,15
  wire [4:0] int_w;
  reg [9:0] sqrt_snr, snr;
  
  // SNR LUT
  always @* begin
    case (snr_idx)
      4'd0: sqrt_snr = 10'd913;
      4'd1: sqrt_snr = 10'd892;
      4'd2: sqrt_snr = 10'd872;
      4'd3: sqrt_snr = 10'd852;
      4'd4: sqrt_snr = 10'd832;
      4'd5: sqrt_snr = 10'd813;
      4'd6: sqrt_snr = 10'd795;
      4'd7: sqrt_snr = 10'd777;
      4'd8: sqrt_snr = 10'd759;
      4'd9: sqrt_snr = 10'd742;
	  default: sqrt_snr = 10'd725;
    endcase
    case (snr_idx)
      4'd0: snr = 10'd813;
      4'd1: snr = 10'd777;
      4'd2: snr = 10'd742;
      4'd3: snr = 10'd708;
      4'd4: snr = 10'd677;
      4'd5: snr = 10'd646;
      4'd6: snr = 10'd617;
      4'd7: snr = 10'd589;
      4'd8: snr = 10'd563;
      4'd9: snr = 10'd537;
	  default: snr = 10'd513;
    endcase
  end
  
  assign int_w = data_w - frac_w;
  assign noise = data_in * sqrt_snr;
  assign rec = one + {{2{noise[25]}}, noise[25:10]};
  assign llr_temp = ({{10{rec[17]}}, rec} <<< 11)/snr;
  assign llr_pmax = (1'd1 <<< (15 + int_w)) - 1;
  assign llr_nmax = ({28{1'd1}} <<< (15 + int_w));
  assign llr_sat =
    ((llr_temp[27:14+int_w]=={13-int_w{1'b0}}) ||
     (llr_temp[27:14+int_w]=={13-int_w{1'b1}}))?
    llr_temp:((llr_temp[27])?llr_nmax:llr_pmax);
  assign llr = llr_sat >>> (15-frac_w);
        
endmodule

