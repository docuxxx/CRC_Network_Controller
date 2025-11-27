module display_controller_face (clk, rx_data, sender_id, hex0, hex1, hex2, hex3, hex4, hex5);

    input wire clk;             // System Clock
    input wire [31:0] rx_data;  // 32-bit Data from Main Controller
    input wire [1:0] sender_id; // 2-bit Sender ID

    // 7-Segment Outputs (Active Low, 7 bits each)
    output wire [0:6] hex0;     // Display Data LSB [3:0]
    output wire [0:6] hex1;     // Display Data [7:4]
    output wire [0:6] hex2;     // Display Data [11:8]
    output wire [0:6] hex3;     // Display Data [15:12]
    output wire [0:6] hex4;     // Separator (Blank)
    output wire [0:6] hex5;     // Display Sender ID

    // -----------------------------------------------------------------
    // 7-Segment Decoding Logic
    // -----------------------------------------------------------------
    
    // 1. Data Display: Show lower 16 bits of rx_data on HEX0 ~ HEX3
    // Even if input is 8-bit, the accumulated value can be larger.
    hex_decoder disp0 (.A(rx_data[3:0]),   .HEX(hex0));
    hex_decoder disp1 (.A(rx_data[7:4]),   .HEX(hex1));
    hex_decoder disp2 (.A(rx_data[11:8]),  .HEX(hex2));
    hex_decoder disp3 (.A(rx_data[15:12]), .HEX(hex3));

    // 2. Blank Display (HEX4) - Turn off all segments for visual separation
    // 7'b1111111 means all segments OFF (Active Low)
    assign hex4 = 7'b1111111; 

    // 3. Sender ID Display (HEX5)
    // Pad 2-bit ID with 0s to match 4-bit input of the decoder
    hex_decoder disp5 (.A({2'b00, sender_id}), .HEX(hex5));

endmodule

