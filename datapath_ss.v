module datapath_ss( input           clk, reset, HZStall, HZFlush, 
                    input [31:0]    InstrF, RD1D, RD2D,
                    input           SSForwardAE, SSForwardBE,

                    input [31:0]    SSAluInA, SSAluInB,

                    output [31:0]   InstrD, ALUOutE, ALUOutM, 
                                    ReadDataM, WriteData3,

                    output          RegWriteW, RegWriteE, RegWriteM,
                    output [4:0]    WriteRegW, WriteRegE, WriteRegM,
                                    RsE, RtE
    );

    wire [63:0] product;
    
    wire [31:0] PCPlus4F, PCF, PCD, PCE, PCPlus4E, PCBranchD, PCBranchE, PCBranchD_1, PCnext, PCnext2, WriteDataE, MultiOut, PCPredictionF,
                //PCF,
                InstrF1, WriteDataM, ResultW,
                //InstrD, 
                PCPlus4D, Jump1, JumpOff, product_lo, product_hi, mlout,
                RD1, RD2, SignImmD, SignImmS2, SignImmE, ZeroImmD, ZeroImmE,
                SrcAE, SrcBE, SrcAD, SrcBD, 
                SrcAEFinal, SrcBEFinal, // RD1D, RD2D, 
                RD1E, RD2E, 
                PCnext1, FixedPredictionPC,
                ALUOutEx, //ALUOutM,
                ALUOutW, // ReadDataM, 
                ReadDataW, JumpTarget;


    wire [5:0]  FuncD, FuncE;
                
    wire [4:0]  RsD, RtD, RdD, //RsE, 
                //RtE; 
                RdE;
                //WriteRegE, WriteRegM;

    wire [3:0]  ALUControlD, ALUControlE, ALUControlFinal;

    wire [1:0]  ForwardAE, ForwardBE, ALUSrcD, ALUSrcE;

    wire        RegWriteD, //RegWriteE, RegWriteM, 
                MemtoRegD, MemtoRegE, MemtoRegM, MemtoRegW,
                MemWriteD, MemWriteE, MemWriteM, WrongPredict1, WrongPredict2,
                //Data_Mem_Read,
                RegDstD, RegDstE, MfhiE, MfloE, MfloM, MfhiM, MfloW, MfhiW, multied, JFlush,
                BranchD, BNotEquals, BEquals, PCSrcD, PCSrc,
                ForwardAD, ForwardBD, mult_ready, TakePredictF, TakePredictD, TakePredictE,
                Stall, EqualD, Multiply, jump, Zero, Cache_Stall, BTFlush, PredictNTakenF, PredictNTakenD, PredictNTakenE,
		          EntryFoundF, EntryFoundD, EntryFoundE, BranchTakenE, BranchTakenD;


// INSTRUCTION FETCH STAGE

/*    mux2 #(32) fixPC_mux(PCPlus4E, PCBranchE, BranchTakenE, FixedPredictionPC); //wrong prediction, fix PC
    mux2 #(32) pcnext_mux(PCPlus4F, PCPredictionF, TakePredictF, PCnext1); //mux to determine PCnext
    mux2 #(32) correct_pc(PCnext1, FixedPredictionPC, BTFlush, PCnext2); //determine if PC needs to be fixed
    mux2 #(32) jumpbranch(PCnext2, JumpTarget, jump, PCnext);
    flopr #(32) pcreg(clk, Stall, Cache_Stall, reset, PCnext, PCF);    //initial clk to get next PC address*/
    /*adder pcadd4(PCF, 32'b100, PCPlus4F);          //PC + 4*/
    /*inst_memory fetch(PCF[7:2], InstrF1); //instantiates with reading file*/
    /*mux2 #(32) btflush_mux(InstrF1, 0, BTFlush, InstrF);*/

    //btb br_table(clk, reset, BranchTakenE, PredictNTakenE, PCF, PCBranchE, PCE, PCPredictionF, EntryFoundF, PredictNTakenF);
    /*assign TakePredictF = (EntryFoundF && ~PredictNTakenF) ? 1 : 0;*/

    blockFD f2d(clk, InstrF, PCPlus4F, PCF, EntryFoundF, PredictNTakenF, TakePredictF, Cache_Stall, reset,
                HZStall, JFlush, HZFlush, InstrD, PCPlus4D, PCD, EntryFoundD, PredictNTakenD, TakePredictD); //fetch to decode block
  

// DECODE STAGE

    controller ctrl_unit(   clk, reset, InstrD[31:26], MemtoRegD, 
                            MemWriteD, BranchD, ALUSrcD,
                            RegDstD, RegWriteD, jump, ALUControlD, BranchNot); //controller takes in funct and opcode to produce control signals


    /*regfile rf(clk, reset, RegWriteW, InstrD[25:21], InstrD[20:16], //regfile to store register memory
                WriteRegW, WriteData3, RD1D, RD2D);
*/
    data_forward_b branch_forward(  WriteRegE, RsD, RtD, //data forwarding for the EQUALS arithmetic and branching
                                    RegWriteE, BranchD, BranchNot,
                                    ForwardAD, ForwardBD);

    mux2 #(32) fwdA(RD1D, ALUOutE, ForwardAD, SrcAD);   //muxes to determine equality function
    mux2 #(32) fwdB(RD2D, ALUOutE, ForwardBD, SrcBD);   

    is_equal Equals (SrcAD, SrcBD, EqualD);             //equals function for branching
    assign BNotEquals = (BranchNot && !EqualD) ?     1 : 0;
    assign BEquals = (BranchD && EqualD) ? 1 : 0;
    
    mux2 #(1) PCSrcMux (BNotEquals, BEquals, EqualD, BranchTakenD); //branching mux
    
    assign FuncD = InstrD[5:0];
    assign RsD = InstrD[25:21];
    assign RtD = InstrD[20:16];

    zeroext ze(InstrD[15:0], ZeroImmD);  //sign and zero extensions for future inputs
    signext se(InstrD[15:0], SignImmD);
    jsignext jse(InstrD[25:0], Jump1);
    sl2 jsl2(Jump1, JumpOff);
    assign JumpTarget = {InstrD[31:28], JumpOff[27:0]}; //jump address

    sl2 immsh(SignImmD, SignImmS2);
    adder pcadd2(PCPlus4D, SignImmS2, PCBranchD);

    blockDE d2e(clk, RD1D, RD2D, InstrD[25:21], InstrD[20:16], InstrD[15:11], FuncD, SignImmD, ZeroImmD, PCBranchD, PCPlus4D, PCD,
                RegWriteD, MemtoRegD, MemWriteD, ALUControlD, ALUSrcD, RegDstD, BranchD, EntryFoundD, BranchTakenD, PredictNTakenD, TakePredictD, 
                Cache_Stall, jump, BTFlush,
                HZFlush, reset, RD1E, RD2E, RsE, RtE, RdE, FuncE, SignImmE, ZeroImmE, PCBranchE, PCPlus4E, PCE,
                RegWriteE, MemtoRegE, MemWriteE, ALUControlE, ALUSrcE, RegDstE, BranchE, EntryFoundE, BranchTakenE, PredictNTakenE, TakePredictE,
                JFlush); //block for decode -> execute stage
    
// EXECUTE STAGE
/*
    assign BTFlush = (~TakePredictE ~^ BranchTakenE) ? 1 : 0; //if predicting to take but not taken and vice versa, throw flush*/
    

    aludec alu_ctrl(FuncE, ALUControlE, ALUControlFinal, Multiply, MfhiE, MfloE); //alu controls
    
    mux2 #(5) wregmux(RtE, RdE, RegDstE, WriteRegE);


    data_forward A_forward( RsE, RtE, WriteRegM, WriteRegW,
                            RegWriteM, RegWriteW,
                            ForwardAE, ForwardBE);          //data forwarding for ALU inputs    
    
    mux3 #(32) srcamux(RD1E, ResultW, ALUOutM, ForwardAE, SrcAE);           //mux to determine src inputs
    mux3 #(32) srcbmux(RD2E, ResultW, ALUOutM, ForwardBE, WriteDataE);
    mux3 #(32) srcbmux2(WriteDataE, SignImmE, ZeroImmE, ALUSrcE, SrcBE);

    multiplier multi(   clk, Multiply, 
                        SrcAE, SrcBE,
                        mult_ready, 
                        product);
    assign product_hi = product[63:32];
    assign product_lo = product[31:0];

    mux2 #(32) ss_alusrca_mux(SrcAE, SSAluInA, SSForwardAE, SrcAEFinal);
    mux2 #(32) ss_alusrcb_mux(SrcBE, SSAluInB, SSForwardBE, SrcBEFinal);
    ALU alu1(SrcAEFinal, SrcBEFinal, ALUControlFinal, ALUOutEx, Zero);                //ALU for arithmetic

    mux2 #(32) aluMUX(  ALUOutEx, product_lo, Multiply, ALUOutE);
    blockEM e2m(clk,    ALUOutE, WriteDataE, WriteRegE, RegWriteE, MemtoRegE, MemWriteE, MfloE, MfhiE, Cache_Stall,
                        ALUOutM, WriteDataM, WriteRegM, RegWriteM, MemtoRegM, MemWriteM, MfloM, MfhiM);   //block for exectue to memory stage

// MEMORY STAGE


    /*memory_control mem_sys( clk, MemWriteM, MemtoRegM, reset,
                            ALUOutM, WriteDataM,
                            ReadDataM,
                            Cache_Stall);*/
    /*cache_wb cachemoney(input clk, reset, read, write
                input [31:0] memoryaddress, writedata,
                input [127:0] mainmemorydata,
                input cachewrite_enable
                output hit
                output [31:0] readdata,
                output [31:0] writebackaddress,
                output [127:0] writebackdata,
                output writeback_enable; //NEW CACHE TO SEND OUT DATA MEMORY READ
    */
    //data_memory main_memory(clk, MemWriteM, MemtoRegM, ALUOutM, WriteDataM, ReadDataM, Cache_Stall);       //data memory for storing address-based data

    blockMW m2w(clk,    ReadDataM, ALUOutM, WriteRegM, RegWriteM, MemtoRegM, MfloM, MfhiM, Cache_Stall,
                        ReadDataW, ALUOutW, WriteRegW, RegWriteW, MemtoRegW, MfloW, MfhiW);   //block for memory to writeback stge

// REG W/B STAGE
    mux2 #(32) mlch(product_hi, product_lo, MfloW, mlout);
    assign multied = (MfloW || MfhiW) ? 1 : 0;

    mux2 #(32) wbmux(ALUOutW, ALUOutW, MemtoRegW, ResultW);

    mux2 #(32) writedat(ResultW, mlout, multied, WriteData3);

endmodule

module is_equal(    input [31:0]    in1, in2, 
                    output reg      out);
    always@(*)
        if(in1 == in2) out <= 1;
        else out <= 0;
    endmodule   

module blockFD( input               clk,                //blocks for sending inputs to next pipeline phases
                input [31:0]        InstrF,
                input [31:0]        PCPlus4F, PCF,
                input               EntryFoundF, PredictNTakenF, TakePredictF, Cache_Stall, Stall, reset,
                input               clear, BTFlush,
                output reg [31:0]   InstrD,
                output reg [31:0]   PCPlus4D, PCD, 
		      output reg	    EntryFoundD, PredictNTakenD, TakePredictD);

    always @(posedge reset) begin
            InstrD <= 0;
            PCPlus4D <= 0;
	    EntryFoundD <= 0;
	    PredictNTakenD <= 1;
	    PCD <= 0;
        end 

    always @(posedge clk) begin
	if (clear) begin
	    PCD <= 0;
	    InstrD <= 0;
        PCPlus4D <= 0;
	    EntryFoundD <= 0;
	    PredictNTakenD <= 1;
        TakePredictD <= 0;
        end 
	else begin 
	    PCD <= PCF;
            InstrD <= InstrF;
	       EntryFoundD <= EntryFoundF;
            PredictNTakenD <= PredictNTakenF;  
            TakePredictD <= TakePredictF;    
	      // PCPlus4D <= #1 PCPlus4F;  
	end 
end
        
endmodule 

module blockDE( input               clk,
                input [31:0]        RD1D, RD2D,
                input [4:0]         RsD, RtD, RdD, 
                input [5:0]         FuncD,
                input [31:0]        SignImmD, ZeroImmD, PCBranchD, PCPlus4D, PCD,
                input               RegWriteD, MemtoRegD, MemWriteD,
                input [3:0]         ALUControlD,
                input [1:0]         ALUSrcD, 
                input               RegDstD, BranchD, EntryFoundD, NeedBranchD, PredictNTakenD, TakePredictD,  stall, jump, BTFlush, clear, reset,
                output reg [31:0]   RD1E, RD2E,
                output reg [4:0]    RsE, RtE, RdE, 
                output reg [5:0]    FuncE,
                output reg [31:0]   SignImmE,ZeroImmE, PCBranchE, PCPlus4E, PCE,
                output reg          RegWriteE, MemtoRegE, MemWriteE,
                output reg [3:0]    ALUControlE,
                output reg [1:0]    ALUSrcE, 
                output reg          RegDstE, BranchE, EntryFoundE, NeedBranchE, PredictNTakenE, TakePredictE, JFlush);

    always @(reset) begin
            RD1E <= 0;
            RD2E <= 0;
            RsE <= 0;
            RtE <= 0;
            RdE <= 0;
            SignImmE <= 0;
            RegWriteE <= 0;
            MemtoRegE <= 0;
            MemWriteE <= 0;
            ALUControlE <= 0;
            ALUSrcE <= 2'b00;
            RegDstE <= 0;
            FuncE <= 0;
            ZeroImmE <= 0;
            BranchE <= 0;
	    NeedBranchE <= 0;
	    EntryFoundE <= 0;
	    PredictNTakenE <= 1;
        TakePredictE <= 0;
	    PCBranchE <= 0;  
	    PCPlus4E <= 0;
	    PCE <= 0;
	    JFlush <= 0;
	end
	
    always @(posedge clk)
        if ((clear || BTFlush) && !stall) begin
            RD1E <= 0;
            RD2E <= 0;
            RsE <= 0;
            RtE <= 0;
            RdE <= 0;
            SignImmE <= 0;
            RegWriteE <= 0;
            MemtoRegE <= 0;
            MemWriteE <= 0;
            ALUControlE <= 0;
            ALUSrcE <= 2'b00;
            RegDstE <= 0;
            FuncE <= 0;
            ZeroImmE <= 0;
            BranchE <= 0;
	    NeedBranchE <= 0;
	    EntryFoundE <= 0;
        TakePredictE <= 0;
	    PredictNTakenE <= 1;
	    PCBranchE <= 0;  
	    PCPlus4E <= 0;
	    PCE <= 0;
	    JFlush <= 0;
        end 
        else begin
            RD1E <= RD1D;
            RD2E <= RD2D;
            RsE <= RsD;
            RtE <= RtD;
            RdE <= RdD;
            SignImmE <= SignImmD;
            RegWriteE <= RegWriteD;
            MemtoRegE <= MemtoRegD;
            MemWriteE <= MemWriteD;
            ALUControlE <= ALUControlD;
            ALUSrcE <= ALUSrcD;
            RegDstE <= RegDstD;
            FuncE <= FuncD;
            ZeroImmE <= ZeroImmD;
            BranchE <= BranchD;
	    
	    EntryFoundE <= EntryFoundD;
        TakePredictE <= TakePredictD;
        PredictNTakenE <= PredictNTakenD;
	    PCBranchE <= PCBranchD;   
	    PCPlus4E <= PCPlus4D;   
	    PCE <= PCD;   
	    JFlush <= jump;
        NeedBranchE <=  #1 NeedBranchD;
    end 
endmodule 

module blockEM( input               clk,
                input [31:0]        ALUOutE, WriteDataE,
                input [4:0]         WriteRegE,
                input               RegWriteE, MemtoRegE, MemWriteE, MfloE, MfhiE, stall,
                output reg [31:0]   ALUOutM, WriteDataM,
                output reg [4:0]    WriteRegM,
                output reg          RegWriteM, MemtoRegM, MemWriteM, MfloM, MfhiM);

    always @(posedge clk) begin
        
            ALUOutM <= ALUOutE;
            WriteDataM <= WriteDataE;
            WriteRegM <= WriteRegE;
            RegWriteM <= RegWriteE;
            MemtoRegM <= MemtoRegE;
            MemWriteM <= MemWriteE;
            MfloM <= MfloE;
            MfhiM <= MfhiE;
        
    end     
endmodule 

module blockMW( input               clk,
                input [31:0]        ReadDataM, ALUOutM,
                input [4:0]         WriteRegM,
                input               RegWriteM, MemtoRegM, MfloM, MfhiM, stall,
                output reg [31:0]   ReadDataW, ALUOutW,
                output reg [4:0]    WriteRegW,
                output reg          RegWriteW, MemtoRegW, MfloW, MfhiW);

    always @(posedge clk) begin
        
            ALUOutW <= ALUOutM;
            ReadDataW <= ReadDataM;
            WriteRegW <= WriteRegM;
            RegWriteW <= RegWriteM;
            MemtoRegW <= MemtoRegM;
            MfloW <= MfloM;
            MfhiW <= MfhiM;
        
    end     
endmodule 