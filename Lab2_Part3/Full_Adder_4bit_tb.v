`timescale 1ns/10ps

module Full_Adder_4bit_tb();
	reg [3:0] A, B;
	reg C_in;
	wire [3:0] S;
	wire C_out;
	reg clk;
	
	Full_Adder_4bit DUT (.S(S), .C_out(C_out), .A(A), .B(B), .C_in(C_in));
	
	initial 
	begin
		A = 4'b0000;
		B = 4'b0000;
		C_in = 1'b0;
		clk = 1'b0;
	end
	always #50 C_in = ~C_in;

	always @(posedge clk)
	begin 
		A = A + 4'b0001;
		B = B + 4'b0001;
	end

	initial 
	begin
		wait(A == 4'b1111);
		#20;
		$stop;
	end	

endmodule	
	
	