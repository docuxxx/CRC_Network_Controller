// ============================================================================
// 모듈: CRC-8 Serial (RX 전용 - 1비트씩 계산)
// ============================================================================
module crc8_serial (clk, rst_n, clear, data_in, enable, crc_out);
    input clk, rst_n, clear, data_in, enable; 
    output reg [7:0] crc_out;
    wire feedback;
    // [수학 원리: 나눌 수 있는지 확인]
    // 현재 나머지(crc_out)의 맨 앞자리와 새 데이터가 충돌하는가?
    // 충돌한다(1) = "숫자가 너무 커져서 깎아내야(XOR) 한다" (10진수에서 9보다 커진 상황)
    assign feedback = crc_out[7] ^ data_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            crc_out <= 8'd0;
        else begin
            if (clear) 
                crc_out <= 8'd0;
            else if (enable) begin
                // [동작 설명: 호너의 법칙 & 모듈러 연산]
                
                if (feedback)
                    // 1. {crc_out[6:0], 1'b0}: [자리 올림] 
                    //    현재 나머지에 2를 곱해서 자릿수를 올림 (10진수 예시: 1 -> 10)
                    // 2. ^ 8'h07: [나머지 연산/버리기] 
                    //    다항식(0x07)만큼 덜어내어(XOR) 나머지만 남김 (10진수 예시: 12 - 9 = 3)
                    crc_out <= {crc_out[6:0], 1'b0} ^ 8'h07;
                else
                    // 1. {crc_out[6:0], 1'b0}: [자리 올림]
                    //    피드백이 없으면 뺄셈 없이 자릿수만 올리고 끝냄
                    //    (10진수 예시: 1이 9보다 작으므로 그냥 10으로 만듦)
                    crc_out <= {crc_out[6:0], 1'b0};
            end
        end
    end
endmodule
