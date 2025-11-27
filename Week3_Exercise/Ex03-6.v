`timescale 1ns/10ps 

module adder (x,y,ci,s);
parameter n = 4;
input ci;
input [n-1:0] x,y;
output reg [n-1:0] s;

always @(x,y,ci)
	s = x+y+ci;

endmodule