`timescale 1ns/10ps

module Binary_Decimal_Converter_tb();
	reg [3:0] V;
	wire [6:0] HEX0, HEX1;
	reg clk;
	Binary_Decimal_Converter BCD (.V(V),  .HEX1(HEX1), .HEX0(HEX0));
	
	initial 
	begin	
		V = 4'b0000;
		clk = 1'b0;
	end

	always #20 clk = ~clk; 	

	always @(posedge clk)
	begin 
		V = V + 4'b0001;
	end
	
	initial 
	begin
		wait(V == 4'b1111);
		#20;
		$stop;
	end		

endmodule