module mux_3bit_6to1 (S, U, V, W, X, Y, Z, M);
	input [2:0] S, U, V, W, X, Y, Z;
	output reg [2:0] M;
	 // 입력
	always @(S, U, V, W, X, Y, Z)
	begin
		case (S)
			3'b000: M = U;
			3'b001: M = V;
			3'b010: M = W;
			3'b011: M = X;
			3'b100: M = Y;
			3'b101: M = Z;
			default: M = 3'b111;
		endcase
	end

endmodule