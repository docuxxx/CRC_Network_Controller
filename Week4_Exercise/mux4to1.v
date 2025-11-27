module mux4to1 (w0, w1, w2, w3, s0, s1, f);
	input w0;
	input w1;
	input w2;
	input w3;
	input s0, s1;
	
	output f;
	
	assign f = s0 ? (s1 ? w3 : w1) : (s1 ? w2 : w0); 

endmodule