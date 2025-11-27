
`timescale 1ns/10ps

module Sequential_Adder_8bit (SW, Reset, Clk,Clk_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR);
	input [7:0] SW;
	input Reset, Clk, Clk_50;
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output LEDR;
	reg [7:0] A, B;
	reg load;
	wire [8:0] S;
	
	//edge 레벨에서 클럭의 상승에 값을 load하므로 D-FF과 같은 역할
	always @(posedge Clk or negedge Reset) 
	begin
		if (!Reset) 
		begin
			A <= 8'b00000000;
			B <= 8'b00000000;
			load <= 0;
		end
		else
		begin
			if (load == 0)
			begin
				A <= SW;
				load <= 1;
			end
			else
			begin
				B <= SW;
				load <= 0;
			end
		end
	end

	assign S = {1'b0 , A} + {1'b0 , B};
	assign LEDR = S[8];
	
	Hex_Decoder DEC_A1(A[7:4], HEX5);
	Hex_Decoder DEC_A0(A[3:0], HEX4);
	Hex_Decoder DEC_B1(B[7:4], HEX3);
	Hex_Decoder DEC_B0(B[3:0], HEX2);
	Hex_Decoder DEC_Sum1(S[7:4], HEX1);
	Hex_Decoder DEC_Sum2(S[3:0], HEX0);

endmodule
