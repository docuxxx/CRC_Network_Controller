module rx_controller_ear (clk, rst_n, rx_line, my_id, rx_data, rx_len, rx_valid, rx_crc_err, sender_id, fsm_state);

    // -----------------------------------------------------------------
    // 포트 선언
    // -----------------------------------------------------------------
    input wire clk;                 // 50MHz 시스템 클럭
    input wire rst_n;               // 리셋 (Active Low)
    input wire rx_line;             // 수신 라인 (GPIO 0)
    input wire [1:0] my_id;         // 내 ID (Destination 확인용)

    output reg [127:0] rx_data;     // 수신된 데이터 (최대 16바이트 = 128비트)
    output reg [3:0]   rx_len;      // 수신된 데이터 길이 (1~16)
    output reg rx_valid;            // "정상 수신 완료!" 신호
    output reg rx_crc_err;          // [추가] "CRC 에러 발생!" 신호 (디버깅용)
    output reg [1:0] sender_id;     // 보낸 사람 ID
    output wire [3:0] fsm_state;    // 상태 확인용

    // -----------------------------------------------------------------
    // 1. 상태 정의 (Length와 CRC 단계 추가됨)
    // -----------------------------------------------------------------
    parameter S_SEARCH_PREAMBLE = 3'd0;
    parameter S_CHECK_SFD       = 3'd1;
    parameter S_CHECK_ADDR      = 3'd2;
    parameter S_GET_LENGTH      = 3'd3; // [신규] 길이 정보(4bit) 읽기
    parameter S_RX_PAYLOAD      = 3'd4; // [변경] 가변 길이 데이터 받기
    parameter S_CHECK_CRC       = 3'd5; // [신규] CRC 검사
    parameter S_DONE            = 3'd6;

    // 패턴 정의
    parameter [15:0] PREAMBLE_PATTERN = 16'b1010101010101010; 
    parameter [7:0]  SFD_PATTERN      = 8'b10101011; // [변경] SFD는 1바이트(8비트)

    // -----------------------------------------------------------------
    // 2. 내부 신호
    // -----------------------------------------------------------------
    reg [2:0] state;
    reg [127:0] shift_reg;          // 최대 16바이트까지 저장할 거대한 가방
    reg [7:0] bit_cnt;              // 비트 카운터 (넉넉하게 8비트)
    
    reg [3:0] payload_len_latched;  // 읽어낸 길이 정보를 저장해둘 곳
    
    // [추가] CRC 관련 신호
    wire [7:0] calc_crc;            // 계산된 CRC 값
    reg crc_clear;                  // CRC 계산기 리셋 신호
    reg crc_en;                     // CRC 계산 활성화 (데이터 받을 때만 1)
    reg crc_in;                     // CRC 계산기로 들어가는 비트

    assign fsm_state = {1'b0, state};

    // -----------------------------------------------------------------
    // [추가] CRC 계산 모듈 인스턴스 (RX 내부에서 실시간 검증)
    // -----------------------------------------------------------------
    // *중요* CRC 모듈은 1비트씩 입력받아 계산하는 직렬(Serial) LFSR 방식이어야 함
    crc8_serial u_crc_rx (.clk(clk), .rst_n(rst_n), .clear(crc_clear), .data_in(crc_in), .enable(crc_en), .crc_out(calc_crc));

    // -----------------------------------------------------------------
    // RX FSM
    // -----------------------------------------------------------------
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            state               <= S_SEARCH_PREAMBLE;
            shift_reg           <= 128'd0;
            bit_cnt             <= 0;
            rx_valid            <= 0;
            rx_crc_err          <= 0;
            rx_data             <= 0;
            rx_len              <= 0;
            sender_id           <= 0;
            payload_len_latched <= 0;
            
            // [추가] CRC 제어 신호 초기화
            crc_clear           <= 1;
            crc_en              <= 0;
            crc_in              <= 0;
        end
        else
        begin
            // [추가] 기본적으로 CRC 계산은 끕니다 (데이터 받을 때만 킴)
            crc_en <= 0;
            crc_clear <= 0; // 리셋 해제

            // Sliding Window (Preamble 감지용)
            // 데이터 받을 때는 shift_reg를 데이터 저장용으로 씀
            if (state == S_SEARCH_PREAMBLE)
                shift_reg <= {shift_reg[126:0], rx_line};
            
            case (state)
                // 1. Preamble 찾기 (16비트)
                S_SEARCH_PREAMBLE:
                begin
                    rx_valid <= 0;
                    rx_crc_err <= 0;
                    crc_clear <= 1; // [추가] CRC 계산기 초기화 준비

                    // 하위 16비트만 비교
                    if (shift_reg[15:0] == PREAMBLE_PATTERN)
                    begin
                        state   <= S_CHECK_SFD;
                        bit_cnt <= 0;
                    end
                end

                // 2. SFD 확인 (8비트)
                S_CHECK_SFD:
                begin
                    // *주의* 12비트가 아니라 8비트(1바이트)로 변경됨
                    // SFD 받는 동안 shift_reg에 쌓음
                    shift_reg[7:0] <= {shift_reg[6:0], rx_line}; 

                    if (bit_cnt == 7)
                    begin
                        if ({shift_reg[6:0], rx_line} == SFD_PATTERN)
                        begin
                            state   <= S_CHECK_ADDR;
                            bit_cnt <= 0;
                        end
                        else
                        begin
                            state   <= S_SEARCH_PREAMBLE;
                        end
                    end
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                // 3. 주소 확인 (4비트: Dest 2bit + Src 2bit)
                S_CHECK_ADDR:
                begin
                    shift_reg[3:0] <= {shift_reg[2:0], rx_line};

                    if (bit_cnt == 3)
                    begin
                        // [Dest ID][Src ID] 순서로 들어옴
                        // shift_reg[3:2] = Dest, [1:0] = Src
                        // 현재 들어오는 비트(rx_line)가 Src의 마지막 비트임
                        
                        // 타이밍상 shift_reg에 완전히 들어가기 전 값을 확인해야 할 수도 있음
                        // 여기선 간단히 4비트 모인 값이라 가정
                        
                        // 내 주소 맞음 (상위 2비트 비교)
                        // 실제 구현에선: if (received_dest == my_id)
                        // 여기서는 편의상 무조건 수신하도록 설정 (테스트용)
                         sender_id <= {shift_reg[0], rx_line}; 
                         state     <= S_GET_LENGTH;
                         bit_cnt   <= 0;
                    end
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                // 4. [신규] 길이(Length) 정보 받기 (4비트)
                S_GET_LENGTH:
                begin
                    // 길이 정보 4비트 수신
                    shift_reg[3:0] <= {shift_reg[2:0], rx_line};

                    if (bit_cnt == 3)
                    begin
                        payload_len_latched <= {shift_reg[2:0], rx_line};
                        state               <= S_RX_PAYLOAD;
                        bit_cnt             <= 0;
                        crc_clear           <= 1; // [추가] Payload 받기 전 CRC 리셋 확실하게
                    end
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                // 5. [변경] Payload 받기 (가변 길이) & CRC 계산
                S_RX_PAYLOAD:
                begin
                    // 1비트씩 들어올 때마다 shift_reg에 저장
                    // 128비트 레지스터를 LSB부터 채워 넣음 (MSB First 전송 가정 시 shift 방향 주의)
                    // 여기서는 일반적인 LSB Shift Left 사용
                    shift_reg <= {shift_reg[126:0], rx_line};
                    
                    // [핵심] 들어오는 비트를 CRC 계산기에도 넣어줌!
                    crc_en <= 1;
                    crc_in <= rx_line;

                    // 목표 비트 수: Length(바이트) * 8 - 1
                    // 예: Length=1 -> 8비트(0~7)
                    if (bit_cnt == (payload_len_latched * 8) - 1)
                    begin
                        rx_data <= {shift_reg[126:0], rx_line}; // 데이터 캡처
                        rx_len  <= payload_len_latched;
                        state   <= S_CHECK_CRC;
                        bit_cnt <= 0;
                    end
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                // 6. [신규] CRC Checksum 받기 (1바이트) 및 검사
                S_CHECK_CRC:
                begin
                    // CRC 8비트 수신 (별도 레지스터에 저장해 비교)
                    shift_reg[7:0] <= {shift_reg[6:0], rx_line};

                    if (bit_cnt == 7)
                    begin
                        // 수신된 CRC와 내가 계산한 CRC가 같은지 확인
                        // {shift_reg[6:0], rx_line} : 수신된 CRC
                        // calc_crc : 내가 계산한 CRC
                        if ({shift_reg[6:0], rx_line} == calc_crc)
                        begin
                            state <= S_DONE;
                        end
                        else
                        begin
                            rx_crc_err <= 1;        // [추가] 에러 플래그 세움
                            state      <= S_DONE;   // 일단 끝내긴 함 (Main에서 err보고 버림)
                        end
                        bit_cnt <= 0;
                    end
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                // 7. 완료
                S_DONE:
                begin
                    if (!rx_crc_err) // 에러 없을 때만 Valid
                        rx_valid <= 1;
                    
                    state <= S_SEARCH_PREAMBLE;
                end

                default: 
                    state <= S_SEARCH_PREAMBLE;
            endcase
        end
    end

endmodule
