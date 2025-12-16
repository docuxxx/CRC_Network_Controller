// Rx 탑 모듈
module Rx (CLOCK_50, KEY, SW, GPIO, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    input CLOCK_50;
    input [1:0] KEY; // KEY0: Reset KEY1: 미지정 상태, 예비 key
    input [9:0] SW; // SW[9:8] = My ID
    inout GPIO; // GPIO[1] = Rx Line
    output [9:0] LEDR;
    output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // 내부 연결선 (rx_receiver 출력 신호들)
    wire [1:0] dest_id;
    wire [1:0] src_id;
    wire [127:0] payload;
    wire frame_valid;
    wire crc_error;

    // 목적지 ID 불일치 표시
    reg invalid_packet;

    // 수신기 - 시리얼 비트 수신 및 패킷
    rx_receiver receiver (.clk(CLOCK_50), .rst_n(KEY[0]), .rx_line(GPIO), 
    .dest_id(dest_id), .src_id(src_id), .payload(payload), .frame_valid(frame_valid), 
    .crc_error(crc_error));

    // 목적지 ID 비교 (내 ID: SW[9:8])
    always @(posedge CLOCK_50 or negedge KEY[0]) begin
        if (!KEY[0])
            invalid_packet <= 1'b0;
        else if (frame_valid) begin
            if (dest_id != SW[9:8])
                invalid_packet <= 1'b1;
            else
                invalid_packet <= 1'b0;
        end
    end

    // 수신된 Payload의 LSB 1 byte 출력
    hex_decoder Display0 (.A(payload[3:0]), .HEX(HEX0));
    hex_decoder Display1 (.A(payload[7:4]), .HEX(HEX1));

    // dest_id, src_id 표시
    hex_decoder Display2 (.A({2'b00, dest_id}), .HEX(HEX2));
    hex_decoder Display3 (.A({2'b00, src_id }), .HEX(HEX3));

    // 사용 안 하는 HEX 끄기
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;

    // 4. LED 표시 (상태 출력)
    // LEDR[0] = frame_valid (정상 수신)
    // LEDR[1] = crc_error   (CRC 오류)
    // LEDR[2] = invalid packet (ID 불일치)
    assign LEDR[0] = frame_valid;
    assign LEDR[1] = crc_error;
    assign LEDR[2] = invalid_packet;

    // 나머지 LED 끄기
    assign LEDR[9:3] = 7'd0;

endmodule
