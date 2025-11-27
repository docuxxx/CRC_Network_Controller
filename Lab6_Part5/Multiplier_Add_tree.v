`timescale 1ns/10ps
// 개선된 Adder_tree multiplier
// 넉넉하게 16비트로 통일하여 carry_out 불필요 
// 만약 더 최적화하려면 partial product마다 비트 폭을 최소로 줄여주면 된다. ex) A(8bit)+B(shift포함 9bit) = 10bit (carry 포함)  
module Multiplier_Add_tree(A, B, Q);
	input [7:0] A, B;
	output [15:0] Q;
	
	wire [15:0] pp0, pp1, pp2, pp3, pp4, pp5, pp6, pp7;
	wire [15:0] s_AB, s_CD, s_EF, s_GH, s_ABCD, s_EFGH, s_All;
	
	assign pp0 = {8'b0, (A & {8{B[0]}})}; 
    	assign pp1 = {8'b0, (A & {8{B[1]}})} << 1;
    	assign pp2 = {8'b0, (A & {8{B[2]}})} << 2;
    	assign pp3 = {8'b0, (A & {8{B[3]}})} << 3;
    	assign pp4 = {8'b0, (A & {8{B[4]}})} << 4;
    	assign pp5 = {8'b0, (A & {8{B[5]}})} << 5;
    	assign pp6 = {8'b0, (A & {8{B[6]}})} << 6;
    	assign pp7 = {8'b0, (A & {8{B[7]}})} << 7;

	// 8x8은 최대 1111_1110_0000_0001로 carry out x
	Full_Adder FA_AB(.A(pp0), .B(pp1), .C_in(1'b0), .C_out(), .S(s_AB));
	defparam FA_AB.n = 16;
	Full_Adder FA_CD(.A(pp2), .B(pp3), .C_in(1'b0), .C_out(), .S(s_CD));
	defparam FA_CD.n = 16;
	Full_Adder FA_EF(.A(pp4), .B(pp5), .C_in(1'b0), .C_out(), .S(s_EF));
	defparam FA_EF.n = 16;
	Full_Adder FA_GH(.A(pp6), .B(pp7), .C_in(1'b0), .C_out(), .S(s_GH));
	defparam FA_GH.n = 16;

	

	Full_Adder FA_ABCD(.A(s_AB), .B(s_CD), .C_in(1'b0), .C_out(), .S(s_ABCD));
	defparam FA_ABCD.n = 16;
	Full_Adder FA_EFGH(.A(s_EF), .B(s_GH), .C_in(1'b0), .C_out(), .S(s_EFGH));
	defparam FA_EFGH.n = 16;
	
	Full_Adder FA_All(.A(s_ABCD), .B(s_EFGH), .C_in(1'b0), .C_out(), .S(s_All));
	defparam FA_All.n = 16;

	assign Q = s_All;

endmodule
