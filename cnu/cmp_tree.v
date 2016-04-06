module cmp_tree(clk, rst, in, min, min2, min_idx);
parameter data_w = 8;
parameter idx_w = 8;
parameter D = 5;
localparam DD = (D & 1)?(D + 1):D;
localparam PL = ppl_l(DD>>1);

input clk, rst;
input [data_w*D-1:0] in;
output reg [data_w-1:0] min, min2;
output reg [idx_w-1:0] min_idx;

wire [data_w*2*(DD>>1)-1:0] pairs [PL:0];
wire [idx_w*2*(DD>>1)-1:0] m_idx [PL:0];
wire [(DD>>1)-1:0] cmp;

genvar i,j;
//--------------
generate
for(i=0; i<(D>>1); i=i+1) begin :generate_pairs
    assign cmp[i] = (in[data_w*2*i +:data_w] > in[data_w*(2*i+1) +:data_w]);
    assign pairs[0][i*2*data_w +:data_w*2] = cmp[i]?
        {in[data_w*2*i +:data_w], in[data_w*(2*i+1) +:data_w]}:
        {in[data_w*(2*i+1) +:data_w], in[data_w*2*i +:data_w]};
    assign m_idx[0][i*2*idx_w +:idx_w] = cmp[i]? (2*i):(2*i+1);
    assign m_idx[0][i*2*idx_w+idx_w +:idx_w] = cmp[i]? (2*i+1):(2*i);
end

if(D & 1) begin
    assign pairs[0][data_w*2*((DD>>1)-1) +:data_w*2]={{data_w{1'b1}}, in[data_w*(D-1) +:data_w]};
    assign m_idx[0][idx_w*2*((DD>>1)-1) +:idx_w]=D;
    assign m_idx[0][idx_w*2*((DD>>1)-1)+idx_w +:idx_w]=D-1;
end

for(i=0; i<PL; i=i+1) begin :pipeline
    for(j=0; (j+1)*2<=ppl_w(DD>>1, i); j=j+1) begin :merge_pairs
        compare #(.data_w(data_w), .idx_w(idx_w)) CP (
            .in(pairs[i][data_w*4*j +:data_w*4]),
            .idx_in(m_idx[i][idx_w*4*j +:idx_w*4]),
            .out(pairs[i+1][data_w*2*j +:data_w*2]),
            .idx_out(m_idx[i+1][idx_w*2*j +:idx_w*2])
        );
    end 

    if((ppl_w(DD>>1,i)& 1)==1) begin
        assign pairs[i+1][data_w*2*(ppl_w(DD>>1,i+1)-1) +:data_w*2] = pairs[i][data_w*2*(ppl_w(DD>>1,i)-1) +:data_w*2];
        assign m_idx[i+1][idx_w*2*(ppl_w(DD>>1,i+1)-1) +:idx_w*2] = m_idx[i][idx_w*2*(ppl_w(DD>>1,i)-1) +:idx_w*2];
    end 
end
endgenerate

always @(posedge clk or posedge rst) begin
    if(rst)begin
        min <= 0;
        min2 <= 0;
        min_idx <= 0;
    end
    else begin
        min <= pairs[PL][data_w-1:0];
        min_idx <= m_idx[PL][idx_w-1:0];
        min2 <= pairs[PL][data_w*2-1:data_w];
    end
end
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
        for(l=l; l>0; l=l-1) begin
            ppl_w = next_n(ppl_w);
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

