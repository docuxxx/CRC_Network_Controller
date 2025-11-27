module tx_controller_mouth (clk, rst_n, tx_start, tx_data, tx_len, tx_dest_id, my_id, tx_line, tx_busy);

    // ... (포트 및 파라미터 선언부는 기존과 동일) ...
    input wire clk;                 
    input wire rst_n;               
    input wire tx_start;            
    input wire [127:0] tx_data;     
    input wire [3:0] tx_len;        
    input wire [1:0] tx_dest_id;    
    input wire [1:0] my_id;         

    output reg tx_line;             
    output reg tx_busy;             

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
    reg [127:0] shift_reg;  
    reg [3:0] len_reg;      
    
    wire [7:0] crc_calc;    
    reg [7:0] crc_reg;      
    reg crc_clear;          
    reg crc_en;             
    reg crc_in;             

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
            state     <= S_IDLE;
            tx_line   <= 1'b0;
            tx_busy   <= 1'b0;
            bit_cnt   <= 0;
            shift_reg <= 128'd0;
            len_reg   <= 4'd0;
            crc_reg   <= 8'd0;
            crc_clear <= 1'b1;
            crc_en    <= 1'b0;
            crc_in    <= 1'b0;
        end
        else
        begin
            crc_en    <= 1'b0;
            crc_clear <= 1'b0;

            case (state)
                // ... (S_IDLE, S_PREAMBLE, S_SFD, S_HEADER는 기존과 동일) ...
                S_IDLE:
                begin
                    tx_line   <= 1'b0;
                    bit_cnt   <= 0;
                    crc_clear <= 1'b1; 
                    
                    if (tx_start)
                    begin
                        state     <= S_PREAMBLE;
                        tx_busy   <= 1'b1;
                        shift_reg <= tx_data;
                        len_reg   <= tx_len;
                    end
                    else
                        tx_busy   <= 1'b0;
                end

                S_PREAMBLE:
                begin
                    tx_line <= PREAMBLE_PATTERN[15 - bit_cnt];
                    if (bit_cnt == 15) begin state <= S_SFD; bit_cnt <= 0; end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_SFD:
                begin
                    tx_line <= SFD_PATTERN[7 - bit_cnt];
                    if (bit_cnt == 7) begin state <= S_HEADER; bit_cnt <= 0; end
                    else bit_cnt <= bit_cnt + 1;
                end

                S_HEADER:
                begin
                    if (bit_cnt == 0)      tx_line <= tx_dest_id[1];
                    else if (bit_cnt == 1) tx_line <= tx_dest_id[0];
                    else if (bit_cnt == 2) tx_line <= my_id[1];
                    else if (bit_cnt == 3) tx_line <= my_id[0];
                    else if (bit_cnt == 4) tx_line <= len_reg[3];
                    else if (bit_cnt == 5) tx_line <= len_reg[2];
                    else if (bit_cnt == 6) tx_line <= len_reg[1];
                    else if (bit_cnt == 7) tx_line <= len_reg[0];

                    if (bit_cnt == 7)
                    begin
                        state   <= S_DATA;
                        bit_cnt <= 0;
                    end
                    else
                        bit_cnt <= bit_cnt + 1;
                end

                // [수정됨] Payload 데이터 보내기 (MSB First로 변경)
                // RX와 정렬을 맞추기 위해 가장 왼쪽 비트(127)부터 보냅니다.
                S_DATA:
                begin
                    // MSB(127번 비트)부터 전송
                    tx_line   <= shift_reg[127];
                    
                    // 다음 비트를 위해 데이터를 왼쪽으로 밈 (Left Shift)
                    shift_reg <= {shift_reg[126:0], 1'b0}; 

                    // CRC 계산기에도 MSB 입력
                    crc_en <= 1'b1;
                    crc_in <= shift_reg[127];

                    if (bit_cnt == (len_reg * 8) - 1)
                    begin
                        state   <= S_CRC;
                        bit_cnt <= 0;
                    end
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                // [수정됨] CRC 체크섬 보내기 (MSB First로 변경)
                S_CRC:
                begin
                    if (bit_cnt == 0)
                    begin
                        // 계산된 결과의 MSB(7번) 전송
                        tx_line <= crc_calc[7];       
                        // 나머지는 레지스터에 저장 (왼쪽으로 밈)
                        crc_reg <= {crc_calc[6:0], 1'b0}; 
                    end
                    else
                    begin
                        // 레지스터의 MSB 전송
                        tx_line <= crc_reg[7];        
                        crc_reg <= {crc_reg[6:0], 1'b0};
                    end

                    if (bit_cnt == 7)
                    begin
                        state   <= S_IDLE; // 끝!
                        bit_cnt <= 0;
                        tx_busy <= 1'b0;
                    end
                    else
                    begin
                        bit_cnt <= bit_cnt + 1;
                    end
                end

                default: 
                    state <= S_IDLE;
            endcase
        end
    end

endmodule