module Tx (
    input CLOCK_50,
    input [1:0] KEY,        // KEY0: Load(Clk), KEY1: Send(Start)
    input [9:0] SW,         // SW[9:8]: Mode, SW[7:0]: Data
    inout [35:0] GPIO,      // GPIO[1]: Tx Output line
    output [9:0] LEDR,      // Status LEDs
    output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

    // =============================================================
    // 내부 연결선 (모듈 간 데이터 전달용 필수 와이어)
    // =============================================================
    wire [135:0] w_packet;    // Assembler -> Transmitter (데이터 패킷)
    wire w_test_mode;         // Assembler -> Transmitter (에러 모드 플래그)
    wire w_transmitter_rst_n; // [수정] Assembler에서 받아올 리셋 신호용 와이어

    // =============================================================
    // 1. 입력 레지스터 (Assembler) - 데이터 조립
    // =============================================================
    tx_input_register u_assembler (
        .load       (KEY[0]),          // [입력] KEY0 직접 연결 (Falling Edge 동작)
        .mode       (SW[9:8]),         // [입력] SW Mode 직접 연결
        .data       (SW[7:0]),         // [입력] SW Data 직접 연결
        .tx_packet  (w_packet),        // [출력] 내부 와이어로 전달
        .test_mode  (w_test_mode),     // [출력] 내부 와이어로 전달
        .flag_status(LEDR[1:0])        // [출력] LEDR 0, 1번에 직접 꽂음
    );

    // =============================================================
    // 2. 송신기 (transmitter) - 전송 담당
    // =============================================================
    tx_transmitter u_transmitter (
        .clk        (CLOCK_50),        // [입력] 50MHz 시스템 클럭
        .rst_n      (w_transmitter_rst_n),   // [입력] 입력 레지스터 리셋 연결 
        .tx_start   (~KEY[1]),         // [입력] KEY1 누르면(Low->High) 전송 시작
        .tx_packet  (w_packet),        // [입력] Assembler에서 온 패킷
        .test_mode  (w_test_mode),     // [입력] Assembler에서 온 모드
        .tx_line    (GPIO[1]),         // [출력] GPIO[1] 핀에 직접 꽂음 (Tx Line)
        .tx_busy    (LEDR[3])          // [출력] LEDR[3] 핀에 직접 꽂음 (Busy)
    );

    // =============================================================
    // 3. 디스플레이 (HEX) - 상태 표시
    // =============================================================
    // 데이터 값 (SW[7:0]) 표시
    hex_decoder h0 (.A(SW[3:0]), .HEX(HEX0));
    hex_decoder h1 (.A(SW[7:4]), .HEX(HEX1));

    // 현재 모드 (SW[9:8]) 표시
    hex_decoder h5 (.A({2'b00, SW[9:8]}), .HEX(HEX5));

    // 사용하지 않는 HEX 및 LED 끄기 (Off = 1)
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    
    // 나머지 LEDR 끄기 (0=Off, LEDR[0,1,3]은 위에서 사용함)
    assign LEDR[2] = 1'b0;
    assign LEDR[9:4] = 6'd0;

endmodule