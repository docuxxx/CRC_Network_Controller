`timescale 1ns/10ps

module Letter_Symbol (SW, Q);
    input [2:0] SW;
    output reg [3:0] Q;

    always @(*) begin
        case (SW)
	    // 문자 입력마다 모스 코드로 변환
            3'b000: Q = 4'b01xx; // A: .-   
            3'b001: Q = 4'b1000; // B: -...
            3'b010: Q = 4'b1010; // C: -.-.
            3'b011: Q = 4'b100x; // D: -..  
            3'b100: Q = 4'b0xxx; // E: .    
            3'b101: Q = 4'b0010; // F: ..-.
            3'b110: Q = 4'b110x; // G: --.  
            3'b111: Q = 4'b0000; // H: ....
            default: Q = 4'b0000; 
        endcase
    end
endmodule
