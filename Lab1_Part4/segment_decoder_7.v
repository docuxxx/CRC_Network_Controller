
module segdec7(HEX0, c);
	input [1:0] c;
	output  [6:0] HEX0;
	
	assign HEX0 = (c == 2'b00) ? 7'b0100001:
			     (c == 2'b01) ? 7'b0000110:
			     (c == 2'b10) ? 7'b1001111:
			     (c == 2'b11) ? 7'b1000000:
						 7'b0000000;

endmodule
	