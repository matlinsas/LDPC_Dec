`ifdef SIMULATION
    `include "cmp.v"
`endif

(* bram_map="yes" *)

module cmp_tree(en, clk, rst, in, min, min2, min_idx);
parameter data_w = 9;
parameter idx_w = 3;
parameter D = 7;
localparam DD = (D & 1)?(D + 1):D;
localparam TH = tree_h(DD>>1);

input clk, rst, en;
input [data_w*D-1:0] in;
output reg [data_w-1:0] min, min2;
output reg [idx_w-1:0] min_idx;

wire [data_w*2*(DD>>1)-1:0] pairs [TH:0];
wire [idx_w*2*(DD>>1)-1:0] m_idx [TH:0];
wire [(DD>>1)-1:0] cmp;

genvar i,j;
//--------------
generate
for(i=0; i<(D>>1); i=i+1) begin :generate_pairs
    assign cmp[i] = (in[data_w*2*i +:data_w] > in[data_w*(2*i+1) +:data_w]);
    assign pairs[0][i*2*data_w +:data_w*2] = cmp[i]?
        {in[data_w*2*i +:data_w], in[data_w*(2*i+1) +:data_w]}:
        {in[data_w*(2*i+1) +:data_w], in[data_w*2*i +:data_w]};
    assign m_idx[0][i*2*idx_w +:idx_w] = cmp[i]? (2*i+1):(2*i);
    assign m_idx[0][i*2*idx_w+idx_w +:idx_w] = cmp[i]? (2*i):(2*i+1);
end

if(D & 1) begin
    assign pairs[0][data_w*2*((DD>>1)-1) +:data_w*2]={1'b0,{data_w-1{1'b1}}, in[data_w*(D-1) +:data_w]};
    assign m_idx[0][idx_w*2*((DD>>1)-1) +:idx_w]=D-1;
    assign m_idx[0][idx_w*2*((DD>>1)-1)+idx_w +:idx_w]=D;
end

for(i=0; i<TH; i=i+1) begin :build_tree
    for(j=0; (j+1)*2<=tree_w(DD>>1, i); j=j+1) begin :cmp_pairs
        compare #(.data_w(data_w), .idx_w(idx_w)) CP (
            .in(pairs[i][data_w*4*j +:data_w*4]),
            .idx_in(m_idx[i][idx_w*4*j +:idx_w*4]),
            .out(pairs[i+1][data_w*2*j +:data_w*2]),
            .idx_out(m_idx[i+1][idx_w*2*j +:idx_w*2])
        );
    end 

    if((tree_w(DD>>1,i)& 1)==1) begin
        assign pairs[i+1][data_w*2*(tree_w(DD>>1,i+1)-1) +:data_w*2] = pairs[i][data_w*2*(tree_w(DD>>1,i)-1) +:data_w*2];
        assign m_idx[i+1][idx_w*2*(tree_w(DD>>1,i+1)-1) +:idx_w*2] = m_idx[i][idx_w*2*(tree_w(DD>>1,i)-1) +:idx_w*2];
    end 
end
endgenerate

always @(posedge clk) begin
    if(rst)begin
        min <= 0;
        min2 <= 0;
        min_idx <= 0;
    end
    else if(en) begin
        min <= pairs[TH][data_w-1:0];
        min_idx <= m_idx[TH][idx_w-1:0];
        min2 <= pairs[TH][data_w*2-1:data_w];
    end
end
//------------
function integer next_n;
    input integer n;
    begin
        next_n = (n >> 1) + (n & 1);
    end
endfunction

function integer tree_w;
    input integer n, l;
    begin
        tree_w = n;
        for(l=l; l>0; l=l-1) begin
            tree_w = next_n(tree_w);
        end
    end
endfunction

function integer tree_h;
    input integer n;
    begin
        tree_h = 0;
        while(n>1) begin
            n = next_n(n);
            tree_h = tree_h + 1;
        end
    end
endfunction
	
endmodule

