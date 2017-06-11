module multiplier_tb();

reg [31:0]  multiplier, multiplicand;
reg        	start, clk;
wire [31:0] product_hi, product_lo;
wire [63:0] product;
wire        ready;

multiplier mult(	clk, start, 
                   				multiplier,multiplicand,
                   				ready, 
                   				product_hi, product_lo, product);

always #5 clk <= ~clk;

initial begin
	clk = 0;
	multiplier = 100;
	multiplicand = -3;
	start = 1;
end // initial
endmodule // multiplier_tb
