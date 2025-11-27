`timescale 1ns/10ps

module part6 (SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input [9:7] SW;
	output [9:7] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	wire [2:0] A, B, C, D, E, F;
	wire [2:0] M0, M1, M2, M3, M4, M5;
	
	assign A = 3'b000;
	assign B = 3'b001;
	assign C = 3'b010;
	assign D = 3'b011;
	assign E = 3'b100;
	assign F = 3'b101;	
	
	mux_3bit_6to1 U0 (.S(SW[9:7]), .U(E[2:0]), .V(F[2:0]), .W(A[2:0]), .X(B[2:0]), .Y(C[2:0]), .Z(D[2:0]), .M(M0));
	mux_3bit_6to1 U1 (.S(SW[9:7]), .U(F[2:0]), .V(A[2:0]), .W(B[2:0]), .X(C[2:0]), .Y(D[2:0]), .Z(E[2:0]), .M(M1));
	mux_3bit_6to1 U2 (.S(SW[9:7]), .U(A[2:0]), .V(B[2:0]), .W(C[2:0]), .X(D[2:0]), .Y(E[2:0]), .Z(F[2:0]), .M(M2));
	mux_3bit_6to1 U3 (.S(SW[9:7]), .U(B[2:0]), .V(C[2:0]), .W(D[2:0]), .X(E[2:0]), .Y(F[2:0]), .Z(A[2:0]), .M(M3));
	mux_3bit_6to1 U4 (.S(SW[9:7]), .U(C[2:0]), .V(D[2:0]), .W(E[2:0]), .X(F[2:0]), .Y(A[2:0]), .Z(B[2:0]), .M(M4));
	mux_3bit_6to1 U5 (.S(SW[9:7]), .U(D[2:0]), .V(E[2:0]), .W(F[2:0]), .X(A[2:0]), .Y(B[2:0]), .Z(C[2:0]), .M(M5));
	
	
	
	char_7seg_3bits H0 (.C(M0), .Display(HEX5));
	char_7seg_3bits H1 (.C(M1), .Display(HEX4));
	char_7seg_3bits H2 (.C(M2), .Display(HEX3));
	char_7seg_3bits H3 (.C(M3), .Display(HEX2));
	char_7seg_3bits H4 (.C(M4), .Display(HEX1));
	char_7seg_3bits H5 (.C(M5), .Display(HEX0));
	assign LEDR = SW;
	
endmodule