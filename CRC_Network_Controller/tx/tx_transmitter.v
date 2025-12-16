module tx_transmitter (clk, rst_n, tx_start, tx_packet, tx_line, test_mode);
    input clk;
    input rst_n;
    input tx_start;
    input [135:0] tx_packet;
    input test_mode;
    output reg tx_line;

    // 상태 정의
    parameter S_IDLE     = 3'b000;
    parameter S_PREAMBLE = 3'b001;
    parameter S_SFD      = 3'b010;
    parameter S_HEADER   = 3'b011;
    parameter S_DATA     = 3'b100;
    parameter S_CRC      = 3'b101;

    parameter [15:0] PREAMBLE_PATTERN = 16'b1010101010101010;
    parameter [7:0]  SFD_PATTERN      = 8'b10101011;

    reg [2:0] state;
    reg [7:0] bit_cnt;
    
    // [추가] Shift 동작을 위한 레지스터들
    reg [15:0] preamble_reg;
    reg [7:0]  sfd_reg;
    reg [7:0]  tx_header;      // 이제 Shift 되므로 원본 값 보존 안 됨
    reg [127:0] shift_reg;     // Data Payload
    reg [7:0]  crc_reg;        // [CRC] Shift용 레지스터 추가
    reg [3:0]  packet_len;     // Header가 Shift 되면 길이 정보가 사라지므로 백업용

    // [추가] Next State Logic (Combinational)
    wire [15:0] preamble_next;
    wire [7:0]  sfd_next;
    wire [7:0]  tx_header_next;
    wire [127:0] shift_reg_next;
    wire [7:0]  crc_next;      // [CRC] Next wire 추가

    // 모든 레지스터는 MSB부터 나가므로 왼쪽으로 Shift (LSB는 0 채움)
    assign preamble_next  = {preamble_reg[14:0], 1'b0};
    assign sfd_next       = {sfd_reg[6:0],       1'b0};
    assign tx_header_next = {tx_header[6:0],     1'b0};
    assign shift_reg_next = {shift_reg[126:0],   1'b0};
    assign crc_next       = {crc_reg[6:0],       1'b0}; // [CRC] Shift 로직

    // CRC 제어 신호
    wire [7:0] crc_calc;
    wire crc_in;
    wire crc_en;             
    reg crc_clear;
    
    assign crc_in = shift_reg[127]; // Data 단계에서 나가는 비트
    assign crc_en = (state == S_DATA); 

    crc8_serial u_crc_tx (
        .clk(clk),
        .rst_n(rst_n),
        .clear(crc_clear),
        .data_in(crc_in),
        .enable(crc_en),
        .crc_out(crc_calc)
    );

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            state        <= S_IDLE;
            bit_cnt      <= 8'd0;
            tx_line      <= 1'b0;
            
            preamble_reg <= 16'd0;
            sfd_reg      <= 8'd0;
            tx_header    <= 8'd0;
            shift_reg    <= 128'd0;
            crc_reg      <= 8'd0;  // [CRC] 초기화
            packet_len   <= 4'd0;
            
            crc_clear    <= 1'b1;
        end
        else
        begin
            crc_clear <= 1'b0;

            case (state)
                S_IDLE:
                begin
                    tx_line   <= 1'b0;
                    bit_cnt   <= 8'd0;
                    crc_clear <= 1'b1; 

                    if (tx_start)
                    begin
                        state <= S_PREAMBLE;
                        
                        // [로드] 모든 데이터를 레지스터에 장전
                        preamble_reg <= PREAMBLE_PATTERN;
                        sfd_reg      <= SFD_PATTERN;
                        tx_header    <= tx_packet[135:128]; // Header
                        packet_len   <= tx_packet[131:128]; // Length 백업 (Header[3:0])
                        shift_reg    <= tx_packet[127:0];   // Payload
                    end
                end

                S_PREAMBLE:
                begin
                    tx_line <= preamble_reg[15]; // MSB 출력
                    
                    // [Shift] Next 값 업데이트
                    preamble_reg <= preamble_next;

                    if (bit_cnt == 15) 
                    begin 
                        state   <= S_SFD;
                        bit_cnt <= 0; 
                    end
                    else 
                        bit_cnt <= bit_cnt + 1;
                end

                S_SFD:
                begin
                    tx_line <= sfd_reg[7]; // MSB 출력

                    // [Shift] Next 값 업데이트
                    sfd_reg <= sfd_next;

                    if (bit_cnt == 7)
                    begin
                        state   <= S_HEADER;
                        bit_cnt <= 0;
                    end
                    else 
                        bit_cnt <= bit_cnt + 1;
                end

                S_HEADER:
                begin
                    tx_line <= tx_header[7]; // MSB 출력

                    // [Shift] Next 값 업데이트
                    tx_header <= tx_header_next;

                    if (bit_cnt == 7)
                    begin
                        state   <= S_DATA;
                        bit_cnt <= 0;
                    end
                    else 
                        bit_cnt <= bit_cnt + 1;
                end

                S_DATA:
                begin
                    // 현재 비트 출력 (Test Mode 시 첫 비트 반전)
                    if (test_mode && (bit_cnt == 0))
                        tx_line <= ~shift_reg[127];
                    else
                        tx_line <= shift_reg[127];

                    // [Shift] Next 값 업데이트
                    shift_reg <= shift_reg_next;

                    // 종료 조건 확인 (백업해둔 packet_len 사용)
                    if (bit_cnt == ((packet_len + 1) * 8) - 1)
                    begin
                        state   <= S_CRC;
                        bit_cnt <= 0;
                    end
                    else 
                        bit_cnt <= bit_cnt + 1;
                end

                S_CRC:
                begin
                    if (bit_cnt == 0) 
                    begin
                        // [CRC Load] 첫 클럭: 계산 완료된 값(crc_calc) 사용 및 로드
                        // bit_cnt 0일 때 MSB를 바로 내보내고, 나머지는 Shift해서 저장
                        tx_line <= crc_calc[7];
                        crc_reg <= {crc_calc[6:0], 1'b0};
                    end
                    else 
                    begin
                        // [CRC Shift] 이후 클럭: 레지스터 사용
                        tx_line <= crc_reg[7];
                        crc_reg <= crc_next;
                    end

                    if (bit_cnt == 7)
                    begin
                        state   <= S_IDLE;
                        bit_cnt <= 0;
                    end
                    else 
                        bit_cnt <= bit_cnt + 1;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule