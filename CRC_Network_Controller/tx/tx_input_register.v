module tx_input_register (load, mode, data, tx_packet, test_mode, flag_status, rst_out_n);
//                        key0,  sw9-8, sw7-0,                       LEDR0-1
input load; // key0
input [1:0] mode; //sw9-8, 00:reset,01:header,10:data,11:test mode
input [7:0] data; // input data

output reg [135:0] tx_packet; // save data
output reg test_mode; // sw98 11일때 
output [1:0] flag_status;
output wire rst_out_n;
assign rst_out_n = ~((mode == 2'b00) && (load == 1'b0));

reg [3:0] byte_ptr;//내부 변수
reg [3:0] target_length;//몇바이트 받을지 

reg flag_header_done;//상태 확인용 LEDR1
reg flag_data_done;  //상태 확인용 LEDR0

assign flag_status[1] = flag_header_done; // 헤더 저장되면 켜짐
assign flag_status[0] = flag_data_done;   // PAYLOAD 저장되면 켜짐

always @(negedge load) begin
        case (mode)
            // [Mode 00] 리셋
            2'b00: 
            begin
                tx_packet        <= 136'd0;
                byte_ptr         <= 4'd0;
                target_length    <= 4'd0;
                test_mode        <= 1'b0;
                flag_header_done <= 0;
                flag_data_done   <= 0;
            end

            // [Mode 01] 헤더 설정
            // SW 구조: [7:6]Dest, [5:4]MyID, [3:0]Length
            2'b01: 
            begin
                tx_packet[135:134] <= data[7:6]; // Destination ID
                tx_packet[133:132] <= data[5:4]; // Source ID (My ID)
                tx_packet[131:128] <= data[3:0]; // Payload Length
                
                target_length <= data[3:0];      // 길이 저장 (참고용)
                byte_ptr      <= 4'd0;           // 데이터 입력 포인터 초기화

                flag_header_done <= 1; // 로드 버튼 누르면 헤더 설정 완료로 간주
            end

            // [Mode 10] 데이터(Payload) 입력
            // 누를 때마다 1바이트씩 순차적으로 채움
            2'b10: 
            begin
                case (byte_ptr)
                    4'd0:  tx_packet[127:120] <= data;
                    4'd1:  tx_packet[119:112] <= data;
                    4'd2:  tx_packet[111:104] <= data;
                    4'd3:  tx_packet[103:96]  <= data;
                    4'd4:  tx_packet[95:88]   <= data;
                    4'd5:  tx_packet[87:80]   <= data;
                    4'd6:  tx_packet[79:72]   <= data;
                    4'd7:  tx_packet[71:64]   <= data;
                    4'd8:  tx_packet[63:56]   <= data;
                    4'd9:  tx_packet[55:48]   <= data;
                    4'd10: tx_packet[47:40]   <= data;
                    4'd11: tx_packet[39:32]   <= data;
                    4'd12: tx_packet[31:24]   <= data;
                    4'd13: tx_packet[23:16]   <= data;
                    4'd14: tx_packet[15:8]    <= data;
                    4'd15: tx_packet[7:0]     <= data;
                endcase

                // 포인터 증가 (최대 16바이트 넘지 않도록)
                if (byte_ptr < 15)
                begin
                    byte_ptr <= byte_ptr + 1;
                end

                if ((byte_ptr) == target_length) 
                begin
                    flag_data_done <= 1; //PAYLOAD 저장 완료 신호
                end
            end

            // [Mode 11] 테스트 모드
            2'b11: 
            begin
                test_mode <= 1; 
            end
        endcase
    end

endmodule
