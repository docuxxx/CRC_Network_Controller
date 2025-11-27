`timescale 1ns/10ps
// Clk = 1 Q = D, Clk = 0 Q = Q'
module gated_D_latch(Clk, D, Q);
	input Clk, D;
	output Q;
	wire S, R, S_g, R_g, Qa, Qb /* synthesis keep */;

	assign S = D;
	assign R = ~D;
	
	/*

		Clk = 0일 때는 S와 R 값에 상관 없이 S_g, R_g는 1
		Clk = 1일 때는 S' , R'
		
		Clk = 0일 때 Qa = Qb', Qb = Qa' - 이전 값 출력
		-> if, Qa = 1, Qb = 0일 때 Clk = 0이면 Qa = Qb' = 1, Qb = Qa' = 0; 이전 값 출력
		
		Clk = 1일 때, D = 0이면? 
		S = 0, R = 1 RESET
		S_g = 1, R_g = 0 -> Q = Qa = Qb' = 0, Qb = 1 
		Clk = 1일 때, D = 1이면?
		S = 1, R = 0, SET
		S_g = 0, R_g = 1 -> Q = Qa = 1, Qb = Qa' = 0

	*/

	assign S_g = ~( S & Clk);
	assign R_g = ~( R & Clk);
	//cross feedback form
	assign Qa = ~( S_g & Qb);
	assign Qb = ~( R_g & Qa);
	//output을 다른 입력으로는 사용 불가
	assign Q = Qa;

endmodule