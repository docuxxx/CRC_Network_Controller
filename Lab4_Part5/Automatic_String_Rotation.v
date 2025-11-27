`timescale 1ns/10ps
// 1초마다 count된 입력이 6to1 mux로 들어가 공백 및 글자가 rotating되는 것 같은 결과를 출력
module Automatic_String_Rotation (Clr, Clk, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input Clr, Clk;
	wire [2:0] SW;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	wire [2:0] A, B, C, D, E, F;
	wire [2:0] M0, M1, M2, M3, M4, M5;
	
	assign A = 3'b000; // d
	assign B = 3'b001; // E
	assign C = 3'b010; // 1
	assign D = 3'b011; // 0
	assign E = 3'b100; // blank
	assign F = 3'b101; // blank	
	
	// 6초까지 count 되도록하는 stop_watch -> clock 5천만번 동작시 1초 (20ns)
	Stop_Watch_1_digit Stop_Watch (.Clr(Clr), .Clk(Clk), .Q(SW));	

	
	// 입력마다 결과가 바꿔지는 효과를 주는 3bit 6to1 Mux
	mux_3bit_6to1 U0 (.S(SW[2:0]), .U(E[2:0]), .V(F[2:0]), .W(A[2:0]), .X(B[2:0]), .Y(C[2:0]), .Z(D[2:0]), .M(M0)); // 0 s
	mux_3bit_6to1 U1 (.S(SW[2:0]), .U(F[2:0]), .V(A[2:0]), .W(B[2:0]), .X(C[2:0]), .Y(D[2:0]), .Z(E[2:0]), .M(M1)); // 1 s
	mux_3bit_6to1 U2 (.S(SW[2:0]), .U(A[2:0]), .V(B[2:0]), .W(C[2:0]), .X(D[2:0]), .Y(E[2:0]), .Z(F[2:0]), .M(M2)); // 2 s
	mux_3bit_6to1 U3 (.S(SW[2:0]), .U(B[2:0]), .V(C[2:0]), .W(D[2:0]), .X(E[2:0]), .Y(F[2:0]), .Z(A[2:0]), .M(M3)); // 3 s
	mux_3bit_6to1 U4 (.S(SW[2:0]), .U(C[2:0]), .V(D[2:0]), .W(E[2:0]), .X(F[2:0]), .Y(A[2:0]), .Z(B[2:0]), .M(M4)); // 4 s
	mux_3bit_6to1 U5 (.S(SW[2:0]), .U(D[2:0]), .V(E[2:0]), .W(F[2:0]), .X(A[2:0]), .Y(B[2:0]), .Z(C[2:0]), .M(M5)); // 5 s
	
	
	// 출력용 Display
	char_7seg_3bits H0 (.C(M0), .Display(HEX5));
	char_7seg_3bits H1 (.C(M1), .Display(HEX4));
	char_7seg_3bits H2 (.C(M2), .Display(HEX3));
	char_7seg_3bits H3 (.C(M3), .Display(HEX2));
	char_7seg_3bits H4 (.C(M4), .Display(HEX1));
	char_7seg_3bits H5 (.C(M5), .Display(HEX0));
	
endmodule
