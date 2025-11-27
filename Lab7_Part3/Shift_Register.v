`timescale 1ns/10ps

module Shift_Register (A, z, Clk, Reset, Register);
	input Clk, Reset, A;
	output reg z;
	output reg [3:0] Register;
	reg Detect_Enable;
	reg [1:0] Count;
	
	// Default 0 Detect
	parameter n = 0;

	always @(posedge Clk) 
	begin
		if (!Reset) 
		begin
			Register <= 4'b0000;
			z <= 1'b0;
			Detect_Enable <= 1'b0;
			Count <= 2'b0;
		end
		else 
		begin
			//shift register
			Register <= {Register[2:0], A};	
			
			//output detection logic
			if (Detect_Enable && ({Register[2:0], A} == {4{n}}))	
				z <= 1'b1;
			else 
				z <= 1'b0;

			if (Detect_Enable == 1'b0) 
			begin		
				Count <= Count + 1'b1;
				
				/*
				왜 첫 sequence 3개 무시? 
				ex) 초기화 상태 Register = 4'b0000이므로 첫 입력으로 0이 들어왔을 때 바로 output이 1이되므로 오류
				 Count = 2일 때 Data_Enable이 되는 이유?
				 Count = 2일 때 3번의 클럭 동작 수행이기 때문에 3번의 동작이 끝난 후 Detect_Enable = 1
				 이후 4번째 동작부터 실제로 들어온 값 바탕으로 Detect
				*/
				if (Count == 2'b10) 
					Detect_Enable <= 1'b1;
			end
		end
	end
endmodule
