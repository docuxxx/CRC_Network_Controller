`timescale 1ns/10ps

module Synchronous_Cnt_8_bit(En, Clk, Clr, HEX0, HEX1);
	input En, Clk, Clr;
	output [6:0] HEX0, HEX1;
	wire [7:0] Q;
	wire [7:1] T;

	T_FF T0(.T(En), .Clk(Clk), .Clr(Clr), .Q(Q[0]));
	assign T[1] = Q[0] & En;

	T_FF T1(.T(T[1]), .Clk(Clk), .Clr(Clr), .Q(Q[1]));
	assign T[2] = Q[1] & T[1];

	T_FF T2(.T(T[2]), .Clk(Clk), .Clr(Clr), .Q(Q[2]));
	assign T[3] = Q[2] & T[2];

	T_FF T3(.T(T[3]), .Clk(Clk), .Clr(Clr), .Q(Q[3]));
	assign T[4] = Q[3] & T[3];

	T_FF T4(.T(T[4]), .Clk(Clk), .Clr(Clr), .Q(Q[4]));
	assign T[5] = Q[4] & T[4];

	T_FF T5(.T(T[5]), .Clk(Clk), .Clr(Clr), .Q(Q[5]));
	assign T[6] = Q[5] & T[5];

	T_FF T6(.T(T[6]), .Clk(Clk), .Clr(Clr), .Q(Q[6]));
	assign T[7] = Q[6] & T[6];

	T_FF T7(.T(T[7]), .Clk(Clk), .Clr(Clr), .Q(Q[7]));

	Hex_Decoder Display0(.X(Q[3:0]), .HEX(HEX0));
	Hex_Decoder Display1(.X(Q[7:4]), .HEX(HEX1));
endmodule
