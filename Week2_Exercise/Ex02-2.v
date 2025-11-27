module mux4to1 (W, S, f);
  input  [0:3] W;  
  input  [1:0] S;
  output f;
  assign f = W[S];
endmodule
