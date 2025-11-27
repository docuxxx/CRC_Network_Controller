`timescale 1ns/10ps

module Counter_5k(Clr, Clk, Q);
	input Clr, Clk;
	output reg [12:0] Q;

	always @(posedge Clk)
	begin
		
		if (!Clr) 
			Q <= 13'd0;

		//5,000까지 count하면 초기화
		else if (Q == 13'd4999)
			Q <= 13'd0;
		else
			Q <= Q + 13'd1;
	end
endmodule

