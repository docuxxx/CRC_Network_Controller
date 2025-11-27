`timescale 1ns/10ps
module Posedge_D_FF(D, Clk, Q);
	input D, Clk;
	output reg Q;
	//non-blocking (edge)
	always @(posedge Clk) 
		Q <= D;
endmodule