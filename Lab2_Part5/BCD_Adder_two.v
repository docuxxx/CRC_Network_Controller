`timescale 1ns/10ps

module BCD_Adder_two (A, B, C_in, HEX0, HEX1, HEX3, HEX5, CLK_50, LEDR);

	input [3:0] A, B;
	input C_in;
	input CLK_50;

	reg [3:0] A_reg, B_reg;
	reg Cin_reg;

	output reg [4:0] LEDR;

	output [6:0] HEX0, HEX1, HEX3, HEX5;

	reg [4:0] Z0, S0, T0;
	reg [4:0] S1, C1;
	wire [7:0] SW;
	always @(A, B, C_in)
	begin
		T0 = A + B + C_in;
		if (T0 >= 4'b1010)
			// 5bit 맞춰주기 위해서 5비트로 선언
			begin 
				Z0 = 5'b01010;
				C1 = 4'b0001;
			end
		else
			begin
				Z0 = 5'b00000;
				C1 = 4'b0000;
			end
		S0 = T0 - Z0;
		S1 = C1;
	end
	
	always @(posedge CLK_50) 
	begin
		A_reg    <= A;
      		B_reg    <= B;
      		Cin_reg <= C_in;
		LEDR <= A_reg + B_reg + Cin_reg;
	end
	
	/*
		
		상위 4bit - 10의자리 0001 or 0000
		하위 4bit - 1의자리 T0(총합) - Z0(비교기 값)

	*/

	assign SW = {S1, S0[3:0]};
	Number_Display Display_Sum(SW, HEX0, HEX1);		
	Number_Display Display_input({A, B}, HEX3, HEX5);	

endmodule

	
		