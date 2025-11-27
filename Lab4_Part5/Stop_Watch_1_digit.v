`timescale 1ns/10ps

module Stop_Watch_1_digit(Clr, Clk, Q);
	input Clr, Clk;
	// Part3에서는 출력 Q를 wire로 받았었는데, Part5에서는 SW에 연결해주어야 하므로 output 선언
	output [2:0] Q;
	wire [13:0] Q_10k;
	wire [12:0] Q_5k;
	wire En_50m, En_10k;
	
	/* 
		Count 5,000 수행 -> 10,000 Counter의 Enable 신호를 1로 만들어 Count 시작
		10,000 count가 5,000번 수행된다면 Display_Counter Count 시작
	*/
	
	Counter_5k First_Counter(.Clr(Clr), .Clk(Clk), .Q(Q_5k));
	assign En_10k = (Q_5k == 13'd4999);

	Counter_10k Second_Counter(.En(En_10k), .Clr(Clr), .Clk(Clk), .Q(Q_10k));
	assign En_50m = (Q_10k == 14'd9999);
	
	Counter_6 Display_Counter(.En(En_50m), .Clr(Clr), .Clk(Clk), .Q(Q));
	
endmodule
	 