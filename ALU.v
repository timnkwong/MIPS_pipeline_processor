module ALU (input [31:0] In1, In2, input [3:0] Func, output reg [31:0] ALUout, output zero) ;
  wire [31:0] BB ;
  wire [31:0] S ;
  wire   cout ;
  wire [31:0] u_i1;
  wire [31:0] u_i2;
  
  assign u_i1 = In1;
  assign u_i2 = In2;

  assign BB = (Func[3]) ? ~In2 : In2 ; //1 = subtract, 0 = add
  assign {cout, S} = Func[3] + In1 + BB ; //add subtract function with carry
  always @ * begin
   case (Func[2:0]) 
    3'b000 : ALUout <= In1 & BB ;  //AND
    3'b001 : ALUout <= In1 | BB ;  //OR/ORI
    3'b010 : ALUout <= S ;         //ADD/SUB
    3'b011 : ALUout <= {31'd0, S[31]}; //SLT
    3'b100 : ALUout <= In1 ^ BB;   // XOR
    3'b101 : ALUout <= {In2[15:0], 16'b0}; //LUI
    3'b110 : ALUout <= S ;         // ADDU/SUBU
    3'b111 : ALUout <= u_i1 < u_i2;   // SLT-U/-IU
    //3'b101 : ALUout <= In1 ^~ BB;  //XNOR
   endcase
  end 
   
  assign zero = (ALUout == 0) ; 
 endmodule

