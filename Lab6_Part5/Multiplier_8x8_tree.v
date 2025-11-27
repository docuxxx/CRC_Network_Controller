`timescale 1ns/10ps

module Multiplier_8x8_tree(Input, Clk, Reset, En_A, En_B, LEDR, HEX0, HEX1, HEX2, HEX3);
	input [7:0] Input;
	input Clk, Reset, En_A, En_B;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	output [7:0] LEDR;
	wire [15:0] P;
	wire [7:0] A, B;
	wire [15:0] Multiplier_Q;

	Register reg_A(.D(Input), .Q(A), .Clk(Clk), .Reset(Reset), .En(En_A));
	defparam reg_A.n = 8;
	Register reg_B(.D(Input), .Q(B), .Clk(Clk), .Reset(Reset), .En(En_B));
	defparam reg_B.n = 8;
	Multiplier_Add_tree Enhanced(.A(A), .B(B), .Q(Multiplier_Q));

	Register reg_P(.D(Multiplier_Q), .Q(P), .Clk(Clk), .Reset(Reset), .En(1'b1));
	defparam reg_P.n = 16;

	assign LEDR = (En_A) ? A : (En_B ? B : 8'b0);

	Hex_Decoder Display0(.X(P[3:0]), .HEX(HEX0));
	Hex_Decoder Display1(.X(P[7:4]), .HEX(HEX1));
	Hex_Decoder Display2(.X(P[11:8]), .HEX(HEX2));
	Hex_Decoder Display3(.X(P[15:12]), .HEX(HEX3));
endmodule
