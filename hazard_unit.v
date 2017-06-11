module hazard_unit(	input clk,
					input MemToRegE,
					input reset,
					input Start_mult, mult_ready, BTFlush, JFlush,
					input [4:0] RegDst, RsD, RtD,
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
			((MemToRegE) && ((RegDst == RsD) || (RegDst == RtD))) || 	
			(Start_mult || !mult_ready) || BTFlush || JFlush
			) && 
			(!reset)) begin
		stall <= 1; flush <= 1;
	end
end
endmodule // hazard_unit