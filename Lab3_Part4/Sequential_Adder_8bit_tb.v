`timescale 1ns/10ps

module Sequential_Adder_8bit_tb;
	reg [7:0] SW;
	reg Reset, Clk;
	wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire LEDR;

	Sequential_Adder_8bit DUT(SW, Reset, Clk, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

	initial begin
		SW = 8'h0;
		Reset = 1'b1;
		Clk = 1'b0;
	end

	always @(SW, Clk, Reset)
	begin

		#10 Reset = ~Reset;  // 처음 초기화
		#5 Reset = ~Reset;

		#20 SW = 8'hF7;		// 247
		#10 Clk = ~Clk;		
		#10 Clk = ~Clk;
		#5 SW = 8'h07;        	
		#10 Clk = ~Clk;		
		#10 Clk = ~Clk;			// FE
		#10 Reset = ~Reset; //Reset
		#5 Reset = ~Reset; // 다시 1 만들어서 대기
		
		SW = 8'h1B;		// 27
		#10 Clk = ~Clk;		
		#10 Clk = ~Clk;
		SW = 8'h30;		// 48
		#10 Clk = ~Clk;		
		#10 Clk = ~Clk;		// 4b
				
		#10 Reset = ~Reset;
		#5 Reset = ~Reset;
		#10 $stop;
	end
endmodule 