module memory_control_tb();

reg clk, write, read, reset;
reg [31:0] memoryaddress, writedata;
wire [31:0] read_data;
wire stall;

memory_control memctrl(	clk, write, read, reset,
                      	memoryaddress, writedata,
                      	read_data,
                      	stall);

	
always #5 clk <= ~clk;
initial begin
	clk <= 1'b1;
	write <= 1'b1;
	read <= 0;
	memoryaddress <= 32'h42060000;
	writedata <= 32'h00000004;
	#10
	memoryaddress <= 32'hf1f10004;
	writedata <= 32'h00000008;
	#10
	memoryaddress <= 32'h42060000;
	writedata <= 32'h0000ffff;
	#10
	memoryaddress <= 32'h00000000;	
	writedata <= 32'habcdef00;
	#10
	read <= 1;
	write <= 0;
	memoryaddress <= 32'h42060000;

	// #10
	// memoryaddress <= 32'h21996000;
	// writedata <= 32'hbeefbeef;
	// #10
	// memoryaddress <= 32'h42060000;
	// #200
	// read <= 1;
	// write <= 0;
	// memoryaddress <= 32'h42060000;
	// #200
	// memoryaddress <= 32'h42160000;
	// #10
	// memoryaddress <= 32'h4206000a;

end // initial
endmodule // cache_tb