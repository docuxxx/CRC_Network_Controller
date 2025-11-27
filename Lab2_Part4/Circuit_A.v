module Circuit_A (V,A);
	input [4:0] V;
	output [4:0] A;
	// make 5bit
	assign A[4] = 1'b0;
	// ~V[3]만 쓰면 보정 안할 때는 상관없는 거처럼 보여도 18 출력할 때 깨짐
	assign A[3] = ~V[3]&V[1]; 
	/* 
		if V = 4'b1101
		   A = 4'b0011
		or
		if V = 4'b1010
		   A = 4'b0000

	*/
	assign A[2] = V[2]~^V[1];  
	assign A[1] = ~V[1];
	assign A[0] = V[0];

endmodule