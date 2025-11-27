`timescale 1ns/10ps

module Morse_Code_Generator_tb();

    reg [2:0] SW;
    reg Reset, Clk, Start;
    wire LEDR;

    Morse_Code_Generator DUT (.SW(SW), .LEDR(LEDR), .Reset(Reset), .Clk(Clk), .Start(Start));

    initial Clk = 0;
    always #10 Clk = ~Clk;

    task Play;
    begin
        Start = 1'b1; @(posedge Clk);
        @(posedge Clk);
        Start = 1'b0; @(posedge Clk);
        @(posedge Clk);
        Start = 1'b1; @(posedge Clk);
    end
    endtask

    initial begin
        SW = 3'b000;
        Start = 0;
        Reset = 0;
        #200;
        Reset = 1;
        @(posedge Clk);

        SW = 3'b000;
        Play();

        #500_000_000; dot
        #500_000_000;
        #500_000_000; dash 
        #500_000_000; 
        #500_000_000; dash 
        #500_000_000;
        #500_000_000; dash

        @(posedge Clk);
        Start = 1'b0; @(posedge Clk);
        @(posedge Clk);
        Start = 1'b1; @(posedge Clk);

        SW = 3'b011;
        Play();

        #500_000_000; dash
        #500_000_000;
        #500_000_000; dash
        #500_000_000;
        #500_000_000; dash
        #500_000_000;
        #500_000_000; dot 
        #500_000_000;
        #500_000_000; dot

        Start = 0; @(posedge Clk);

        #1_000_000;
        $stop;
    end

endmodule
