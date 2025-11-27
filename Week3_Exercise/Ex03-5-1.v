`timescale 1ns/10ps 
module FA01 (x,y,ci,s,co);
input x,y,ci;
output s,co;

assign s = x^y^ci;
assign co = (x&y) | (x&ci) | (y&ci);

endmodule