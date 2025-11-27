`timescale 1ns/10ps

module T_FF(T, Clk, Clr, Q);
	input T, Clk, Clr;
	output reg Q;

	always @(posedge Clk)
	begin
		if(Clr == 1'b1)
			Q <= 1'b0;

		else if(T == 1'b1) 
			Q <= ~Q;

		else if(T == 1'b0)
			Q <= Q;
	end
endmodule
