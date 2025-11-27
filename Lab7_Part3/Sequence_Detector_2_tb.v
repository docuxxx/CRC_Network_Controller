`timescale 1ns/10ps

module Sequence_Detector_2_tb();
    reg w, Clk, Reset;
    wire z;
    wire [7:4] LEDR;

    Sequence_Detector_2 DUT (w, z, Clk, Reset, LEDR);

    initial Clk = 0;
    always #1 Clk = ~Clk; 

    initial begin
        Reset = 0;
        w     = 0;
        @(posedge Clk);   
        Reset = 1;

        // state: 0
        w = 0;
        @(posedge Clk);    // z = 0

        // state: 0_1
        w = 1;
        @(posedge Clk);

        // state: 0_11
        w = 1;
        @(posedge Clk);

        // state: 0_110
        w = 0;
        @(posedge Clk);

        // state: 0_1101
        w = 1;
        @(posedge Clk);

        // state: 0_1101_1
        w = 1;
        @(posedge Clk);

        // state: 0_1101_11
        w = 1;
        @(posedge Clk);

        // state: 0_1101_111
        w = 1;
        @(posedge Clk);

        // state: 0_1101_1111 (detect)
        w = 1;
        @(posedge Clk);

        // state: 0_1101_1111_0
        w = 0;
        @(posedge Clk);

        // state: 0_1101_1111_00
        w = 0;
        @(posedge Clk);

        // state: 0_1101_1111_000
        w = 0;
        @(posedge Clk);

        // state: 0_1101_1111_0000 (detect)
        w = 0;
        @(posedge Clk);
       
        @(posedge Clk);
	@(posedge Clk);
	@(posedge Clk);

        #5 $stop;
    end
endmodule
