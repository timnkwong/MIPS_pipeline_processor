module maindec(input [5:0] op,
                output memtoreg, memwrite,
                output branch, 
                output [1:0] alusrc, //changed to 2-bit to accommodate the new mux3 module
                output regdst, regwrite,
                output jump,
                output [1:0] aluop,
                output branchNot);
  
  reg [10:0] controls; //bit size increased due to addition of branchNot and extension of alusrc 
  assign {regwrite, regdst, alusrc, branch, memwrite,
          memtoreg, jump, aluop, branchNot} = controls;
  always@(*)
  case(op)
      6'b000000: controls <= 11'b11000000100; // RTYPE
      6'b100011: controls <= 11'b10010010000; // LW
      6'b101011: controls <= 11'b00010100000; // SW
      6'b000100: controls <= 11'b00001000010; // BEQ
      6'b001000: controls <= 11'b10010000000; // ADDI
      6'b000010: controls <= 11'b00000001000; // J
      6'b000101: controls <= 11'b00000000011; // BNE, all signals are 0 except for using the aluOP to determine inequality and the new branchNot signal
      6'b001101: controls <= 11'b10100000110; /* ORI, uses signals: 
                                                      regWrite to put new value in register,
                                                      [10] alusrc value to acquire the new zeroImm value
                                                      [11] aluOP value in order to do an or-operation without being an R-type
                                              */
      default: controls <= 11'bxxxxxxxxxxx; // illegal op
  endcase
endmodule