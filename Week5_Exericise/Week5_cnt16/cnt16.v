`timescale 1ns/10ps
module cnt16(cnt, clk, rst_l, ld_l, en_l, cnt_in);
output reg [3:0] cnt;
input clk, rst_l, ld_l, en_l;
input [3:0] cnt_in;

always @ (posedge clk or negedge rst_l)
begin
 if (!rst_l)
   cnt <= #1 4'b0000; // ' 가 복사하면서 에러 발생
 else if (!ld_l)
   cnt <= #1 cnt_in;
 else if (!en_l)
   cnt <= #1 cnt + 1;
end

endmodule
