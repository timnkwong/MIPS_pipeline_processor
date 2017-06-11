module hazard_tb();
	reg clk, MemToRegE,
		reset, multiply;
	reg [4:0] RegDst, RsD, RtD;
	wire stall, flush;


hazard_unit danger(	clk, MemToRegE, reset, multiply,
					RegDst, RsD, RtD, stall, flush);


always #5 clk <= !clk;

initial begin
	clk = 0;
	MemToRegE = 0;
	reset = 0;
	multiply = 0;
	RegDst = 10;
	RsD = 0;
	RtD = 0;
	#10 MemToRegE = 1; RsD = 10;
	#10 RtD = 10; RsD = 0;
	#10 MemToRegE = 0;
	#10 MemToRegE = 1; reset = 1;
	#10 reset = 0; MemToRegE = 0;
	#10 multiply = 1;
	#10 reset = 1;
end
endmodule // hazard_tb
