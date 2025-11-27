`timescale 1ns/10ps

module Lab3_Part1(SW, LEDR);
	input [1:0] SW;
	output LEDR;

	gated_D_latch DUT(.Clk(SW[1]), .D(SW[0]), .Q(LEDR));

endmodule