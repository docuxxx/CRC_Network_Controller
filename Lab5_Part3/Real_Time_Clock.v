`timescale 1ns/10ps

module Real_Time_Clock (Clk, Reset, SW, Preset, Stop, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	input Clk, Reset, Preset, Stop;
	input [7:0] SW;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	wire Rollover_500k, Rollover_Hs_1, Rollover_Hs_10, Rollover_S_1, Rollover_S_10, Rollover_M_1, Rollover_M_10; 
	wire [18:0] Q_500k;
	wire [4:0] Q_Hs_1, Q_Hs_10, Q_S_1, Q_S_10, Q_M_1, Q_M_10;

	Modulo_k_Counter Cnt_500k (.Q(Q_500k), .Clk(Clk), .Reset(Reset), .En(Stop), 
						.Preset(1'b1), .Preset_Input(1'b0), .Rollover(Rollover_500k));
		defparam Cnt_500k.n = 19;
		defparam Cnt_500k.k = 500_000;

	Modulo_k_Counter Cnt_Hs_1 (.Q(Q_Hs_1), .Clk(Clk), .Reset(Reset), .En(Rollover_500k), 
						.Preset(1'b1), .Preset_Input(1'b0), .Rollover(Rollover_Hs_1));
		defparam Cnt_Hs_1.n = 4;
		defparam Cnt_Hs_1.k = 10;
	
	Modulo_k_Counter Cnt_Hs_10 (.Q(Q_Hs_10), .Clk(Clk), .Reset(Reset), .En(Rollover_Hs_1), 
						.Preset(1'b1), .Preset_Input(1'b0), .Rollover(Rollover_Hs_10));
		defparam Cnt_Hs_10.n = 4;
		defparam Cnt_Hs_10.k = 10;

	Modulo_k_Counter Cnt_S_1 (.Q(Q_S_1), .Clk(Clk), .Reset(Reset), .En(Rollover_Hs_10), 
						.Preset(1'b1), .Preset_Input(1'b0), .Rollover(Rollover_S_1));
		defparam Cnt_S_1.n = 4;
		defparam Cnt_S_1.k = 10;

	// 비트폭 4로 통일
	Modulo_k_Counter Cnt_S_10 (.Q(Q_S_10), .Clk(Clk), .Reset(Reset), .En(Rollover_S_1), 
						.Preset(1'b1), .Preset_Input(1'b0), .Rollover(Rollover_S_10));
		defparam Cnt_S_10.n = 4;
		defparam Cnt_S_10.k = 6;

	Modulo_k_Counter Cnt_M_1 (.Q(Q_M_1), .Clk(Clk), .Reset(Reset), .En(Rollover_S_10), 
						.Preset(Preset), .Preset_Input(SW[3:0]), .Rollover(Rollover_M_1));
		defparam Cnt_M_1.n = 4;
		defparam Cnt_M_1.k = 10;

	Modulo_k_Counter Cnt_M_10 (.Q(Q_M_10), .Clk(Clk), .Reset(Reset), .En(Rollover_M_1), 
						.Preset(Preset), .Preset_Input(SW[7:4]), .Rollover(Rollover_M_10));
		defparam Cnt_M_10.n = 4;
		defparam Cnt_M_10.k = 6;


	Hex_Decoder Display_Hs_1 (.X(Q_Hs_1), .HEX(HEX0));
	Hex_Decoder Display_Hs_10 (.X(Q_Hs_10), .HEX(HEX1));
	Hex_Decoder Display_S_1 (.X(Q_S_1), .HEX(HEX2));
	Hex_Decoder Display_S_10 (.X(Q_S_10), .HEX(HEX3));
	Hex_Decoder Display_M_1 (.X(Q_M_1), .HEX(HEX4));
	Hex_Decoder Display_M_10 (.X(Q_M_10), .HEX(HEX5));

endmodule