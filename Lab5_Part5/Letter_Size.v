`timescale 1ns/10ps

module Letter_Size (SW, En, Load, Q, Clk, Reset);
    input [2:0] SW;
    input En, Load, Clk, Reset;
    output reg [2:0] Q;

    reg [2:0] Letter_reg;

    // Start=0일 때 문자 선택 
    always @(posedge Clk or negedge Reset) begin
        if (!Reset)
            Letter_reg <= 3'b000;
        else if (Load == 1'b0)
            Letter_reg <= SW;
    end
    // 문자 입력마다 Size 구분
    always @(*) begin
        case (Letter_reg)
            3'b000: Q = 3'd2; // A: .-
            3'b001: Q = 3'd4; // B: -...
            3'b010: Q = 3'd4; // C: -.-.
            3'b011: Q = 3'd3; // D: -..
            3'b100: Q = 3'd1; // E: .
            3'b101: Q = 3'd4; // F: ..-.
            3'b110: Q = 3'd3; // G: --.
            3'b111: Q = 3'd4; // H: ....
            default: Q = 3'd0;
        endcase
    end
endmodule
