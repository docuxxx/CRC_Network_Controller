`timescale 1ns/10ps

module Counter_10k(En, Clr, Clk, Q);
	input En, Clk, Clr;
	output reg [13:0] Q;

	always @(posedge Clk)
	begin
		if(!Clr)
			Q <= 14'd0;
		// 10,000까지 카운트 후 초기화
		else if(Q == 14'd9999)
				Q <= 14'd0;
		// enable(5000 count마다 1) 신호가 1일 때만 카운트		
		else if(Q != 14'd9999 && En == 1'b1)
				Q <= Q + 1'd1;
	end
endmodule
