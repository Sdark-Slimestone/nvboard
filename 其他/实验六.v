/* verilator lint_off DECLFILENAME */
module Reg #(WIDTH = 1, RESET_VAL = 0) (
  input clk,
  input rst,
  input [WIDTH-1:0] din,
  output reg [WIDTH-1:0] dout,
  input wen
);
  always @(posedge clk) begin
    if (rst) dout <= RESET_VAL;
    else if (wen) dout <= din;
  end
endmodule

module top(
    input clk,
    input rst,
    input shift_en,
    output [7:0]out
);
    wire feedback = out[4] ^ out[3] ^ out[2] ^ out[0];
    wire zero = (out == 8'b00000000)? 1'b1: feedback;

    Reg #(1, 1'b0) i7 (clk, rst, zero, out[7], shift_en);
    Reg #(1, 1'b0) i6 (clk, rst, out[7], out[6], shift_en);
    Reg #(1, 1'b0) i5 (clk, rst, out[6], out[5], shift_en);
    Reg #(1, 1'b0) i4 (clk, rst, out[5], out[4], shift_en);
    Reg #(1, 1'b0) i3 (clk, rst, out[4], out[3], shift_en);
    Reg #(1, 1'b0) i2 (clk, rst, out[3], out[2], shift_en);
    Reg #(1, 1'b0) i1 (clk, rst, out[2], out[1], shift_en);
    Reg #(1, 1'b1) i0 (clk, rst, out[1], out[0], shift_en);

endmodule
