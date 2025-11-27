module Logic_Circuit (AQ, SQ, SUM, Overflow, Reset);
	parameter n = 8;

	input [n-1:0] AQ, SQ, SUM;
	input Reset;
	output reg Overflow;
	
	always @(*)
	begin
		if (!Reset)
			Overflow = 0;
		else
		begin
			if ((AQ[n-1] == SQ[n-1]) && (AQ[n-1] != SUM[n-1]))
				Overflow = 1;
			else
				Overflow = 0;
		end
	end
endmodule