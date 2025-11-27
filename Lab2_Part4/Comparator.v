module Comparator(V,Z);
	input [4:0] V;
	output Z;
	//comparator make 5bit 
	//S = {C_out, s}; 한 이유도 comparator에 전달하여 값을 보정하기 위함
	assign Z = V[4] | (V[3] & V[2]) | (V[3] & V[1]);

endmodule