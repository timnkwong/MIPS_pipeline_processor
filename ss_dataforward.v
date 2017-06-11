module ss_dataforward(	input [4:0] 	Rd1e1, Rd2e1, Rd1e2, Rd2e2,
						input			RegWriteE1, RegWriteM1, RegWriteW1,
										RegWriteE2, RegWriteM2, RegWriteW2,
						input [4:0] 	WriteRegE1, WriteRegM1, WriteRegW1,
										WriteRegE2, WriteRegM2, WriteRegW2,
						input [31:0]	AluOutE1, AluOutM1, WriteData3_1, 
										AluOutE2, AluOutM2, WriteData3_2,
						output reg		SSForwardAE1, SSForwardBE1,
										SSForwardAE2, SSForwardBE2,
						output reg [31:0]	SSAluInA1, SSAluInB1,
											SSAluInA2, SSAluInB2);

/* 	DATA FORWARDING FOR FORWARDING HAZARDS
	FORWARD ON THE FOLLOWING CASES:
		-REGS OF NEXT EXEC INSTR USES ANY REGS IN MEM STAGE
		-REGS OF NEXT EXEC NSTR USES ANY REGS IN WB STAGE */
	always@(*) begin
		//default case: direct values in muxes
		SSForwardAE1 <= 0; SSForwardBE1 <= 0;
		SSForwardAE2 <= 0; SSForwardBE2 <= 0;
		//GET REG VALUES FROM D1EX IF THEY ARE NEEDED IN D2EX
		if(	(RegWriteE1) && 
			(WriteRegE1 != 0) &&
			(WriteRegE1 == Rd1e2)) begin
			SSForwardAE2 <= 1;
			SSAluInA2 <= AluOutE1;
	end
		if(	(RegWriteE1) && 
			(WriteRegE1 != 0) &&
			(WriteRegE1 == Rd2e2)) begin
			SSForwardBE2 <= 1;
			SSAluInB2 <= AluOutE1;
	end


		//GET REG VALUES FROM D1MEM IF THEY ARE NEEDED IN D2EX
		if(	(RegWriteM1) && 
			(WriteRegM1 != 0) &&
			(WriteRegM1 != WriteRegE1) &&
			(WriteRegM1 == Rd1e2)) begin
			SSForwardAE2 <= 1;
			SSAluInA2 <= AluOutM1;
	end
		if(	(RegWriteM1) && 
			(WriteRegM1 != 0) &&
			(WriteRegM1 != WriteRegE1) &&			
			(WriteRegM1 == Rd2e2)) begin
			SSForwardBE2 <= 1;
			SSAluInB2 <= AluOutM1;
	end

		//GET REG VALUES FROM D1WB IF THEY ARE NEEDED IN D2EX
		if(	(RegWriteW1) && 
			(WriteRegW1 != 0) &&
			(WriteRegW1 != WriteRegM1) &&
			(WriteRegW1 != WriteRegE1) &&			
			(WriteRegW1 == Rd1e2)) begin
			SSForwardAE2 <= 1;
			SSAluInA2 <= WriteData3_1;

end
		if(	(RegWriteW1) && 
			(WriteRegW1 != 0) &&
			(WriteRegW1 != WriteRegM1) &&
			(WriteRegW1 != WriteRegE1) &&
			(WriteRegW1 == Rd2e2))	begin
			SSForwardBE2 <= 1;
			SSAluInB2 <= WriteData3_1;
		end

		if(	(RegWriteE1) && 
			(WriteRegE1 != 0) &&
			(WriteRegE1 == Rd1e2)) begin
			SSForwardAE2 <= 1;
			SSAluInA2 <= AluOutE1;
	end
		if(	(RegWriteE1) && 
			(WriteRegE1 != 0) &&
			(WriteRegE1 == Rd2e2)) begin
			SSForwardBE2 <= 1;
			SSAluInB2 <= AluOutE1;
	end

	//THIS IS FOR VICE VERSA DATA FORWARD FROM DP2 TO DP1
		//GET REG VALUES FROM D1MEM IF THEY ARE NEEDED IN D2EX
		if(	(RegWriteM2) && 
			(WriteRegM2 != 0) &&
			(WriteRegM2 == Rd1e1)) begin
			SSForwardAE1 <= 1;
			SSAluInA1 <= AluOutM2;
	end
		if(	(RegWriteM2) && 
			(WriteRegM2 != 0) &&
			(WriteRegM2 == Rd2e1)) begin
			SSForwardBE1 <= 1;
			SSAluInB1 <= AluOutM2;
	end

		//GET REG VALUES FROM D1WB IF THEY ARE NEEDED IN D2EX
		if(	(RegWriteW2) && 
			(WriteRegW2 != 0) &&
			(WriteRegW2 != WriteRegM2) &&			
			(WriteRegW2 == Rd1e1)) begin
			SSForwardAE1 <= 1;
			SSAluInA1 <= WriteData3_2;
	end
		if(	(RegWriteW2) && 
			(WriteRegW2 != 0) &&
			(WriteRegW2 != WriteRegM2) &&			
			(WriteRegW2 == Rd2e1)) begin
			SSForwardBE1 <= 1;
			SSAluInB1 <= WriteData3_2;
	end

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