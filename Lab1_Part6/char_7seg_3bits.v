module char_7seg_3bits(Display, C);
	input [2:0] C;
	output  [6:0] Display;
	
	assign Display = (C == 3'b000) ? 7'b0100001:
			     (C == 3'b001) ? 7'b0000110:
			     (C == 3'b010) ? 7'b1001111:
			     (C == 3'b011) ? 7'b1000000:
			     			    7'b1111111;
endmodule
	