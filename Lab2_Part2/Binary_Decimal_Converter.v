module Binary_Decimal_Converter(V, HEX1, HEX0);
	input [3:0] V;
	output [6:0] HEX1, HEX0;
	wire Z;
	wire [3:0] A;
	wire [3:0] M;
	wire [7:0] SW;
	// 10의 자리 숫자 및 selector 신호
	Comparator cmp(.V(V), .Z(Z));
	Circuit_A circuit(.V(V), .A(A));

	// 4bit 2to1 mux 
	assign M[0] = (Z & A[0]) | (~Z & V[0]);
	assign M[1] = (Z & A[1]) | (~Z & V[1]);
	assign M[2] = (Z & A[2]) | (~Z & V[2]);
	assign M[3] = (Z & A[3]) | (~Z & V[3]);
	Number_Display Display (.SW(SW), .HEX0(HEX0), .HEX1(HEX1));
	/*  
	    4비트 입력으로 나타낼 수 있는 최대의 수 범위는 15
	    즉, 10의 자리 1, 1의 자리 5
	    10의 자리는 0 or 1로 고정이기 때문에 SW[7:4] = 4'b0000 or 4'b0001
	    1의 자리는 0 ~ 9까지 나타내므로 Mux 결과로 할당
	*/

	assign SW = {3'b000, Z, M}; 
	
endmodule