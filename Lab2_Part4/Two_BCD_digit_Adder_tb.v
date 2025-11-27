`timescale 1ns/10ps

module Two_BCD_Digit_adder_tb();
	reg [3:0] X, Y;		
	reg C_in;		
	
	// HEX0 , HEX1: 합 
	// HEX3: Y, HEX5: X
	wire [6:0] HEX0, HEX1, HEX3, HEX5;	
	wire [4:0] LEDR;
	reg clk;

	Two_BCD_digit_Adder DUT(.X(X), .Y(Y), .C_in(C_in), 
						.HEX0(HEX0), .HEX1(HEX1), .HEX3(HEX3), .HEX5(HEX5), .LEDR(LEDR));

	initial 
	begin		
		clk = 1'b0;
		X = 4'b0000;
		Y = 4'b0000;
		C_in = 1'b0;
	end

	always			
		#20 clk = ~clk;
	always			
		#10 C_in = ~C_in;

	always @(posedge clk)	
	begin
		X = X + 4'b0001;	
		Y = Y + 4'b0010;			
	
		// 최대 표현 가능한 숫자는 9 합은 19 = 9 + 9 + c_in
		if(Y == 4'b1010)	
		
			$stop;
	end
endmodule
