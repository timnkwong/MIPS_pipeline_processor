module data_memory(input 		clk, write, read,
				   input		[31:0] address, write_data,
				   output reg	[31:0] read_data,
				   output reg	stall);
	reg [31:0] RAM[65536:0]; //RAM to store address-based memory
	reg [5:0] cycles;
	initial cycles = 0;
	initial stall = 0;

	//assign read_data = RAM[address[31:2]];
	always @(posedge clk) begin
		#1
		if (write)
			RAM[address[31:2]] <= write_data; //store data in address RAM
		if(read) begin
			if(cycles == 20) begin
				cycles = 0;
				stall <= 0;
				read_data <= RAM[address[31:2]];
			end
			else begin
				cycles = cycles + 1;
				stall <= 1;
			end
		end
	end
endmodule	