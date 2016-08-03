File.open("config", "r") do |f|
	x=f.gets.split(" ").map(&:to_i)
	x.each_with_index do |val,idx|
		print "wire [temp_w*",val,"-1:0] c",idx,"ibus;\n"
		print "wire [data_w*",val,"-1:0] c",idx,"obus;\n"
		print "cnu #(.res_w(data_w), .ext_w(ext_w), .D(",val,"), .idx_w(idx_w)) CNU",idx," ( .en(en), .clk(clk), .rst(rst), .q(c",idx,"ibus), .r(c",idx,"obus));\n"
	end
	x=f.gets.split(" ").map(&:to_i)
	x.each_with_index do |val,idx|
		print "wire [data_w*",val,"-1:0] v",idx,"ibus;\n"
		print "wire [temp_w*",val,"-1:0] v",idx,"obus;\n"
		print "vnu #(.data_w(data_w), .D(",val,"), .ext_w(ext_w)) VNU",idx," (.l(l[",idx,"*data_w +:data_w]), .r(v",idx,"ibus), .q(v",idx,"obus), .dec(dec[",idx,"]));\n"
	end
	cn = 0
	vv = Array.new(2304, 0)
	f.each_line do |line|
		x = line.split(" ").map(&:to_i)
		x.each_with_index do |val,idx|
			if(val < 0) then 
				break
			end
			print "assign c",cn,"ibus[temp_w*",idx," +:temp_w] = v",val,"obus[temp_w*",vv[val]," +:temp_w];\n"
			print "assign v",val,"ibus[data_w*",vv[val]," +:data_w] = c",cn,"obus[data_w*",idx," +:data_w];\n"
			vv[val] = vv[val] + 1
		end
		cn = cn + 1;
	end
end
