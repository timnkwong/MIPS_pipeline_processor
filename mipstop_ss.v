module mips_top_ss(	input 			clk, reset,
					output [31:0] 	//WriteData3_1, WriteData3_2,
									ALUoutE1, ALUoutE2,
									InstrD1, InstrD2, 
					output [63:0] 	InstrF);
	
	//wire [63:0] InstrF;
	wire [31:0] Rd1D_1, Rd1D_2, Rd2D_1, Rd2D_2, WriteData3_1, WriteData3_2,
				ALUoutM1, ALUoutM2, ReadDataM1, ReadDataM2,
				SSAluInA1, SSAluInB1, //SSAluOutM1, SSAluOutW1, 
				SSAluInA2, SSAluInB2; //SSAluOutM2, SSAluOutW2;
	wire [4:0] 	RegDst1, RegDst2, 
				WriteRegW1, WriteRegW2, WriteRegE1, WriteRegE2, WriteRegM1, WriteRegM2,
				Rd1e_1, Rd2e_1, Rd1e_2, Rd2e_2;

	wire 		RegWriteW1, RegWriteW2, 
				RegWriteM1, RegWriteM2,
				RegWriteE1, RegWriteE2;

	reg [31:0] PCF;
	initial PCF = 0;

	inst_memory_ss imem(PCF, InstrF);

	ss_dataforward ssdf(Rd1e_1, Rd2e_1, Rd1e_2, Rd2e_2,
						RegWriteE1, RegWriteM1, RegWriteW1,
						RegWriteE2, RegWriteM2, RegWriteW2,
						WriteRegE1, WriteRegM1, WriteRegW1,
						WriteRegE2, WriteRegM2, WriteRegW2,
						ALUoutE1, ALUoutM1, WriteData3_1,
						ALUoutE2, ALUoutM2, WriteData3_2,
						SSForwardAE1, SSForwardBE1,
						SSForwardAE2, SSForwardBE2,
						SSAluInA1, SSAluInB1,
						SSAluInA2, SSAluInB2);		//CROSS DATAPATH FORWARDING

	datapath_ss dp1(clk, reset, HZStall, HZFlush, InstrF[31:0], 
					Rd1D_1, Rd2D_1,
					SSForwardAE1, SSForwardBE1,
					SSAluInA1, SSAluInB1,// SSAluOutM1, SSAluOutW1,
					InstrD1, ALUoutE1, ALUoutM1,  
					ReadDataM1, WriteData3_1, 
					RegWriteW1, RegWriteE1, RegWriteM1,
					WriteRegW1, WriteRegE1, WriteRegM1,
					Rd1e_1, Rd2e_1);

	datapath_ss dp2(clk, reset, HZStall, HZFlush, InstrF[63:32], 
					Rd1D_2, Rd2D_2,	
					SSForwardAE2, SSForwardBE2,
					SSAluInA2, SSAluInB2,// SSAluOutM2, SSAluOutW2,
					InstrD2, ALUoutE2, ALUoutM2, 
					ReadDataM2, WriteData3_2, 
					RegWriteW2, RegWriteE2, RegWriteM2,
					WriteRegW2, WriteRegE2, WriteRegM2,
					Rd1e_2, Rd2e_2);

	regfile_ss rmem(clk, reset, RegWriteW1, RegWriteW2,
			InstrD1, WriteRegW1, WriteData3_1,
			InstrD2, WriteRegW2, WriteData3_2, 
			Rd1D_1, Rd2D_1, Rd1D_2, Rd2D_2
			);

	/*memory_control_ss main_mem(clk, reset, write1, read1, 
							mem_addr1, mem_addr2, wd1, wd2,
							readdata1, readdata2, stall); //CHANGE THE MAIN MEM PARAM ORDER
*/
	hazard_unit_ss hzunit(clk, reset, memtoregE1, memtoregE2,
						BTFlush1, BTFlush2, JFlush1, JFlush2, 
						RegDst1, RegDst2, InstrD1, InstrD2,
						HZStall, HZFlush); //SAME WITH MEMCTRL

	always@(posedge clk)
		PCF <= PCF + 8;

endmodule