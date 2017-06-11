module signext(input [15:0] a,
              output [31:0] y);
  assign y = {{16{a[15]}}, a}; //sign extend for 16 bits
endmodule


module jsignext(input [25:0] a,
              output [31:0] y);
  assign y = {{6{a[25]}}, a}; //sign extend for 26 bits
endmodule