module char_7seg(Display, C);
	input [1:0] C;
	output  [6:0] Display;
	
	// 7 segment display는 Active Low이므로 0일 때 작동

	assign Display = (C == 2'b00) ? 7'b0100001:
			     (C == 2'b01) ? 7'b0000110:
			     (C == 2'b10) ? 7'b1001111:
			     (C == 2'b11) ? 7'b1000000:
						  7'b0000000;

endmodule
	