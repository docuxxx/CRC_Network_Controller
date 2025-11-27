`timescale 1ns/10ps
module gated_D_Latch (D, Clk, Q);
	input D, Clk;
	output reg Q;
	//blocking (level)
	always @(D, Clk)
		if (Clk)
			Q = D;
endmodule