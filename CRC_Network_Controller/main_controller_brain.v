// ============================================================================
// 모듈: Main Controller (데이터 정렬 버그 수정 및 스타일 적용)
// ============================================================================
module main_controller_brain (clk, rst_n, master_slave_sw, load_send_sw, btn_action, target_id_sw, sw_data, rx_valid, rx_data, sender_id, rx_len, tx_start, tx_data, tx_len, tx_dest_id);

    // -----------------------------------------------------------------
    // 포트 선언 (Non-ANSI, One-line)
    // -----------------------------------------------------------------
    input wire clk;
    input wire rst_n;
    input wire master_slave_sw;
    input wire load_send_sw;
    input wire btn_action;
    input wire [1:0] target_id_sw;
    input wire [7:0] sw_data;
    input wire rx_valid;
    input wire [127:0] rx_data;
    input wire [1:0] sender_id;
    input wire [3:0] rx_len;
    
    output reg tx_start;
    output reg [127:0] tx_data;
    output reg [3:0] tx_len;
    output reg [1:0] tx_dest_id;

    // -----------------------------------------------------------------
    // 내부 신호 및 파라미터
    // -----------------------------------------------------------------
    reg [31:0] saved_value;
    reg prev_btn_state;
    wire btn_pressed;
    
    // 쉬프트 연산을 위한 정수형 변수
    integer shift_amount;

    // -----------------------------------------------------------------
    // 버튼 엣지 검출 (Rising Edge of Button release logic)
    // -----------------------------------------------------------------
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            prev_btn_state <= 1'b1;
        end
        else
        begin
            prev_btn_state <= btn_action;
        end
    end

    // 버튼이 눌렸다가 떼질 때 동작 (Active Low 버튼 가정 시)
    // 만약 누르는 순간 동작하길 원하면 로직 반전 필요. 여기서는 기존 코드 유지.
    assign btn_pressed = (prev_btn_state == 1'b1) && (btn_action == 1'b0);

    // -----------------------------------------------------------------
    // 메인 로직
    // -----------------------------------------------------------------
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            tx_start    <= 1'b0;
            tx_data     <= 128'd0;
            tx_dest_id  <= 2'b00;
            saved_value <= 32'd0;
            tx_len      <= 4'd0;
        end
        else
        begin
            tx_start <= 1'b0; // Default: Pulse 형태 유지

            // 1. 데이터 저장 (SW -> Register)
            if (btn_pressed && (load_send_sw == 1'b0))
            begin
                // 하위 8비트에 스위치 값 저장
                saved_value <= {24'd0, sw_data}; 
            end

            // 2. 마스터 모드 (송신)
            if (master_slave_sw == 1'b1)
            begin
                // 초기 전송 (버튼 누르면 전송)
                if (btn_pressed && (load_send_sw == 1'b1))
                begin
                    tx_start   <= 1'b1;
                    tx_dest_id <= target_id_sw;
                    tx_len     <= 4'd4; // 4바이트 전송 (예시)
                    
                    // [버그 수정] TX는 MSB(127)부터 전송하므로 데이터를 최상위로 밀어올림
                    // 4바이트(32비트)를 보내므로 128-32 = 96비트만큼 Left Shift
                    tx_data    <= {saved_value, 96'd0}; 
                end
                
                // 루프백 응답 (Echo 수신 시 동작 정의 - 필요시 추가)
                if (rx_valid)
                begin
                    // 마스터가 루프백 받은 경우 처리 (Display만 하고 전송 안함 등)
                end
            end
            
            // 3. 슬레이브 모드 (수신 및 루프백)
            else
            begin
                // 유효한 패킷 수신 시 자동 응답 (Loopback)
                if (rx_valid)
                begin
                    tx_start   <= 1'b1;
                    tx_dest_id <= sender_id; // 보낸 사람에게 다시 전송
                    tx_len     <= rx_len;    // 받은 길이만큼 전송
                    
                    // [버그 수정] Loopback 데이터 정렬
                    // rx_data는 LSB 정렬되어 들어옴 (0~N). 
                    // tx_data는 MSB 정렬 필요 (127~M).
                    // 계산: tx_data = (rx_data + saved_value) << (128 - (rx_len * 8))
                    // Verilog에서 가변 쉬프트는 자원 소모가 크지만 로직상 이것이 정확함.
                    
                    case (rx_len)
                        4'd1: tx_data <= (rx_data + saved_value) << 120;
                        4'd2: tx_data <= (rx_data + saved_value) << 112;
                        4'd4: tx_data <= (rx_data + saved_value) << 96;
                        // 필요에 따라 다른 길이 케이스 추가
                        default: tx_data <= (rx_data + saved_value) << 96; // Default 4 bytes
                    endcase
                end
            end
        end
    end

endmodule