`timescale 1ns/10ps

module Three_Digit_Number (A, HEX0, HEX1, HEX2);
	input [7:0] A;
	output [6:0] HEX0, HEX1, HEX2;
	wire [3:0]  R0, R1, Q1;
	wire [4:0] Q0;
	
	// 1의 자리 (나머지 연산)
	assign R0 = A % 4'b1010;
	// 몫 연산 ex) A = 255면 Q0 = 25
	assign Q0 = A / 4'b1010;
	// 10의 자리 구하기 위한 나머지 연산 ex) 25 % 10 = 5
	assign R1 = Q0 % 4'b1010;
	// 100의 자리 구하기 위한 몫 연산 ex) 25 / 10 = 2
	assign Q1 = Q0 / 4'b1010;
	
	Number_Display Display0(.SW(R0), .HEX0(HEX0));	
	Number_Display Display1(.SW(R1), .HEX0(HEX1));	
	Number_Display Display2(.SW(Q1), .HEX0(HEX2));	
endmodule