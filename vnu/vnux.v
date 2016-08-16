module vnu(l, r, q, dec);
parameter data_w = 6;
parameter D=6;
parameter ext_w = 3;
localparam sum_w = data_w + ext_w;

input 	[data_w-1:0] l;
input	[data_w*D-1:0] r;
output	[sum_w*D-1:0] q;
output	dec;

wire 	[sum_w-1:0] s, sta, stb;

genvar i;
generate
if(D == 2) begin
    assign q[sum_w*0 +:sum_w] = l + r[data_w*1 +:data_w];
    assign q[sum_w*1 +:sum_w] = l + r[data_w*0 +:data_w];
    assign s = l + r[data_w*1 +:data_w] + r[data_w*0 +:data_w];
end

if(D == 3) begin
    assign q[sum_w*0 +:sum_w] = l + r[data_w*1 +:data_w] + r[data_w*2 +:data_w];
    assign q[sum_w*1 +:sum_w] = l + r[data_w*0 +:data_w] + r[data_w*2 +:data_w];
    assign q[sum_w*2 +:sum_w] = l + r[data_w*0 +:data_w] + r[data_w*1 +:data_w];
    assign s = q[sum_w*0 +:sum_w] + r[data_w*0 +:data_w];
end

if(D == 6) begin
    assign sta = r[data_w*0 +:data_w] + r[data_w*1 +:data_w] + r[data_w*2 +:data_w];
    assign stb = r[data_w*3 +:data_w] + r[data_w*4 +:data_w] + r[data_w*5 +:data_w];
    assign s = sta + stb + l;
    for (i=0; i<D; i=i+1) begin :calc_q
        assign q[i*sum_w +:sum_w] = s - r[i*data_w +:data_w];
    end
end



endgenerate

assign dec = s[sum_w-1];

endmodule

