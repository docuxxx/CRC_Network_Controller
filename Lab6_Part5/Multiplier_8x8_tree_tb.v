`timescale 1ns/10ps

module Multiplier_8x8_tree_tb();
    reg [7:0] Input;
    reg Clk, Reset, En_A, En_B;
    wire [6:0] HEX0, HEX1, HEX2, HEX3;
    wire [7:0] LEDR;

    Multiplier_8x8_tree DUT (Input, Clk, Reset, En_A, En_B, LEDR, HEX0, HEX1, HEX2, HEX3);

    // 클럭 생성 (20 ns)
    initial Clk = 1'b0;

    always #10 Clk = ~Clk;

    initial begin
        // 초기화 상태
        Reset = 1'b0;
        En_A  = 1'b0;
        En_B  = 1'b0;
        Input = 8'd0;

        // 리셋 상태 유지
        @(posedge Clk);
	// 여유 클럭
        @(posedge Clk);

        // Reset 해제 
        Reset = 1'b1;

        // Test 1 : 0x33 × 0x38 = 0x0B28

        Input = 8'h33;
        En_A  = 1'b1;
	
	// A <= 0x33
        @(posedge Clk); 
	// 여유 클럭
        @(posedge Clk);  

        En_A  = 1'b0;

        // 여유 클럭
        @(posedge Clk);

        Input = 8'h38;
        En_B  = 1'b1;
	
	// B <= 0x38
        @(posedge Clk);  
	// 여유 클럭
        @(posedge Clk);  

        En_B  = 1'b0;

  	 // 결과가 P에 저장되고 HEX 출력이 안정될 때까지 여유 클럭
        @(posedge Clk);
        @(posedge Clk);
        @(posedge Clk);

        #50; 

        // Test 2 : 0xFF × 0xFF = 0xFE01
        Reset = 1'b0;
        @(posedge Clk); 
        Reset = 1'b1;

        Input = 8'hFF;
        En_A  = 1'b1;

	// B <= 0xFF
        @(posedge Clk);  
	// 여유 클럭
        @(posedge Clk);   

        En_A  = 1'b0;
	
	// 여유 클럭
        @(posedge Clk);   

        Input = 8'hFF;
        En_B  = 1'b1;

	// B <= 0xFF  
        @(posedge Clk);
	// 여유 클럭   
        @(posedge Clk);   

        En_B  = 1'b0;

        // 결과가 P에 저장되고 HEX 출력이 안정될 때까지 여유 클럭
        @(posedge Clk);
        @(posedge Clk);
        @(posedge Clk);

        #100 $stop;
    end

endmodule
