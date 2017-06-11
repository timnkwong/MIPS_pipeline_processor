module flopr #(parameter WIDTH = 8)
              (input clk, stall, c_stall, reset,
                input [WIDTH-1:0] d,
                output reg [WIDTH-1:0] q);
  always @(posedge clk, posedge reset) //standard D flipfop
  		if (reset)
  			q <= 0;
  		else if (!stall && !c_stall)
 			q <= d;
endmodule