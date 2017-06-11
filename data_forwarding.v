module data_forward(	input [4:0] RsD, RtD, RegM, RegW,
						input RegWriteM, RegWriteW,
						output reg [1:0] ForwardAE, ForwardBE);

/* 	DATA FORWARDING FOR FORWARDING HAZARDS
	FORWARD ON THE FOLLOWING CASES:
		-REGS OF NEXT EXEC INSTR USES ANY REGS IN MEM STAGE
		-REGS OF NEXT EXEC NSTR USES ANY REGS IN WB STAGE */
	always@(*) begin
		//default case: direct values in muxes
		ForwardAE <= 2'b00; ForwardBE <= 2'b00;

		//GET REG VALUES FROM MEM IF THEY ARE NEEDED IN EX
		if(	(RegWriteM) && 
			(RegM != 0) &&
			(RegM == RsD))
			ForwardAE <= 2'b10;
		if(	(RegWriteM) && 
			(RegM != 0) &&
			(RegM == RtD))
			ForwardBE <= 2'b10;

		//GET REG VALUES FROM WB IF THEY ARE NEEDED IN EX
		if(	(RegWriteW) && 
			(RegW != 0) &&
			(RegW != RegM) &&
			(RegW == RsD))
			ForwardAE <= 2'b01;

		if(	(RegWriteW) && 
			(RegW != 0) &&
			(RegW != RegM) &&
			(RegW == RtD))
			ForwardBE <= 2'b01;
	end
endmodule // data_forward


/*	DATA FORWARDING FOR BRANCH CASES (BEQ/BNE)
	STALL AND FORWARD IF WRITEREG_E == RST OR RSD */
	
module data_forward_b(	input [4:0] WriteRegE, RsD, RtD,
						input RegWriteE, BranchD, BranchNot,
						output reg ForwardAD, ForwardBD);

	always@(*) begin
		//default case: direct values in muxes
		ForwardAD <= 0; ForwardBD <= 0;

		//IF RSD AND RTD ARE EQUAL TO WRITEREGE AND BRANCHD, ENABLE FORWARDS

		if ( 	(RegWriteE) &&
				(BranchD || BranchNot)	&&
				(WriteRegE != 0) &&
				(WriteRegE == RsD))
				ForwardAD <= 1;

		if ( 	(RegWriteE) &&
				(BranchD || BranchNot)	&&
				(WriteRegE != 0) &&
				(WriteRegE == RtD))
				ForwardBD <= 1;
	end
endmodule