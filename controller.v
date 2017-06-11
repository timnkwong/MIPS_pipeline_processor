module controller( input clk, reset,
                input [5:0] op,
                output memtoreg, memwrite,
                output branch, 
                output [1:0] alusrc, //changed to 2-bit to accommodate the new mux3 module
                output regdst, regwrite,
                output jump,
                output [3:0] aluop,
                output branchNot);
  
  reg [12:0] controls; //bit size increased due to addition of branchNot and extension of alusrc 
  assign {regwrite, regdst, alusrc, branch, memwrite,
          memtoreg, jump, aluop, branchNot} = controls;
  always@(*) begin
  if (reset)
      controls <= 13'b0000000000000;
  end
  always@(op) begin
  case(op)
      6'b000000:  controls <= 13'b1100000001000; // RTYPE
      6'b100011:  controls <= 13'b1001001000000; // LW
      6'b101011:  controls <= 13'b0001010000000; // SW
      6'b000100:  controls <= 13'b0000100000010; // BEQ
      6'b000101:  controls <= 13'b0000000000011; // BNE
      6'b001000:  controls <= 13'b1001000000000; // ADDI
      6'b000010:  controls <= 13'b0000000100000; // J
      6'b001101:  controls <= 13'b1010000000110; // ORI
      6'b001001:  controls <= 13'b1001000000000; // ADDIU
      6'b001010:  controls <= 13'b1001000010000;  // SLTI
      6'b001011:  controls <= 13'b1001000010010;  // SLTIU
      6'b001111:  controls <= 13'b1001000011110;  // LUI
      6'b001100:  controls <= 13'b1001000010100;  // ANDI
      6'b001110:  controls <= 13'b1001000010110;  // XORI

      default: controls <= 13'b0000000000000; // illegal op
  endcase
end
endmodule