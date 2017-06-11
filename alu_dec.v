module aludec(input [5:0] funct,
              input [3:0] aluop,
              output reg [3:0] alucontrol,
              output reg multiply, mfhi, mflo);
always@(*) begin
  multiply <= 0;
  mfhi <= 0;
  mflo <= 0;
  case(aluop)
      4'b0000: alucontrol <= 4'b0010; // add (for lw/sw/addi)
      4'b0001: alucontrol <= 4'b1010; // sub (for beq)
      4'b0011: alucontrol <= 4'b0001; // ori
      4'b1000: alucontrol <= 4'b1011; // slti
      4'b1001: alucontrol <= 4'b1111; // sltiu
      4'b1010: alucontrol <= 4'b0000; // andi
      4'b1011: alucontrol <= 4'b0100; // xori
      4'b1111: alucontrol <= 4'b0101; // lui
          default: case(funct) // R-type instructions
                6'b100000: alucontrol <= 4'b0010; // add
                6'b100010: alucontrol <= 4'b1010; // sub

                6'b100100: alucontrol <= 4'b0000; // and

                6'b101010: alucontrol <= 4'b1011; // slt
                6'b101011: alucontrol <= 4'b1111; // sltu

                6'b100001: alucontrol <= 4'b0110; // addu
                6'b100011: alucontrol <= 4'b1110; // subu

                6'b100101: alucontrol <= 4'b0001; // or
                6'b100110: alucontrol <= 4'b0100; // xor
                //6'b100111: alucontrol <= 4'b0101; // xnor

                6'b011000:  multiply <= 1;
                6'b011001:  multiply <= 1; 
                6'b010000:  mfhi <= 1; 
                6'b010010:  mflo <= 1;
                default: begin  alucontrol <= 4'bxxxx; // ???
                                multiply <= 1'b0;

                        end
          endcase
  endcase
end
endmodule