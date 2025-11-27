`timescale 1ns/10ps

module Stop_Watch_1_digit_tb();
    reg Clr, Clk;
    wire [6:0] HEX0;

    Stop_Watch_1_digit DUT(.Clr(Clr), .Clk(Clk), .HEX0(HEX0));

    // 50MHz clock
    always #10 Clk = ~Clk;

    initial begin
        Clk = 0;
        Clr = 0;
        #100 Clr = 1;                
        #1_000_000_000 $stop;          
    end


endmodule
