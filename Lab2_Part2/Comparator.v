module Comparator(V,Z);
	input [3:0] V;
	output Z;
	
	/*
		9를 기준으로 비교
		if, V = 1010(10)이라면  Z = (1 & 0) | (1 & 1) = 1
		    V = 1001(9)이라면 Z = (1 & 0) | (1 & 0) = 0	

	*/

	assign Z = (V[3]&V[2]) | (V[3]&V[1]);

endmodule