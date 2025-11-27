`timescale 1ns/10ps

module BCD_Adder_two_tb();
	reg [3:0] A, B;		
	reg C_in;		
	
	// HEX0 , HEX1: 합 
	// HEX3: Y, HEX5: X
	wire [6:0] HEX0, HEX1, HEX3, HEX5;	
	reg clk;

	BCD_Adder_two DUT(.A(A), .B(B), .C_in(C_in), 
						.HEX0(HEX0), .HEX1(HEX1), 
						.HEX3(HEX3), .HEX5(HEX5));

	initial 
	begin		
		clk = 1'b0;
		A = 4'b0000;
		B = 4'b0000;
		C_in = 1'b0;
	end

	always			
		#20 clk = ~clk;
	always			
		#10 C_in = ~C_in;

	always @(posedge clk)	
	begin
		A = A + 4'b0001;	
		B = B + 4'b0010;			
	
		// 최대 표현 가능한 숫자는 9 합은 19 = 9 + 9 + c_in
		if(B == 4'b1010)	
		
			$stop;
	end
endmodule
