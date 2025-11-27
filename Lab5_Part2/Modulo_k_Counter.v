`timescale 1ns/10ps

module Modulo_k_Counter (Q, Clk, Reset, En, Rollover);
	parameter n = 5;
	parameter k = 20;

	input Clk, Reset, En;
	output reg [n-1:0] Q;
	output Rollover;

always @(posedge Clk or negedge Reset) 
	begin 
		if (!Reset) 		
		begin
			Q <= 0;
		end

		else if (En) 
		begin
			if (Q == k - 1) 
				Q <= 0;
			else
				Q <= Q + 1;
		end

		else
		Q <= Q; 
	end

	assign Rollover = (Q == k - 1) & En;

endmodule