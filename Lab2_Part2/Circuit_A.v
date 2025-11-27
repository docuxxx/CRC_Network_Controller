// 값을 보정해주는 역할
module Circuit_A (V,A);
	input [3:0] V;
	output [3:0] A;
	/*
		10 이상의 값을 입력으로 받을 때, 
		일의 자리 값을 보정해주는 회로
		
		if, V = 1110(14)이라면  A[3] = 0 
	           				A[2] = 1
						A[1] = 0
						A[0] = 0 
		   A = 0100 (4)가 된다.

	*/

	assign A[3] = ~V[3];
	assign A[2] = V[2]&V[1];
	assign A[1] = ~V[1];
	assign A[0] = V[0];

endmodule;