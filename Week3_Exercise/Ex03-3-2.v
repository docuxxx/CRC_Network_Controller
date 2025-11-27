`timescale 1ns/10ps

module D_FF (D, clk, Q);
input D, clk;
output reg Q;

always @(posedge clk) 
begin 
	Q = D;
end

endmodule