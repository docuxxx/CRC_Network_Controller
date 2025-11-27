`timescale 1ns/10ps
module Full_Adder_1bit(a, b, c_in, c_out, s);
	input a, b, c_in;
	output c_out, s;
	wire sel;
	assign sel = a^b;
	assign c_out = sel ? c_in : b;
	assign s = sel^c_in;
endmodule