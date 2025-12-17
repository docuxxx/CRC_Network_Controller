// 실제 수신하고 연산하는 모듈
module rx_receiver (clk, rst_n, rx_line, dest_id, src_id, payload, frame_valid, crc_error);

    input clk;
    input rst_n;
    input rx_line;     // 네트워크 라인에서 들어오는 1비트 데이터

    output reg [1:0] dest_id;
    output reg [1:0] src_id;   
    output reg [127:0] payload;     // 최대 16바이트 저장

    output reg frame_valid;  // 정상 프레임 수신 완료(다음 프레임 수신 전까지 유지)
    output reg crc_error;    // CRC 에러 발생(다음 프레임 수신 전까지 유지)

    // 상태 정의
    localparam WAIT_PREAMBLE = 3'd0;
    localparam WAIT_SFD = 3'd1;
    localparam HEADER = 3'd2;
    localparam PAYLOAD = 3'd3;
    localparam RECIVED_CRC = 3'd4;

    // Tx와 동일한 패턴
    localparam [15:0] PREAMBLE_PATTERN = 16'b1010101010101010;
    localparam [7:0] SFD_PATTERN = 8'b10101011;

    reg [2:0] state;

    // 패턴 검출용 시프트 레지스터
    reg [15:0] preamble_shift;
    reg [7:0]  sfd_shift;

    // 헤더, CRC 수신용
    reg [7:0] header;
    reg [7:0] crc_received;
    reg [2:0] bit_cnt;          // 헤더/CRC에서 0~7 카운트

    // Payload 수신용
    reg [7:0] data_bit_cnt;     // 0 ~ 128
    reg [3:0] length;           // 헤더에서 받은 원본 length 필드

    wire [7:0] payload_bit_len;  // 총 수신해야 할 payload 비트 수
    // bitwise left shift는 2의 제곱 곱셈과 동일, 즉 3비트 shift는 8배 -> byte 단위
    assign payload_bit_len = (length + 1) << 3; 

    // 시리얼 비트로 들어오기 때문에 1비트씩 shift
    // 현재 들어온 비트까지 즉각 계산하기 위해 blocking (클럭과 동기화x)
    wire [15:0] preamble_shift_next = {preamble_shift[14:0], rx_line};
    wire [7:0] sfd_shift_next = {sfd_shift[6:0], rx_line};
    wire [7:0] header_next = {header[6:0], rx_line};
    wire [7:0] crc_received_next = {crc_received[6:0], rx_line};
    wire [127:0] payload_next = {payload[126:0], rx_line};

    // CRC 모듈 연결
    wire crc_enable; 
    reg crc_clear;
    wire [7:0] crc_computed;

    // CRC 계산은 헤더와 페이로드 구간에서만 활성화
    assign crc_enable = (state == PAYLOAD);

    crc8_serial crc_recived (.clk(clk), .rst_n(rst_n), .clear(crc_clear), 
    .data_in(rx_line), .enable(crc_enable), .crc_out(crc_computed));

    // 메인 FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin

            state <= WAIT_PREAMBLE;
            preamble_shift <= 16'd0;
            sfd_shift <= 8'd0;
            header <= 8'd0;
            crc_received <= 8'd0;
            bit_cnt <= 3'd0;
            data_bit_cnt <= 8'd0;

            dest_id <= 2'd0;
            src_id <= 2'd0;
            length <= 4'd0;
            payload <= 128'd0;

            frame_valid <= 1'b0;
            crc_error <= 1'b0;

            crc_clear <= 1'b1;   // 초기에는 CRC 레지스터 0 유지
        end
        else begin
            // 초기화 (CRC 제어 신호만 기본값 설정)
            crc_clear <= 1'b0;

            case (state)
                // PREAMBLE 검출
                WAIT_PREAMBLE: begin
                    // CRC는 이 구간 동안 항상 클리어 상태 유지
                    crc_clear <= 1'b1;
                    // PREAMBLE 제대로 수신됐는지 1비트씩 shift해서 detect
                    // if) 첫 프레임을 rx가 제대로 받지 못했다면, 다음 프레임부터 제대로 검출 가능. 이전 데이터는 인식x
                    preamble_shift <= preamble_shift_next;

                    // PREAMBLE 패턴이 맞으면 SFD 검출 상태로 이동
                    if (preamble_shift_next == PREAMBLE_PATTERN) begin
                        state <= WAIT_SFD;
                        sfd_shift <= 8'd0;
                    end
                end

                // SFD 검출
                WAIT_SFD: begin
                    crc_clear <= 1'b1;
                    sfd_shift <= sfd_shift_next;

                    if (sfd_shift_next == SFD_PATTERN) begin
                        state <= HEADER;
                        bit_cnt <= 3'd0;
                        header <= 8'd0;
                        end
                end     
                // 헤더 수신 
                HEADER: begin  

                    header <= header_next;
                    bit_cnt <= bit_cnt + 1;
                    // 1바이트 헤더 수신 완료했을 때 
                    if (bit_cnt == 3'd7) begin

                        dest_id <= header_next[7:6];
                        src_id  <= header_next[5:4];
                        length  <= header_next[3:0];

                        // Payload 수신 전 초기화
                        data_bit_cnt <= 8'd0;
                        payload      <= 128'd0;
                        state        <= PAYLOAD;
                    end
                end

                // Payload 수신 + CRC 계산 계속
                PAYLOAD: begin

                    payload      <= payload_next;
                    data_bit_cnt <= data_bit_cnt + 1;

                    if (data_bit_cnt == (payload_bit_len - 1)) begin
                        // Payload 끝 → CRC 바이트 수신으로 전환
                        state        <= RECIVED_CRC;
                        bit_cnt      <= 3'd0;
                        crc_received <= 8'd0;
                    end
                end

                // CRC 바이트 수신(8bit)
                RECIVED_CRC: begin
                    crc_received <= crc_received_next;
                    bit_cnt      <= bit_cnt + 1;

                    if (bit_cnt == 3'd7) begin
                        // crc_received_next가 최종 수신 CRC 값
                        if (crc_received_next == crc_computed) begin
                            frame_valid <= 1'b1;   // 정상 프레임
                            crc_error   <= 1'b0;
                        end
                        else begin
                            frame_valid <= 1'b0;
                            crc_error   <= 1'b1;   // CRC 불일치
                        end

                        // 다음 프레임 전 초기화
                        state          <= WAIT_PREAMBLE;
                        preamble_shift <= 16'd0;
                        sfd_shift      <= 8'd0;
                        data_bit_cnt   <= 8'd0;
                    end
                end

                default: state <= WAIT_PREAMBLE;
            endcase
        end
    end

endmodule
