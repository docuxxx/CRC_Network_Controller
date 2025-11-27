module Register (D, Q, Clk, Reset, En);
	parameter n = 8;
	
	input [n-1:0] D;
	input Clk, Reset, En;
	output reg [n-1:0] Q;

	always @(posedge Clk or negedge Reset)
	begin
		if (!Reset) 
			Q <= 0;
		else if (En)
			Q <= D;
		else
			Q <= Q;
	end
endmodule