`timescale 1ns/10ps 

module counter(L,Clk,Data,Q);
input L, Clk;
input [2:0] Data;
output reg [2:0] Q;
wire E;

always @(posedge Clk)
	if (!L) 
		Q <= Data;
	else if (E)
		Q <= Q - 3'b1;
assign E = (Q != 3'b0);

endmodule