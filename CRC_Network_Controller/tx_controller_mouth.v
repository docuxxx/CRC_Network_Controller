// 모듈: TX Controller (Mouth) - 136비트 직접 인덱싱 및 실시간 CRC
// 최종 수정: CRC Direct Indexing & Timing Fix 완료 
module tx_controller_mouth (clk, rst_n, tx_start, tx_packet, tx_line, tx_busy, test_mode);

    input clk;
    input rst_n;
    
    input tx_start;            // 전송 시작 신호
    input [135:0] tx_packet;   // Brain에서 온 136비트 통 데이터
    input test_mode;           // 에러 주입 모드

    output reg tx_line;      //전송선은 1비트니깐
    output reg tx_busy;            

    // 상태 정의
    parameter S_IDLE     = 3'b000;
    parameter S_PREAMBLE = 3'b001;
    parameter S_SFD      = 3'b010;
    parameter S_HEADER   = 3'b011;
    parameter S_DATA     = 3'b100;
    parameter S_CRC      = 3'b101;

    parameter [15:0] PREAMBLE_PATTERN = 16'b1010101010101010;
    parameter [7:0]  SFD_PATTERN      = 8'b10101011;

    // 내부 레지스터
    reg [2:0] state;
    reg [7:0] bit_cnt;

    reg [7:0] tx_header;       //destid, myid,length        
    reg [127:0] shift_reg;     // Payload 저장용
    
    // CRC 관련 신호
    wire [7:0] crc_calc;
    wire crc_in;                // reg-->wire로 수정 완료
    reg crc_clear;              
    reg crc_en;                 
    
    // [삭제됨] reg [7:0] crc_result_latch; <- 이제 필요 없음!
    assign crc_in = shift_reg[127]; // 레지스터 맨 앞을 전선으로 바로 연결!

    // CRC 모듈 인스턴스
    crc8_serial u_crc_tx (
        .clk(clk),
        .rst_n(rst_n),
        .clear(crc_clear),
        .data_in(crc_in),
        .enable(crc_en),
        .crc_out(crc_calc)
    );

    // Main FSM
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            state            <= S_IDLE;
            bit_cnt          <= 8'd0;
            
            tx_header        <= 8'd0;
            shift_reg        <= 128'd0;
            
            tx_line          <= 1'b0;
            tx_busy          <= 1'b0;
            
            // [삭제됨] crc_result_latch 초기화 삭제
            crc_clear        <= 1'b1;
            crc_en           <= 1'b0;
            // crc_in 초기화 삭제 (wire라서 초기화 불필요)
        end
        else
        begin
            crc_en    <= 1'b0;
            crc_clear <= 1'b0; 

            case (state)
                S_IDLE:
                begin
                    tx_line <= 1'b0;
                    tx_busy <= 1'b0;
                    bit_cnt <= 8'd0;
                    crc_clear <= 1'b1; 

                    if (tx_start)
                    begin
                        state      <= S_PREAMBLE;
                        tx_busy    <= 1'b1;
                        
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
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_DATA:
                begin
                    //1. [출력 결정] 현재 shift_reg[127] 값을 보고 tx_line에 뭘 실을지 정함
                    if (test_mode && (bit_cnt == 0))
                        tx_line <= ~shift_reg[127]; 
                    else
                        tx_line <= shift_reg[127];
                    
                    shift_reg <= {shift_reg[126:0], 1'b0};
                    crc_en <= 1'b1;

                    // 종료 조건, tx_length 대신 tx_header[3:0] 사용,(Header의 하위 4비트가 곧 Length이므로)
                    if (bit_cnt == ((tx_header[3:0] + 1) * 8) - 1)
                    begin
                        state   <= S_CRC;
                        bit_cnt <= 0;
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_CRC:
                begin
                    // [직접 인덱싱] MSB(7)부터 LSB(0)까지 순서대로 전송
                    tx_line <= crc_calc[7 - bit_cnt];

                    if (bit_cnt == 7)
                    begin
                        state   <= S_IDLE; // [수정됨] IDLE -> S_IDLE 로 오타 수정
                        tx_busy <= 1'b0;
                        bit_cnt <= 0;
                    end
                    else bit_cnt <= bit_cnt + 1;
                end

                default: state <= S_IDLE;
            endcase
        end
    end

endmodule
