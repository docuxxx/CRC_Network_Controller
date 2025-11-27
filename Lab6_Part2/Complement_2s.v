`timescale 1ns/10ps

module Complement_2s (D, add_sub, Q);
	input [7:0] D;
    	input add_sub;
    	output [7:0] Q;

   	assign Q = add_sub ? (~D + 8'b1) : D;
endmodule
