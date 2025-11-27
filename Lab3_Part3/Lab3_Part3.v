`timescale 1ns/10ps
module Lab3_Part3 (D, Clk, Qa, Qb, Qc);
	input D, Clk;
	output Qa, Qb, Qc;
	
	gated_D_Latch Latch (.D(D), .Clk(Clk), .Q(Qa));
	Posedge_D_FF PosDFF (.D(D), .Clk(Clk), .Q(Qb));
	Negedge_D_FF NegDFF (.D(D), .Clk(Clk), .Q(Qc));
endmodule