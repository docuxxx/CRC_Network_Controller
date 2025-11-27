`timescale 1ns/10ps

module Sequence_Detector_1_reg (w, z, Clk, Reset, LEDR);
	input w, Clk, Reset;
	output z;
	output [7:4] LEDR;
	Shift_Register Sequence_Detect (.A(w), .z(z), .Clk(Clk), .Reset(Reset), .Register(LEDR));
endmodule