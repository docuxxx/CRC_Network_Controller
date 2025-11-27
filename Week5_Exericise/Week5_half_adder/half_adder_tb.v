`timescale 1ns/10ps

module half_adder_tb; 
reg a, b; 
wire sum, carry; 

half_adder DUT(.a(a), .b(b), .sum(sum), .carry(carry)); 

initial 	// initial block executes only once 
begin
  $display($time, "<< Starting the Simulation >>");
  a = 0; b = 0; 
  #20; 	// wait for 20ns 
  a = 0; b = 1; 
  #20; a = 1; b = 0; 
  #20; a = 1; b = 1; 
  #20; 
end
 
endmodule