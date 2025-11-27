`timescale 1ns/10ps

module part6_tb ();

reg [9:0] SW;

wire [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

part6 DUT(.SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3), .HEX4(HEX4), .HEX5(HEX5));

initial 
begin 
	$display($time, "Simulation Start");
	#20; SW[9:7] = 3'b000;
	#20; SW[9:7] = 3'b001;
	#20; SW[9:7] = 3'b010;
	#20; SW[9:7] = 3'b011;
	#20; SW[9:7] = 3'b100;
	#20; SW[9:7] = 3'b101;
	#20;
	$display($time, "Simulation End");
end

endmodule