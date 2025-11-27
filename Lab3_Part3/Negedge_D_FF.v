`timescale 1ns/10ps
module Negedge_D_FF(D, Clk, Q);
	input D, Clk;
	output reg Q;
	//non-blocking (edge)
	always @(negedge Clk) 
		Q <= D;
endmodule