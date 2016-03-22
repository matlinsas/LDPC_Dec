module merge_ppl(clk, rst, in, min, min2, min_idx);
parameter data_w = 8;
parameter idx_w = 8;
parameter D = 5;
localparam DD = (D & 1)?(D+1):D;

input clk, rst;
input [data_w*D-1:0] in;
output [data_w-1:0] min, min2;
output [idx_w-1:0] min_idx;

wire [data_w*2*(DD>>1)-1:0] pairs [ppl_l(DD>>1):0];
wire [idx_w*2*(DD>>1)-1:0] m_idx [ppl_l(DD>>1):0];
wire [(DD>>1)-1:0] cmp;

genvar i;
//--------------
generate

for(i=0; i<(D>>1); i=i+1) begin :generate_pairs
	assign cmp[i] = (in[data_w*2*i +:data_w] > in[data_w*(2*i+1) +:data_w]);
	assign pairs[0][i*2*data_w +:data_w*2] = cmp[i]?
		{in[data_w*2*i +:data_w], in[data_w*(2*i+1) +:data_w]}:
		{in[data_w*(2*i+1) +:data_w], in[data_w*2*i +:data_w]};
	assign m_idx[0][i*2*idx_w +:idx_w*2] = cmp[i]?{2*i, 2*i+1}:{2*i+1, 2*i};
end

if(D & 1) begin
	assign pairs[0][data_w*2*((DD>>1)-1) +:data_w*2]={{data_w{1'b1}}, in[data_w*(D-1) +:data_w]};
	assign m_idx[0][idx_w*2*((DD>>1)-1) +:idx_w*2]={D, D-1};
end

for(i=0; i<ppl_l(DD>>1); i=i+1) begin :pipeline
	merge_N #(.Pin(ppl_w(DD>>1, i)), .data_w(data_w), .idx_w(idx_w)) MN (
		.clk(clk),
		.rst(rst),
		.in(pairs[i]),
		.idx_in(m_idx[i]),
		.out(pairs[i+1]),
		.idx_out(m_idx[i+1])
	);
end
endgenerate

assign min2 = pairs[ppl_l(DD>>1)][data_w*2-1:data_w];
assign min = pairs[ppl_l(DD>>1)][data_w-1:0];
assign min_idx = m_idx[ppl_l(DD>>1)][idx_w-1:0];
//------------
function integer next_n;
	input integer n;
	begin
		next_n = (n >> 1) + (n & 1);
	end
endfunction

function integer ppl_w;
	input integer n, l;
	begin
		ppl_w = n;
		while(ppl_w>1 && l>0) begin
			ppl_w = next_n(ppl_w);
			l = l - 1;
		end
	end
endfunction

function integer ppl_l;
	input integer n;
	begin
		ppl_l = 0;
		while(n>1) begin
			n = next_n(n);
			ppl_l = ppl_l + 1;
		end
	end
endfunction

endmodule

