`timescale 1ns/10ps

module Modulo_k_Counter (Q, Clk, Reset, Rollover);
	parameter n = 5;
	parameter k = 20;

	input Clk, Reset;
	output reg [n-1:0] Q;
	output Rollover;

	always @(posedge Clk or negedge Reset) 
	begin 
		if (!Reset) 
			Q <= 0;
		else if (Q == k - 1'b1) 
			Q <= 0;
		else
			Q <= Q + 1;
	end
	assign Rollover = (Q == k-1);

endmodule