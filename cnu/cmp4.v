module cmp4(in, idx_in, out, idx_out);
parameter data_w = 9;
parameter idx_w = 3;

input [data_w*4-1:0] in;
input [idx_w*2-1:0] idx_in;
output reg [data_w*2-1:0] out;
output reg [idx_w-1:0] idx_out;

wire [2:0] cc;

assign cc[0] = (in[0 +:data_w]<in[2*data_w +:data_w]);
assign cc[1] = (in[data_w +:data_w]<in[2*data_w +:data_w]) & cc[0];
assign cc[2] = (in[0 +:data_w]<in[3*data_w +:data_w]) | cc[0];

always @(*) begin
    case (cc)
        3'b111: begin
                    out = {in[data_w +:data_w], in[0 +:data_w]};
                    idx_out = idx_in[0 +:idx_w];
                end
        3'b101: begin
                    out = {in[2*data_w +:data_w], in[0 +:data_w]};
                    idx_out = idx_in[0 +:idx_w];
                end
        3'b100: begin
                    out = {in[0 +:data_w], in[2*data_w +:data_w]};
                    idx_out = idx_in[idx_w +:idx_w];
                end
        default: begin
                    out = {in[3*data_w +:data_w], in[2*data_w +:data_w]};
                    idx_out = idx_in[idx_w +:idx_w];
                end
    endcase
end

endmodule
