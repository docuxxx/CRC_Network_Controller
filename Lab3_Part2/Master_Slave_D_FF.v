module Master_Slave_D_FF(Clk, D, Q);
	input Clk, D;
	output Q;
	wire Qm, Qs;
	/*
	
	Master Latch는 Clk = 0에서 동작하고 Slave Latch는 Clk = 1에서 동작한다. 
	고로, 하나의 큰 FF으로 보았을 때, Clk이 0에서 1로 상승하는 순간 D 값이 Q로 전달되는 것과 같은 효과를 낸다.
	D 값과 상관 없이 Clk이 상승 엣지일 때만 동작한다.  Level 동작에서  Edge 동작하는 것처럼 만들 수 있다.
	Master에서의 Clk 신호를 반전하는게 아니라 Slave에서의 Clk을 반전해주면 하강엣지에서 동작하도록 만들 수 있다.
	*/
	gated_D_latch Master (.Clk(~Clk), .D(D), .Q(Qm));
	gated_D_latch Slave (.Clk(Clk), .D(Qm), .Q(Qs));
	
	assign Q = Qs;
	
endmodule