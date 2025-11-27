`timescale 1ns/10ps

module Multiplier(A, B, Q);
	input [7:0] A, B;
	output [15:0] Q;
	wire c1, c2, c3, c4, c5, c6, c7;
	wire [7:0] S1, S2, S3, S4, S5, S6, S7;
	// p0를 따로 처리하기 위해 .A 벡터 달라짐
	Full_Adder FA_1(.A({1'b0, A[7:1]&{7{B[0]}}}), .B(A[7:0]&{8{B[1]}}), .C_in(1'b0), .C_out(c1), .S(S1));
	Full_Adder FA_2(.A({c1, S1[7:1]}), .B(A[7:0]&{8{B[2]}}), .C_in(1'b0), .C_out(c2), .S(S2));
	Full_Adder FA_3(.A({c2, S2[7:1]}), .B(A[7:0]&{8{B[3]}}), .C_in(1'b0), .C_out(c3), .S(S3));
	Full_Adder FA_4(.A({c3, S3[7:1]}), .B(A[7:0]&{8{B[4]}}), .C_in(1'b0), .C_out(c4), .S(S4));
	Full_Adder FA_5(.A({c4, S4[7:1]}), .B(A[7:0]&{8{B[5]}}), .C_in(1'b0), .C_out(c5), .S(S5));
	Full_Adder FA_6(.A({c5, S5[7:1]}), .B(A[7:0]&{8{B[6]}}), .C_in(1'b0), .C_out(c6), .S(S6));
	Full_Adder FA_7(.A({c6, S6[7:1]}), .B(A[7:0]&{8{B[7]}}), .C_in(1'b0), .C_out(c7), .S(S7));
	// p7 ~ p0
	assign Q = {c7, S7, S6[0], S5[0], S4[0], S3[0], S2[0], S1[0], A[0] & B[0]};

endmodule
