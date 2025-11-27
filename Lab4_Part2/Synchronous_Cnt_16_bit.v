`timescale 1ns/10ps

module Synchronous_Cnt_16_bit(En, Clr, Clk, Clk_50, HEX0, HEX1, HEX2, HEX3);
	input En, Clr, Clk, Clk_50;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	reg [15:0] Q;

	always @(posedge Clk)
	begin
		if (Clr == 1'b0)
			Q <= 16'h0;

		else if (En == 1'b1)
			Q <= Q + 16'h0001;
	end

	Hex_Decoder Display0 (.X(Q[3:0]), .HEX(HEX0));
	Hex_Decoder Display1 (.X(Q[7:4]), .HEX(HEX1));
	Hex_Decoder Display2 (.X(Q[11:8]), .HEX(HEX2));
	Hex_Decoder Display3 (.X(Q[15:12]), .HEX(HEX3));
endmodule
