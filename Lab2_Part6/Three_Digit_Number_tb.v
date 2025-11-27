`timescale 1ns/10ps

module Three_Digit_Number_tb ();

	reg [7:0] A;
	wire [6:0] HEX0, HEX1, HEX2;
	
	Three_Digit_Number DUT (.A(A), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2));	
	
	initial 
	begin	
		#20 A = 8'b0110_0100; // 100
		#20 A = 8'b0111_1000; // 120
		#20 A = 8'b1111_1111; // 255
		#20 
		$stop;
	end
endmodule