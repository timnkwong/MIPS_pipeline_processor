module controller_tb();
	reg [5:0] op;
	wire 	memtoreg, memwrite,
			branch, alusrc,
			regdst, regwrite,
			jump, branchNot;
	wire [3:0] aluop;

controller main(op, memtoreg, memwrite, branch,
				alusrc, regdst, regwrite, jump, aluop, branchNot);

initial begin
    	op = 6'b000000; // RTYPE
    #5 	op = 6'b100011;// LW
    #5 	op = 6'b101011; // SW
    #5 	op = 6'b000100; // BEQ
    #5 	op = 6'b000101; // BNE
    #5 	op = 6'b001000; // ADDI
    #5 	op = 6'b000010; // J
    #5 	op = 6'b001101; // ORI
    #5 	op = 6'b001001; // ADDIU
    #5 	op = 6'b001010;  // SLTI
    #5 	op = 6'b001011;  // SLTIU
    #5 	op = 6'b001111;  // LUI
    #5 	op = 6'b001100;  // ANDI
    #5 	op = 6'b001110;  // XORI
	end
endmodule	
