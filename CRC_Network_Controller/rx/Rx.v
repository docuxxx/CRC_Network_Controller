// Rx 탑 모듈
module Rx (KEY, CLOCK_50, SW, GPIO, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    input [1:0] KEY;      // KEY0: Reset, KEY1: 예비
    input [9:0] SW;       // SW[9:8]: My ID, SW[3:0]: Payload Byte Selector
    input CLOCK_50;
    inout GPIO;    
    output [9:0] LEDR;
    output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    // 내부 연결선
    wire [1:0] dest_id;
    wire [1:0] src_id;
    wire [127:0] payload;
    wire frame_valid;
    wire crc_error;
	reg [4:0] clk_div;
	always @(posedge CLOCK_50)
	    clk_div <= clk_div +1;
    // 목적지 ID 불일치 표시
    reg invalid_packet;

    rx_receiver receiver (.clk(clk_div[4]), .rst_n(KEY[0]), .rx_line(GPIO), .dest_id(dest_id), 
        .src_id(src_id), .payload(payload), .frame_valid(frame_valid), .crc_error(crc_error));

    // 목적지 ID 비교
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

    reg [7:0] display_byte; // 선택된 1바이트를 담을 변수

    // SW[3:0] 값에 따라 16바이트 중 하나를 선택 (Multiplexer)
    always @(*) begin
        case (SW[3:0])
            4'd15: display_byte = payload[127:120]; 
				4'd14: display_byte = payload[119:112];
				4'd13: display_byte = payload[111:104];
				4'd12: display_byte = payload[103:96];
				4'd11: display_byte = payload[95:88];
				4'd10: display_byte = payload[87:80];
				4'd9: display_byte = payload[79:72];
				4'd8: display_byte = payload[71:64];
				4'd7: display_byte = payload[63:56];
				4'd6: display_byte = payload[55:48];
				4'd5: display_byte = payload[47:40];
				4'd4: display_byte = payload[39:32];
				4'd3: display_byte = payload[31:24];
				4'd2: display_byte = payload[23:16];
				4'd1: display_byte = payload[15:8];
				4'd0: display_byte = payload[7:0]; 
            default: display_byte = 8'h00;
        endcase
    end

    // 선택된 바이트를 16진수로 출력
    hex_decoder Display0 (.A(display_byte[3:0]), .HEX(HEX0)); // 하위 4비트
    hex_decoder Display1 (.A(display_byte[7:4]), .HEX(HEX1)); // 상위 4비트

    // dest_id, src_id 표시
    hex_decoder Display2 (.A({2'b00, dest_id}), .HEX(HEX2));
    hex_decoder Display3 (.A({2'b00, src_id }), .HEX(HEX3));

    // 사용 안 하는 HEX 끄기
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;

    // LED 표시
    assign LEDR[0] = frame_valid;
    assign LEDR[1] = crc_error;
    assign LEDR[2] = invalid_packet;

    // 나머지 LED 끄기
    assign LEDR[9:3] = 7'd0;

endmodule
