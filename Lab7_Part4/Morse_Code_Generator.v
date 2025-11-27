`timescale 1ns/10ps
// 파라미터를 추가한 Morse Code Generator 모듈
module Morse_Code_Generator (SW, LEDR, Reset, Clk, Start);
    parameter Wait = 2'b00, Dot = 2'b01, Dash = 2'b10, End = 2'b11;
    input [2:0] SW;
    input Reset, Clk, Start;
    output reg LEDR;

    wire Rollover_25M;
    wire [24:0] Q_25M;
    wire [3:0] Letter_in;
    wire [2:0] Size;
    // Enable은 동작 판단
    // Count는 dash - 1.5s pulse이므로 0.5s pulse 몇 번 동작할지 (3번) 세는 카운터  
    reg  [1:0] State, Count;

    // Index는 Symbol로 들어온 문자의 상위 비트부터 읽는 index
    reg  [1:0] Index;
    // 어디까지 읽어야할지에 대한 remain ex) A라면 01까지만 읽음 (Size 값 할당)
    reg  [2:0] Remain;

    Modulo_k_Counter Cnt_25M (.Q(Q_25M), .Clk(Clk), .Reset(Reset), .En(1'b1), .Rollover(Rollover_25M));
    defparam Cnt_25M.n = 25;
    defparam Cnt_25M.k = 25_000_000;

    Letter_Symbol Letter_Select (.SW(SW), .Q(Letter_in));
    Letter_Size Size_Letter (.SW(SW), .En(1'b1), .Load(Start), .Q(Size), .Clk(Clk), .Reset(Reset));
   
   // 입력으로 들어온 문자를 필요한 길이만큼 필터링
   // Enable 및 Size 지정 시에 안전하게 (X or Z) 값을 할당하기 위함.
    reg [3:0] Mask;
    wire [3:0] Symbol = Letter_in & Mask;
   
   /*

	ex) Size = 3'd2, Mask = 4'b1100일 때
	     Letter_in(A) = 01xx에서 01만 사용하므로 
             Symbol = Letter_in & Mask = 0100

    */
    always @(*) 
    case (Size)
	// E
        3'd1: Mask = 4'b1000;
	// A
        3'd2: Mask = 4'b1100;
	// D, G
        3'd3: Mask = 4'b1110;
	// B, C, F, H
        3'd4: Mask = 4'b1111;
        default: Mask = 4'b0000;
    endcase

    always @(posedge Clk or negedge Reset) begin
        if (!Reset) 
	begin
            LEDR   <= 1'b0;
            State <= 2'b00;
            Count  <= 2'b00;
            Index  <= 2'd3;
            Remain <= 3'd0;
        end 

	else if (!Start) 
	begin
            LEDR   <= 1'b0;
            State <= 2'b00;
            Count  <= 2'b00;
            Index  <= 2'd3;
            Remain <= Size;
        end
 	// 0.5s pulse 동작 시에만
	else if (Rollover_25M) 
	case (State)
	    // 다음 동작 판단
            Wait: begin
                LEDR <= 1'b0;
		// 남은 신호가 없을 때 -> 즉, 출력 끝
                if (Remain == 0)
                    State <= End;

                else 
		begin
		    // Mask가 없다면 State 신호에 X 들어갈 수 있음
                    State <= (Symbol[Index] ? Dash : Dot);
                    if (Index != 0) 
			Index <= Index - 1'b1;
                end

            end
	    // dot 0.5s pulse
            Dot: begin
                LEDR   <= 1'b1;
                Remain <= Remain - 1'b1;
                State <= Wait;
            end
	    // dash
            Dash: begin
                LEDR  <= 1'b1;
                Count <= Count + 1'b1;

		// dash이므로 0.5s pulse x3 
                if (Count == 2) 
		begin
                    Count  <= 2'b00;
                    Remain <= Remain - 1'b1;
                    State <= Wait;
                end

            end
	    // 신호가 다 출력 됐을 때
            End: LEDR <= 1'b0;
        endcase
    end
endmodule
