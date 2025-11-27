`timescale 1ns/10ps

/*

DE-10 보드의 기본 클럭은 50Mhz이므로 한 주기가 20ns인 클럭이다. 
우리는 1초에 한 번씩 증가하는 Counter를 만들고자한다.
1초 = 1,000,000,000 ns이므로 총 5천만번의 클럭의 동작마다 1번의 카운터가 일어나도록 설계한다.
이는 5,000짜리 Counter 1개, 10,000짜리 Counter 1개를 만들어 5,000번씩 10,000번 Count 하도록 설계하였다.

*/

module Stop_Watch_1_digit(Clr, Clk, HEX0);
	input Clr, Clk;
	output [6:0] HEX0;
	wire [13:0] Q_10k;
	wire [12:0] Q_5k;
	wire [3:0] Q;
	wire En_50m, En_10k;
	
	/* 
		Count 5,000 수행 -> 10,000 Counter의 Enable 신호를 1로 만들어 Count 시작
		10,000 count가 5,000 번수행된다면 Display_Counter Count 시작
	*/
	
	Counter_5k First_Counter(.Clr(Clr), .Clk(Clk), .Q(Q_5k));
	assign En_10k = (Q_5k == 13'd4999);

	Counter_10k Second_Counter(.En(En_10k), .Clr(Clr), .Clk(Clk), .Q(Q_10k));
	assign En_50m = (Q_10k == 14'd9999);
	
	Counter_10 Display_Counter(.En(En_50m), .Clr(Clr), .Clk(Clk), .Q(Q));
	

	Hex_Decoder Dispay(.X(Q), .HEX(HEX0));
endmodule
	 