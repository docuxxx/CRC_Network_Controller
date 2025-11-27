module Full_Adder (A, B, S, C_in, C_out);
	parameter n = 8;
	
	input [n-1:0] A, B;
	input C_in;
	output [n-1:0] S;
	output C_out;
	
	assign {C_out, S} = B + A + C_in;

endmodule