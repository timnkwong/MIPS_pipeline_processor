module btb(		input clk, reset, taken_branch, pnifE,
			input [31:0] pc, predictedpc, pce,
			output [31:0] pcprediction,
			output entryfoundF, pnif); 
			//pif = predict if taken
reg [63:0] pc_addresses[127:0][3:0];
reg [1:0] global_tables[127:0][3:0];
reg [1:0] global;

integer i, j;
initial begin
	for (i = 0; i < 128; i = i + 1) begin //instantiate all the tables with base values
		for (j = 0; j < 4; j = j + 1) begin
			pc_addresses[i][j][63:32] = 1;	//using 1 since PC can never equal 1
			pc_addresses[i][j][31:0] = 1;
			global_tables[i][j] = 2'b00; //NN state
		end
	end
	global = 0;
end

assign pnif = (global_tables[pc[6:0]][global] < 2'b10) ? 1 : 0; //if the global state is NN or NT but predict gets taken, throw a flush, vice versa
assign entryfoundF = (pc == pc_addresses[pc[6:0]][global][63:32]) ? 1 : 0;
assign pcprediction = pc_addresses[pc[6:0]][global][31:0];

always @(posedge clk) begin
	//if a branch is taken determined in decode stage
	if (taken_branch) begin //branch taken but not found case
		if (pc_addresses[pce[6:0]][global][63:32] == 1) begin //branch not in BTB, add it
			pc_addresses[pce[6:0]][global][63:32] <= pce;
			pc_addresses[pce[6:0]][global][31:0] <= predictedpc;
			global_tables[pce[6:0]][global] <= 2'b01;
		end
	end
	if(pc_addresses[pce[6:0]][global][63:32] != 1) begin //if there is an entry found, change the state
		if(taken_branch) begin //taken and found
			if(global_tables[pce[6:0]][global] != 2'b11)
				global_tables[pce[6:0]][global] = global_tables[pce[6:0]][global] + 1;
					
		end else begin //not taken but found
			if(global_tables[pce[6:0]][global] != 2'b00)
				global_tables[pce[6:0]][global] = global_tables[pce[6:0]][global] - 1;

		end
			case(global_tables[pce[6:0]][global])
			2'b11: pc_addresses[pce[6:0]][global][31:0] = predictedpc;
			2'b10: pc_addresses[pce[6:0]][global][31:0] = predictedpc;
			2'b01: pc_addresses[pce[6:0]][global][31:0] = pce + 4;
			2'b00: pc_addresses[pce[6:0]][global][31:0] = pce + 4;
		endcase // global_tables[pce[6:0]][global_history]
	end
	if(taken_branch) begin
		if(~pnifE) begin
			if (global != 2'b11) //change global state
				global = global + 1;
		end
		else if (global != 2'b00)
				global = global - 1;
	end

end
endmodule // btb