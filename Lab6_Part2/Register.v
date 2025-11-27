module Register (D, Q, Clk, Reset);
	parameter n = 8;
	
	input [n-1:0] D;
	input Clk, Reset;
	output reg [n-1:0] Q;

	always @(posedge Clk or negedge Reset)
	begin
		if (!Reset) 
			Q <= 0;
		else 
			Q <= D;
	end

endmodule