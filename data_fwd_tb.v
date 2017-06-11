module data_fwd_tb();
	reg [4:0] RsD, RtD, RegM, RegW, WriteRegE;
	reg RegWriteM, RegWriteW, RegWriteE, BranchD;
	wire [1:0] ForwardAE, ForwardBE;
	wire ForwardAD, ForwardBD;

data_forward MWD(	RsD, RtD, RegM, RegW,
					RegWriteM, RegWriteW,
					ForwardAE, ForwardBE);

data_forward_b ED(	WriteRegE, RsD, RtD,
					RegWriteE, BranchD,
					ForwardAD, ForwardBD);

initial begin
	RsD = 0; RtD = 0; RegM = 0; RegW = 0; WriteRegE = 0;
	RegWriteM = 1; RegWriteW = 1; RegWriteE = 1; BranchD = 1;
	#5 RsD = 10; RtD = 10; RegM = 10; RegW = 10; WriteRegE = 10;
	#5 BranchD = 0;
	#5 RegWriteM = 0;
	#5 RegWriteW = 0;
	#5 RegWriteE = 0;
	#5 BranchD = 1;
	#5 RegWriteE = 1;
	#5 RegWriteW = 1; 
	#5 RegWriteM = 1;
	#5 RtD = 5; RegM = 5;


	end
	endmodule // data_fwd_tb
