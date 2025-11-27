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
		
		/*
			ex) A : 50 + S : (-80) = SUM : -30
		            A[7] = 0, S[7] = -1 이므로 첫번째 조건부터 false -> Overflow = 0
			ex) A : 50 - S : (-80) = SUM : -126((wraparound - 8비트 표현 범위 초과) - add_sub = 1
			    A[7] = 0, S[7] = 0 (보수화) SUM[7] = 1 -> Overflow = 1		    
		*/	

		begin
			if ((AQ[n-1] == SQ[n-1]) && (AQ[n-1] != SUM[n-1]))
				Overflow = 1;
			else
				Overflow = 0;
		end
	end
endmodule