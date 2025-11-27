`timescale 1ns/10ps

module part5_tb ();

//입력 기억
reg [9:0] SW;

//출력 wire로 받아오기
wire [6:0] HEX0, HEX1, HEX2, HEX3;

part5 DUT(.SW(SW), .HEX0(HEX0), .HEX1(HEX1), .HEX2(HEX2), .HEX3(HEX3));

initial 
begin 
	$display($time, "Simulation Start");
	#20; 
	SW[1:0] = 2'b11;
	SW[3:2] = 2'b10;
	SW[5:4] = 2'b01;
	SW[7:6] = 2'b00;
	
	#20; SW[9:8] = 2'b00;
	#20; SW[9:8] = 2'b01;
	#20; SW[9:8] = 2'b10;
	#20; SW[9:8] = 2'b11;
	#20; $stop;
	$display($time, "Simulation End");
end

endmodule