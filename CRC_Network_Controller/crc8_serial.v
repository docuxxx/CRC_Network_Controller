// ============================================================================
// 모듈: CRC-8 Serial (RX 전용 - 1비트씩 계산)
// ============================================================================
module crc8_serial (clk, rst_n, clear, data_in, enable, crc_out);
    input wire clk; 
    input wire rst_n; 
    input wire clear; 
    input wire data_in; 
    input wire enable;
    
    output reg [7:0] crc_out;
    
    wire feedback;
    // 다항식: x^8 + x^2 + x + 1
    assign feedback = crc_out[7] ^ data_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) 
            crc_out <= 8'd0;
        else begin
            if (clear) 
                crc_out <= 8'd0;
            else if (enable) begin
                crc_out[0] <= feedback;
                crc_out[1] <= feedback ^ crc_out[0];
                crc_out[2] <= feedback ^ crc_out[1];
                crc_out[3] <= crc_out[2];
                crc_out[4] <= crc_out[3];
                crc_out[5] <= crc_out[4];
                crc_out[6] <= crc_out[5];
                crc_out[7] <= crc_out[6];
            end
        end
    end
endmodule
