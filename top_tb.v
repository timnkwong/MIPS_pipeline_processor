module pipeline_top();

reg clk, reset;
wire [31:0] ALUOutE1, ALUOutE2, InstrD1, InstrD2;
wire [63:0] InstrF;

mips_top_ss DUT(clk, reset, // WriteData3_1, WriteData3_1, 
				ALUOutE1, ALUOutE2, InstrD1, InstrD2, InstrF);

always #5 clk <= !clk;

initial begin
	
	clk = 0;
	#2
	reset = 1;
	#2 reset = 0;

end // initial
endmodule // pipeline_top