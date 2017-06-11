module hazard_unit_ss(	input clk,
					input MemToRegE1, MemToRegE2,
					input reset,
					input Start_mult, mult_ready, BTFlush, JFlush,
					input [4:0] RegDst1, RegDst2, 
					input [31:0] InstrD1, InstrD2,
					output reg stall, flush);

/*	HAZARD UNIT THAT WILL STALL FOR STALL HAZARDS (LOAD-USE)
	CHECK IF REGDST AT DECODE STAGE == WRITE REG */
	always@(*) if(reset) begin
	stall <= 0; flush <= 0;	
	end
	always@(posedge clk) begin
	#1
	stall <= 0; flush <= 0;	
	if (	(
			((MemToRegE1) && ((RegDst1 == InstrD1[25:21]) || (RegDst1 == InstrD1[20:16]))) ||
			((MemToRegE2) && ((RegDst2 == InstrD2[25:21]) || (RegDst2 == InstrD2[20:16]))) ||	
			BTFlush || JFlush
			) && 
			(!reset)) begin
		stall <= 1; flush <= 1;
		end
	end
endmodule // hazard_unit