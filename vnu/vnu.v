module vnu(l, r, q, dec);
parameter data_w = 6;
parameter D=3;
parameter ext_w = 3;
localparam sum_w = data_w + ext_w;
localparam TH = tree_h(D+1);

input 	[data_w-1:0] l;
input	[data_w*D-1:0] r;
output	[sum_w*D-1:0] q;
output	dec;

wire 	[sum_w-1:0] s;
wire 	[sum_w*(D+1)-1:0] tree[TH:0];

genvar i, j;

generate
for(i=0; i<D; i=i+1) begin :init
	assign tree[0][i*sum_w +:sum_w] = {{ext_w{r[(i+1)*data_w-1]}}, r[i*data_w +:data_w]};
end

assign tree[0][D*sum_w +:sum_w] = {{ext_w{l[data_w-1]}}, l};

for(i=0; i<TH; i=i+1) begin :csa_tree
	for(j=0; j<tree_w(D+1, i)-1; j=j+2)begin :add
	   assign tree[i+1][(j >> 1)*sum_w +:sum_w] = tree[i][j*sum_w +:sum_w] + tree[i][(j+1)*sum_w +:sum_w];
	end

	if(tree_w(D+1, i) & 1) begin
		assign tree[i+1][(tree_w(D+1, i+1)-1)*sum_w +:sum_w] = tree[i][(tree_w(D+1, i)-1)*sum_w +:sum_w];
	end
end

assign s = tree[TH][0 +:sum_w];

for(i=0; i<D; i=i+1)begin :calc_q
    assign q[i*sum_w +:sum_w] = s - tree[0][i*sum_w +:sum_w];
end
endgenerate

assign dec = s[sum_w-1];
//----------
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

