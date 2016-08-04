`ifdef SIMULATION
    `include "fadd.v"
`endif
module vnu(l, r, q, dec);//,test);
parameter data_w = 8;
parameter D=12;
parameter ext_w = 3;
localparam sum_w = data_w + ext_w;
localparam TH = tree_h(D+1);

input 	[data_w-1:0] l;
input	[data_w*D-1:0] r;
output	[sum_w*D-1:0] q;
output	dec;
//output  [sum_w-1:0] test;

wire 	[sum_w-1:0] s;
wire 	[sum_w*(D+1)-1:0] tree[TH:0];

genvar i, j;

generate
for(i=0; i<D; i=i+1) begin :init
	assign tree[0][i*sum_w +:sum_w] = {{ext_w{r[(i+1)*data_w-1]}}, r[i*data_w +:data_w]};
end

assign tree[0][D*sum_w +:sum_w] = {{ext_w{l[data_w-1]}}, l};

for(i=0; i<TH; i=i+1) begin :csa_tree
	for(j=2; j<tree_w(D+1, i); j=j+3)begin :add
		fadd #(.data_w(sum_w)) FA (
			.A(tree[i][j*sum_w +:sum_w]),
			.B(tree[i][(j-1)*sum_w +:sum_w]),
			.Ci(tree[i][(j-2)*sum_w +:sum_w]),
			.S(tree[i+1][(((j+1)<<1)/3-1)*sum_w +:sum_w]),
			.Co(tree[i+1][(((j+1)<<1)/3-2)*sum_w +:sum_w])
		);
	end

	for(j=1; j<=tree_w(D+1, i)%3; j=j+1) begin :copy
		assign tree[i+1][(tree_w(D+1, i+1)-j)*sum_w +:sum_w] = tree[i][(tree_w(D+1, i)-j)*sum_w +:sum_w];
	end
end

assign s = tree[TH][0 +:sum_w] + tree[TH][sum_w +:sum_w];

for(i=0; i<D; i=i+1)begin :calc_q
    assign q[i*sum_w +:sum_w] = s - tree[0][i*sum_w +:sum_w];
end
endgenerate

assign dec = s[sum_w-1];
//--------test---------
//assign test = s;
//--------------------

function integer next_n;
    input integer n;
	 integer t;
    begin
	     t = n%3;
        next_n = t + ((n-t) << 1)/3;
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
        while(n>2) begin
            n = next_n(n);
            tree_h = tree_h + 1;
        end
    end
endfunction
	
endmodule

