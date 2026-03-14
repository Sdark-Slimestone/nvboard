module top(
  input SW0,
  input SW1,
  input SW2,
  input SW3,
  input SW4,
  input SW5,
  input SW6,
  input SW7,
  input ena,
  output [2:0]led,
  output [7:0]seg,
  output zhishi
);
assign led = (SW7 && ena)? 3'b111 : 
             (SW6 && ena)? 3'b110 :
             (SW5 && ena)? 3'b101 :
             (SW4 && ena)? 3'b100 :
             (SW3 && ena)? 3'b011 :
             (SW2 && ena)? 3'b010 :
             (SW1 && ena)? 3'b001 :
             (SW0 && ena)? 3'b000 : 3'b000;
assign zhishi = ((SW7 | SW6 | SW5 | SW4 | SW3 | SW2 | SW1 | SW0) && ena)? 1'b1 : 1'b0;
assign seg = (SW7 && ena)? 8'b00011111 :
             (SW6 && ena)? 8'b01000001 :
             (SW5 && ena)? 8'b01001001 :
             (SW4 && ena)? 8'b10011001 :
             (SW3 && ena)? 8'b00001101 :
             (SW2 && ena)? 8'b00100101 :
             (SW1 && ena)? 8'b10011111 :
             (SW0 && ena)? 8'b00000011 : 8'b00000000;

endmodule
