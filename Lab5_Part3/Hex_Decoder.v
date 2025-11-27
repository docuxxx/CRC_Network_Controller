`timescale 1ns/10ps

module Hex_Decoder (X, HEX);
	input [3:0] X;
	output reg [6:0] HEX;


	always @(*) begin
        	case (X)
		//4bit Hexadecimal
            	4'h0: HEX = 7'b1000000; 
            	4'h1: HEX = 7'b1111001; 
            	4'h2: HEX = 7'b0100100; 
            	4'h3: HEX = 7'b0110000; 
            	4'h4: HEX = 7'b0011001; 
            	4'h5: HEX = 7'b0010010; 
            	4'h6: HEX = 7'b0000010; 
            	4'h7: HEX = 7'b1111000; 
            	4'h8: HEX = 7'b0000000; 
            	4'h9: HEX = 7'b0010000; 
            	default: HEX = 7'b1000000; 

       		endcase

    	end
endmodule