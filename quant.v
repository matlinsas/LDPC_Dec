module quant(snr_idx, frac_w, data_in, llr);
  parameter data_w = 5;
  
  input [3:0] snr_idx;
  input signed [4:0] frac_w;
  input signed [15:0] data_in;  // Q5,11
  output signed [data_w-1:0] llr;
  
  wire signed [data_w-1:0] llr_shift;
  wire signed [25:0] noise;  // Q5,21
  wire signed [17:0] one ={8'd1,{11{1'b0}}}; // Q7,11 = 1.000..
  wire signed [17:0] rec; // Q7,11
  wire signed [27:0] llr_temp; // Q17,11
  wire signed [27:0] llr_pmax; // Q17,11
  wire signed [27:0] llr_nmax; // Q17,11
  wire signed [27:0] llr_sat; // Q17,11
  wire signed [27:0] llr_div; // Q17,11
  wire [4:0] int_w;
  reg signed [10:0] sqrt_snr, snr;
  
  // SNR LUT
  always @* begin
    case (snr_idx)
      4'd0: sqrt_snr = 11'd913;
      4'd1: sqrt_snr = 11'd893;
      4'd2: sqrt_snr = 11'd872;
      4'd3: sqrt_snr = 11'd852;
      4'd4: sqrt_snr = 11'd832;
      4'd5: sqrt_snr = 11'd813;
      4'd6: sqrt_snr = 11'd795;
      4'd7: sqrt_snr = 11'd777;
      4'd8: sqrt_snr = 11'd759;
      4'd9: sqrt_snr = 11'd742;
	  default: sqrt_snr = 11'd725;
    endcase
    case (snr_idx)
      4'd0: snr = 11'd813;
      4'd1: snr = 11'd777;
      4'd2: snr = 11'd742;
      4'd3: snr = 11'd708;
      4'd4: snr = 11'd677;
      4'd5: snr = 11'd646;
      4'd6: snr = 11'd617;
      4'd7: snr = 11'd589;
      4'd8: snr = 11'd563;
      4'd9: snr = 11'd537;
	  default: snr = 11'd513;
    endcase
  end
  
  assign int_w = data_w - frac_w;
  assign noise = data_in * sqrt_snr;
  assign rec = one + {{2{noise[25]}}, noise[25:10]};
  assign llr_temp = ({{10{rec[17]}}, rec} <<< 11);
  assign llr_div = llr_temp[27] ? -(-llr_temp/snr):llr_temp/snr;
  assign llr_pmax = (1'd1 <<< (11 + int_w)) - 1;
  assign llr_nmax = ({28{1'd1}} <<< (11 + int_w));
  assign llr_sat = (llr_div < llr_pmax && llr_div > llr_nmax) ? llr_div:((llr_div[27])?llr_nmax:llr_pmax);
  assign llr_shift = llr_sat >>> (5'd11-frac_w);
  assign llr = frac_w[4] ? llr_shift <<< (-frac_w) : llr_shift;
  
  initial begin
    $monitor(
      "%b\n%b\n%d\n%d\n%d\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n%b\n",
      llr_pmax, llr_nmax, int_w, sqrt_snr, snr, data_in, noise, rec, llr_temp, llr_div, llr_sat, llr_shift, llr
    );
  end
        
endmodule

