`timescale 1ns/10ps

module Modulo_k_Counter_tb;
	reg Clk, Reset;
	wire [4:0] Q;
	wire Rollover;

	Modulo_k_Counter DUT(.Q(Q), .Clk(Clk), .Reset(Reset), .Rollover(Rollover));
	
	initial 
	begin
		Clk = 1'b0;
		Reset = 1'b0;
	end

	always
		#5 Clk = ~Clk;

	always @(posedge Clk) 
	begin
		#15 Reset = 1'b1;
		#350 $stop;
	end
endmodule
