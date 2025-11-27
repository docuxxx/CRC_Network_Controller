`timescale 1ns/10ps

module Modulo_k_Counter (Q, Clk, Reset, En, Preset, Preset_Input, Rollover);
	parameter n = 5;
	parameter k = 20;

	input Clk, Reset, En, Preset;
	input [3:0] Preset_Input;
	output reg [n-1:0] Q;
	output Rollover;

always @(posedge Clk or negedge Reset) 
	begin 
		if (!Reset) 		
		begin
			Q <= 0;
		end
		
		else if (!Preset)
			Q <= Preset_Input;
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