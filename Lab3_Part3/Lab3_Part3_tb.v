`timescale 1ns/10ps
module Lab3_Part3_tb ();
	reg D, Clk;
	wire Qa, Qb, Qc;

	Lab3_Part3 DUT(.D(D), .Clk(Clk), .Qa(Qa), .Qb(Qb), .Qc(Qc));
	
	initial 
	begin
		D = 1'b0; 
		#5 Clk = 1'b0; 
	end
	
	always 
	begin 
		#10 Clk = ~Clk;
	end

	initial
	begin
		#5 D = ~D;
		#12 D = ~D;
		#11 D = ~D;
		#9 D = ~D;
		#7 D = ~D;
		#23 D = ~D;
		#17 D = ~D;
		#20 $stop;
	end
endmodule