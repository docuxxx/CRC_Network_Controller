`timescale 1ns/10ps

module BCD_3_digit_Counter(Clk, Reset, En, HEX0, HEX1, HEX2);
	input Clk, Reset, En;
	output [6:0] HEX0, HEX1, HEX2;
	wire Rollover_50m, Rollover_1, Rollover_10, Rollover_100;
	wire [25:0] Q_50m;
	wire [3:0] Q_1, Q_10, Q_100;

	Modulo_k_Counter Cnt_50m(.Q(Q_50m), .Clk(Clk), .Reset(Reset), .En(En), .Rollover(Rollover_50m));
		defparam Cnt_50m.n = 26;
		defparam Cnt_50m.k = 26'd50_000_000;

	Modulo_k_Counter Cnt_1(.Q(Q_1), .Clk(Clk), .Reset(Reset), .En(Rollover_50m), .Rollover(Rollover_1));
		defparam Cnt_1.n = 4;
		defparam Cnt_1.k = 4'd10;

	Modulo_k_Counter Cnt_10(.Q(Q_10), .Clk(Clk), .Reset(Reset), .En(Rollover_1), .Rollover(Rollover_10));
		defparam Cnt_10.n = 4;
		defparam Cnt_10.k = 4'd10;

	Modulo_k_Counter Cnt_100(.Q(Q_100), .Clk(Clk), .Reset(Reset), .En(Rollover_10), .Rollover(Rollover_100));
		defparam Cnt_100.n = 4;
		defparam Cnt_100.k = 4'd10;

	Hex_Decoder Display0 (.X(Q_1), .HEX(HEX0));
	Hex_Decoder Display1 (.X(Q_10), .HEX(HEX1));
	Hex_Decoder Display2 (.X(Q_100), .HEX(HEX2));

endmodule