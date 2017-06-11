module zeroext(input [15:0] a, //new zero immediate extend for extension of positive immediates 
              output [31:0] y);
  assign y = {{16{1'b0}}, a};
endmodule