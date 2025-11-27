`timescale 1ns/10ps

// lab1_part5 Rotating displays 

/*
	SW 9-8 rotating control 
	sw 7-0  input control

*/
module part5 (SW, LEDR, HEX0, HEX1, HEX2, HEX3);
	input [9:0] SW;
	output [9:0] LEDR;
	output [6:0] HEX0, HEX1, HEX2, HEX3;

	wire [1:0] M0, M1, M2, M3;
	/*
		SW 9-8 00 -> U V W X           - d E 1 0
		SW 9-8 01 -> V W X U  1 shift - E 1 0 d
		SW 9-8 10 -> W X U V  2 shift - 1 0 d E 
		SW 9-8 11 -> X U V W  3 shift - 0 d E 1
	*/
											 
	mux_2bit_4to1 U0 (.S(SW[9:8]), .U(SW[7:6]), .V(SW[5:4]), .W(SW[3:2]), .X(SW[1:0]), .M(M0));
	mux_2bit_4to1 U1 (.S(SW[9:8]), .U(SW[5:4]), .V(SW[3:2]), .W(SW[1:0]), .X(SW[7:6]), .M(M1));
	mux_2bit_4to1 U2 (.S(SW[9:8]), .U(SW[3:2]), .V(SW[1:0]), .W(SW[7:6]), .X(SW[5:4]), .M(M2));
	mux_2bit_4to1 U3 (.S(SW[9:8]), .U(SW[1:0]), .V(SW[7:6]), .W(SW[5:4]), .X(SW[3:2]), .M(M3));
	
	//HEX3이 제일 왼쪽 Display
	char_7seg H0 (.C(M0), .Display(HEX3));
	char_7seg H1 (.C(M1), .Display(HEX2));
	char_7seg H2 (.C(M2), .Display(HEX1));
	char_7seg H3 (.C(M3), .Display(HEX0));
	assign LEDR = SW;
	
endmodule