`timescale 1ns/10ps

module Sequence_Detector (w, Reset, Clk, z, LEDR);
	input w, Reset, Clk;
	output reg z;
	output [8:0] LEDR;

	reg [3:0] State, Next_State;
	
	parameter A = 4'b0000, B = 4'b0001, C = 4'b0010, D = 4'b0011, E = 4'b0100, 
		F = 4'b0101, G = 4'b0110, H = 4'b0111, I = 4'b1000;
	// Next State Logic
	always @(*) 
	begin 
		case (State)
			A : if(!w) 
				Next_State = B;
			    else 
				Next_State = F;
			B : if(!w) 
				Next_State = C;
			    else 
				Next_State = F;
			C : if(!w) 
				Next_State = D;
			    else 
				Next_State = F;
			D : if(!w) 
				Next_State = E;
			    else 
				Next_State = F;
			E : if(!w) 
				Next_State = E;
		            else 
				Next_State = F;
			F : if(w) 
				Next_State = G;
			    else 
				Next_State = B;
			G : if(w) 
				Next_State = H;
			    else 
				Next_State = B;
			H : if(w) 
				Next_State = I;
			    else 
				Next_State = B;
			I : if(w)
				Next_State = I;
			   else 
				Next_State = B; 
			default: Next_State = 4'bxxxx;
		endcase
	end
	// Output Logic - Moore Machine
	always @(*) 
	 begin	
		case (State)
			A : z = 1'b0;
			B : z = 1'b0;
			C : z = 1'b0;
			D : z = 1'b0;
			//output = 1
			E : z = 1'b1;	
			F : z = 1'b0;
			G : z = 1'b0;
			H : z = 1'b0;
			//output = 1
			I : z = 1'b1;	
			default: z = 1'bx;
		endcase
	end
	// State_FF
	always @(posedge Clk) 
	begin 
		if(!Reset)
			State <= A;
		else
			State <= Next_State;
	end

	assign LEDR = State;

endmodule