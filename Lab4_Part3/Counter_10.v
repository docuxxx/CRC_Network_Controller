`timescale 1ns/10ps

module Counter_10(En, Clr, Clk, Q);
	input En, Clk, Clr;
	output reg [3:0] Q;

	always @(posedge Clk)
	begin
		if(!Clr)
			Q <= 4'd0;
			
		else if(En == 1'b1)
			Q <= Q + 1'd1;
			
		else if(Q == 4'd10)
				Q <= 4'd0;	
	end
endmodule
	