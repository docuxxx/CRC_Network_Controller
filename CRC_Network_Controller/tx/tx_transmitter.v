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
    reg [7:0] tx_header;
    reg [127:0] shift_reg;
    
    // [수정 1] crc_en을 wire로 변경하고 상태에 따라 즉시 켜지도록 설정
    wire [7:0] crc_calc;
    wire crc_in;
    wire crc_en;             
    reg crc_clear;
    
    assign crc_in = shift_reg[127];
    assign crc_en = (state == S_DATA); // S_DATA 상태일 때만 CRC 활성화 (콤비네이션)

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
            state       <= S_IDLE;
            bit_cnt     <= 8'd0;
            tx_header   <= 8'd0;
            shift_reg   <= 128'd0;
            tx_line     <= 1'b0;
            crc_clear   <= 1'b1;
        end
        else
        begin
            // crc_en 제어 코드 삭제됨 (assign으로 대체)
            crc_clear <= 1'b0; 

            case (state)
                S_IDLE:
                begin
                    tx_line <= 1'b0;
                    bit_cnt <= 8'd0;
                    crc_clear <= 1'b1; 

                    if (tx_start)
                    begin
                        state      <= S_PREAMBLE;
                        tx_header  <= tx_packet[135:128];
                        shift_reg  <= tx_packet[127:0];
                    end
                end

                S_PREAMBLE:
                begin
                    tx_line <= PREAMBLE_PATTERN[15 - bit_cnt];
                    if (bit_cnt == 15) 
                    begin 
                        state <= S_SFD;
                        bit_cnt <= 0; 
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_SFD:
                begin
                    tx_line <= SFD_PATTERN[7 - bit_cnt];
                    if (bit_cnt == 7)
                    begin
                        state   <= S_HEADER;
                        bit_cnt <= 0;
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_HEADER:
                begin
                    tx_line <= tx_header[7 - bit_cnt];
                    if (bit_cnt == 7)
                    begin
                        state   <= S_DATA;
                        bit_cnt <= 0;
                        
                        // [수정 2] Data 구간의 첫 비트를 미리 내보냄 (1클럭 지연 방지)
                        if (test_mode) tx_line <= ~shift_reg[127];
                        else           tx_line <= shift_reg[127];
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_DATA:
                begin
                    // 현재 비트 출력
                    if (test_mode && (bit_cnt == 0))
                        tx_line <= ~shift_reg[127];
                    else
                        tx_line <= shift_reg[127];
                    
                    // 시프트는 정상적으로 진행
                    shift_reg <= {shift_reg[126:0], 1'b0};

                    // 종료 조건
                    if (bit_cnt == ((tx_header[3:0] + 1) * 8) - 1)
                    begin
                        state   <= S_CRC;
                        bit_cnt <= 0;
                        
                        // [수정 3] CRC 구간의 첫 비트를 미리 내보냄
                        tx_line <= crc_calc[7];
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_CRC:
                begin
                    tx_line <= crc_calc[7 - bit_cnt];
                    if (bit_cnt == 7)
                    begin
                        state   <= S_IDLE;
                        bit_cnt <= 0;
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                default: state <= S_IDLE;
            endcase
        end
    end
endmodule