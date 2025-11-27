`timescale 1ns/10ps

module Number_Display_tb;
	reg [7:0] SW;
	wire [6:0] HEX0, HEX1;
	reg clk;

	Number_Display DUT (.SW(SW), .HEX0(HEX0), .HEX1(HEX1));	

	initial 
	begin
		clk = 1'b0;
		SW [3:0] = 4'b0000;
		SW [7:4] = 4'b0001;
	end

	always				
		#10 clk = ~clk;

	always @(posedge clk)		
	begin
		SW[3:0] = SW[3:0] + 4'b0001;	
		SW[7:4] = SW[7:4] + 4'b0001;	
		
		// 0~9까지만 표현 가능
		if (SW[3:0] == 4'b1001)		
			$stop;
	end

endmodule
