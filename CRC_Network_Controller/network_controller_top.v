// ============================================================================
// 모듈: Top Module
// ============================================================================
module network_controller_top (MAX10_CLK1_50, KEY, SW, GPIO, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);

    // -------------------------------------------------------------------------
    // 포트 선언
    // -------------------------------------------------------------------------
    input wire MAX10_CLK1_50;
    input wire [1:0] KEY;       // KEY0: Reset, KEY1: Action
    input wire [9:0] SW;
    inout wire [35:0] GPIO;     // GPIO[0]: RX, GPIO[1]: TX
    output wire [0:6] HEX0;
    output wire [0:6] HEX1;
    output wire [0:6] HEX2;
    output wire [0:6] HEX3;
    output wire [0:6] HEX4;
    output wire [0:6] HEX5;
    output wire [9:0] LEDR;

    // -------------------------------------------------------------------------
    // 내부 신호
    // -------------------------------------------------------------------------
    wire clk_sys;
    wire rst_n;
    wire line_rx;
    wire line_tx;
    wire tx_busy;
    
    wire [127:0] rx_data_sig;
    wire [127:0] tx_data_sig;
    wire rx_valid_sig;
    wire [1:0] sender_id_sig;
    wire rx_crc_err_sig;
    wire [3:0] rx_len_sig;
    wire [3:0] tx_len_sig;
    wire tx_start_sig;
    wire [1:0] tx_dest_id_sig;
    wire [3:0] rx_fsm_state;

    // -------------------------------------------------------------------------
    // 할당
    // -------------------------------------------------------------------------
    assign clk_sys = MAX10_CLK1_50;
    assign rst_n   = KEY[0];
    
    // [하드웨어 연결 주의] 
    // 보드1(TX) GPIO[1] <---> 보드2(RX) GPIO[0]
    assign line_rx = GPIO[0];   // 입력
    assign GPIO[1] = line_tx;   // 출력
    
    // LED 표시
    assign LEDR[0]   = rx_valid_sig;
    assign LEDR[1]   = tx_busy;
    assign LEDR[2]   = rx_crc_err_sig;
    assign LEDR[8]   = SW[8];
    assign LEDR[9]   = SW[9];
    assign LEDR[6:3] = rx_fsm_state;

    // -------------------------------------------------------------------------
    // 인스턴스 연결
    // -------------------------------------------------------------------------
    
    main_controller_brain u_main (
        .clk            (clk_sys),
        .rst_n          (rst_n),
        .master_slave_sw(SW[9]),
        .load_send_sw   (SW[8]),
        .btn_action     (KEY[1]),
        .target_id_sw   (SW[9:8]), // 타겟 ID 설정 (SW9,8 사용 예시)
        .sw_data        (SW[7:0]),
        .rx_valid       (rx_valid_sig),
        .rx_data        (rx_data_sig),
        .sender_id      (sender_id_sig),
        .rx_len         (rx_len_sig),    // [중요] 포트 연결 확인
        .tx_start       (tx_start_sig),
        .tx_data        (tx_data_sig),
        .tx_len         (tx_len_sig),
        .tx_dest_id     (tx_dest_id_sig)
    );

    rx_controller_ear u_rx (
        .clk            (clk_sys),
        .rst_n          (rst_n),
        .rx_line        (line_rx),
        .my_id          (SW[9:8]), // 내 ID 설정
        .rx_data        (rx_data_sig),
        .rx_len         (rx_len_sig),
        .rx_valid       (rx_valid_sig),
        .rx_crc_err     (rx_crc_err_sig),
        .sender_id      (sender_id_sig),
        .fsm_state      (rx_fsm_state)
    );

    tx_controller_mouth u_tx (
        .clk            (clk_sys),
        .rst_n          (rst_n),
        .tx_start       (tx_start_sig),
        .tx_data        (tx_data_sig),
        .tx_len         (tx_len_sig),
        .tx_dest_id     (tx_dest_id_sig),
        .my_id          (SW[9:8]), 
        .tx_line        (line_tx),
        .tx_busy        (tx_busy)
    );

    display_controller_face u_disp (
        .clk            (clk_sys),
        .rx_data        (rx_data_sig[31:0]), // 하위 32비트만 표시
        .sender_id      (sender_id_sig),
        .hex0           (HEX0),
        .hex1           (HEX1),
        .hex2           (HEX2),
        .hex3           (HEX3),
        .hex4           (HEX4),
        .hex5           (HEX5)
    );

endmodule