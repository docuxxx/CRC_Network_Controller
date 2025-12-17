module Tx (CLOCK_50, KEY, SW, GPIO, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

    input CLOCK_50;
    input [1:0] KEY;
    input [9:0] SW;
    inout GPIO;
    output [9:0] LEDR;
    output [0:6] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    wire [135:0] w_packet;
    wire w_test_mode;
    wire w_transmitter_rst_n;
	reg [2:0] clk_divide;
    always @(posedge CLOCK_50)
        clk_divide <= clk_divide + 1;

    tx_input_register u_assembler (.load(KEY[0]), .mode(SW[9:8]), .data(SW[7:0]), 
    .tx_packet(w_packet), .test_mode(w_test_mode),
    .flag_status(LEDR[1:0]), .rst_out_n(w_transmitter_rst_n));

    tx_transmitter u_transmitter ( .clk(clk_divide[2]), .rst_n(w_transmitter_rst_n), 
    .tx_start(KEY[1]), .tx_packet(w_packet), .test_mode(w_test_mode),
    .tx_line(GPIO));

    hex_decoder h0 (.A(SW[3:0]), .HEX(HEX0));
    hex_decoder h1 (.A(SW[7:4]), .HEX(HEX1));
    hex_decoder h5 (.A({2'b00, SW[9:8]}), .HEX(HEX5));

    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;

    assign LEDR[2] = 1'b0;
    assign LEDR[8:4] = 5'd0;
	assign LEDR[9] = w_test_mode;

endmodule