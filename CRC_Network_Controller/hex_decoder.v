`timescale 1ns/10ps

module hex_decoder (A, HEX);
	input [3:0] A;
	output reg [0:6] HEX;

	always @(A)
	begin
		case (A)
			4'h0: HEX = 7'b0000001; //0
			4'h1: HEX = 7'b1001111; //1
			4'h2: HEX = 7'b0010010; //2
			4'h3: HEX = 7'b0000110; //3
			4'h4: HEX = 7'b1001100; //4
			4'h5: HEX = 7'b0100100; //5
 			4'h6: HEX = 7'b0100000; //6
			4'h7: HEX = 7'b0001101; //7
			4'h8: HEX = 7'b0000000; //8
 			4'h9: HEX = 7'b0001100; //9
			4'ha: HEX = 7'b0001000; //A
			4'hb: HEX = 7'b1100000; //b
			4'hc: HEX = 7'b0110001; //C
			4'hd: HEX = 7'b1000010; //d
			4'he: HEX = 7'b0110000; //E
			4'hf: HEX = 7'b0111000; //F
		default: HEX = 7'b1111111; //off
		endcase
	end
endmodule
			