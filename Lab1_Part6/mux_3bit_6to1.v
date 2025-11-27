module mux_3bit_6to1 (S, U, V, W, X, Y, Z, M);
	input [2:0] S, U, V, W, X, Y, Z;
	output [2:0] M;
	 
	assign M = ( S == 3'b000) ? U : 
			( S == 3'b001) ? V :
			( S == 3'b010) ? W :
			( S == 3'b011) ? X :
			( S == 3'b100) ? Y :
			( S == 3'b101) ? Z :
			3'b111;

endmodule