`timescale 1ns/10ps

module Adder_Subtractor(A, add_sub, S, Overflow, C_out, Clk, Reset, HEX0, HEX1, HEX2, HEX3);
	input [7:0] A;
	input add_sub;
	input Clk, Reset;
	output [7:0] S;
	output [6:0] HEX0, HEX1, HEX2, HEX3;
	output Overflow, C_out;
	wire [7:0] AQ, SQ, SUM;
	wire [7:0] A_operand;
	wire Overflow_reg, C_out_reg;
	
	Register A_reg(.D(A), .Q(AQ), .Clk(Clk), .Reset(Reset));
	defparam A_reg.n = 8;
	Complement_2s Complement(.D(AQ), .add_sub(add_sub), .Q(A_operand));
	
	Full_Adder Adder(.A(A_operand), .B(SQ), .C_in(1'b0), .S(SUM), .C_out(C_out_reg));

	Register S_reg(.D(SUM), .Q(SQ), .Clk(Clk), .Reset(Reset));
	defparam S_reg.n = 8;
	Logic_Circuit Overflow_detect(.AQ(A_operand), .SQ(SQ), .SUM(SUM), .Overflow(Overflow_reg), .Reset(Reset));
	
	Register Overflow_register(.D(Overflow_reg), .Q(Overflow), .Clk(Clk), .Reset(Reset));
		defparam Overflow_register.n = 1;

		
	Register Carry_reg(.D(C_out_reg), .Q(C_out), .Clk(Clk), .Reset(Reset));
		defparam Carry_reg.n = 1;

	assign S = SQ;

	Hex_Decoder Display0(.X(SQ[3:0]), .HEX(HEX0));
	Hex_Decoder Display1(.X(SQ[7:4]), .HEX(HEX1));
	Hex_Decoder Display2(.X(AQ[3:0]), .HEX(HEX2));
	Hex_Decoder Display3(.X(AQ[7:4]), .HEX(HEX3));

endmodule
	