`timescale 1ns/10ps

module D_Latch (D, clk, Q);
input D, clk;
output reg Q;

always @(D or clk) 
begin 
	if(clk) Q = D;
end

endmodule