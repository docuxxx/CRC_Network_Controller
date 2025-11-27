`timescale 1ns/10ps 

module FA02 (x,y,ci,s,co);
input x,y,ci;
output reg s,co;

always @(x,y,ci)
	{co,s} = x+y+ci;

endmodule