module ALU_tb();
	reg [31:0] In1, In2;
	reg [3:0] Func;
	wire [31:0] ALUout;
	wire zero;

ALU alu1(In1, In2, Func, ALUout, zero);

initial begin
	In1 = 2;
	In2 = 1;
	Func = 4'b0000;		//and
	#5 Func = 4'b0010; 	//add
	#5 Func = 4'b1010;	//sub
	#5 Func = 4'b0001;	//ori
	#5 Func = 4'b1011;	//slti
	#5 Func = 4'b1111;	//sltiu
	#5 Func = 4'b0100;	//xori
	#5 Func = 4'b0101;	//lui
	#5 Func = 4'b0110;	//addu
	#5 Func = 4'b1110;	//subu
	#5 Func = 4'b0110; 	//addu
	#5 In1 = 32'hffffffff;
	#5 Func = 4'b0010; 
	#5 Func = 4'b1010; In2 = 32'hffffffff;
	#5 In1 = -1; In2 = -2; Func = 4'b1011;
	#5 Func = 4'b1111;



end // initial
endmodule // ALU_tb

