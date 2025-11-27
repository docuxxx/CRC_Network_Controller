`timescale 1ns/10ps

module Lab3_Part1_tb();

	reg [1:0] SW;
	wire      Q;  

	Lab3_Part1 DUT (.SW(SW), .LEDR(Q));

	initial 
	begin
		SW[1] = 1'b0; // Clk = 0
		SW[0] = 1'b0; // D = 0
	end
	
	always 
	begin 

		#20 SW[0] = ~SW[0];
		#30 SW[1] = ~SW[1];  
		#20 SW[0] = ~SW[0];  
		#10 SW[1] = ~SW[1];  
		#5 SW[1] = ~SW[1];
		#5 SW[1] = ~SW[1];
		#5 SW[0] = ~SW[0];
		#30 $stop;
	end
	
endmodule