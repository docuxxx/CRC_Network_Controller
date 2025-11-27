module mux_2bit_4to1 (S, U, V, W, X, M);
	input [1:0] S, U, V, W, X;
	output [1:0] M;
	 
	assign M = S[0] ? ( S[1] ? X : V) : ( S[1] ? W : U);

endmodule