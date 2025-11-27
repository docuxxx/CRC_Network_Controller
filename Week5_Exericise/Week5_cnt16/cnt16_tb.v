`timescale 1ns/10ps

module cnt16_tb ();
// inputs to the DUT are reg type
reg clk;
reg rst_l, load_l, enable_l;
reg [3:0] cnt_in;

// outputs from the DUT are wire type
wire [3:0] cnt_out;

// instantiation 할 때 모듈 이름 다르게 호출해서 이후 이름 수정해서 해결
cnt16 DUT(.cnt(cnt_out), .clk(clk), .rst_l(rst_l), .ld_l(load_l), .cnt_in(cnt_in), .en_l(enable_l));

// create a 50Mhz clock
always
 #10 clk = ~clk;
initial
begin
 $display($time, " << Starting the Simulation >>");
 clk = 1'b0; 
 enable_l = 1'b1; // disabled
 load_l = 1'b1; // disabled
 cnt_in = 4'h0; // enabled
 rst_l = 0;  // reset is active

 #20 rst_l = 1'b1; // at time 20 release reset
 $display($time, " << Coming out of reset >>");

 @(negedge clk); // wait till the negedge of clk then continue
 load_count(4'h3); // call the load_count task

 @(negedge clk);
 $display($time, " << Turning ON the count enable >>");
 enable_l = 1'b0; // turn ON enable

 wait (cnt_out == 4'b0001); // wait until the count equals 1
 $display($time, "<<cnt=%d-Turning OFF the cnt enable>>", cnt_out);
 enable_l = 1'b1;

 #40;
 $display($time, "<< Simulation Complete >>");
 $stop;
end

// This initial block runs concurrently with others and starts at time 0
 initial begin
  // $monitor will print whenever a signal changes in the design
  $monitor($time, "clk=%b, rst_l=%b, enable_l=%b, load_l=%b, cnt_in=%h, 
           cnt_out=%h", clk, rst_l, enable_l, load_l, cnt_in, cnt_out);
 end

// The load_count task loads the counter with the value passed
 task load_count;
 input [3:0] load_value;
 begin
  @(negedge clk);
  $display($time, " << Loading the counter with %h >>", load_value);
  load_l = 1'b0;
  cnt_in = load_value;
  @(negedge clk);
  load_l = 1'b1;
 end
 endtask

 endmodule