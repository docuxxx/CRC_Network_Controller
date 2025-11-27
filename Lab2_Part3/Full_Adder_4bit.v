`timescale 1ns/10ps
module Full_Adder_4bit (A, B, C_in, C_out, S);
	input [3:0] A, B;
	input C_in;
	output [3:0] S;
	output C_out;
	wire C1, C2, C3;
	
	Full_Adder_1bit FA0 (.a(A[0]), .b(B[0]), .c_in(C_in), .c_out(C1), .s(S[0]));
	Full_Adder_1bit FA1 (.a(A[1]), .b(B[1]), .c_in(C1), .c_out(C2), .s(S[1]));
	Full_Adder_1bit FA2 (.a(A[2]), .b(B[2]), .c_in(C2), .c_out(C3), .s(S[2]));
	Full_Adder_1bit FA3 (.a(A[3]), .b(B[3]), .c_in(C3), .c_out(C_out), .s(S[3]));

endmodule