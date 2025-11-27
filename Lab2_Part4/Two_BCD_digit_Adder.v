`timescale 1ns/10ps
module Two_BCD_digit_Adder(X, Y, C_in, HEX0, HEX1, HEX3, HEX5, LEDR, CLK_50);
	input [3:0] X, Y;
	input C_in;
	input CLK_50;
	output [6:0] HEX0, HEX1, HEX3, HEX5;
	output [4:0] LEDR;
	wire Z;
	//5bit output check
	wire [4:0] A;
	wire [3:0] M;
	wire [7:0] SW;
	wire [4:0] S;
	
	Full_Adder_4bit FA(.A(X), .B(Y), .C_in(C_in), .S(S));
	Comparator cmp (.V(S), .Z(Z));
	Circuit_A circuit (.V(S), .A(A));
	assign M[0] = (Z & A[0]) | (~Z & S[0]);
	assign M[1] = (Z & A[1]) | (~Z & S[1]);
	assign M[2] = (Z & A[2]) | (~Z & S[2]);
	assign M[3] = (Z & A[3]) | (~Z & S[3]);
	/*
		
		상위 4bit - 10의자리 0001 or 0000
		하위 4bit - 1의자리 Mux output

	*/
	assign SW = {3'b000, Z, M};
	//Display_Sum
	Number_Display Display_Sum (.SW(SW), .HEX0(HEX0), .HEX1(HEX1));
	//Display_Input 
	//HEX3 - Y HEX5 - X input cocatenate
	Number_Display Display_Input (.SW({X,Y}), .HEX0(HEX3), .HEX1(HEX5));
	assign LEDR[4:0] = S;
	always @(posedge CLK_50)
	LEDR <= SW;

endmodule


/*

4비트 두 개의 덧셈이 출력되야하니까 
덧셈의 결과가 10이상이면 십의 자리는 1이라 z는 1이고, 
1의 자리가 보정된 값이 출력되야하니까 S값을 보정 

*/

