module cache_tb();

reg clk, reset, read, write;
reg [31:0] memoryaddress, writedata;
reg [127:0] mainmemorydata;
reg cachewrite_enable, stall_en;
wire hit;
wire [31:0] readdata;
wire [31:0] writebackaddress;
wire [127:0] writebackdata;
wire writeback_enable;


cache_wb cache_A(clk, reset, read, write,
                memoryaddress, writedata,
                mainmemorydata,
                cachewrite_enable, stall_en,
                hit,
                readdata,
                writebackaddress,
                writebackdata,
                writeback_enable);

always #5 clk <= ~clk;
initial begin
	clk <= 1'b1;
	write <= 1'b1;
	read <= 0;
	mainmemorydata <= 32'h00000000;
	memoryaddress <= 32'h00000000;
	writedata <= 32'h00000004;
	cachewrite_enable <= 1	;
	#10
	mainmemorydata <= 32'h00000008;	
	memoryaddress <= 32'h00000800;
	writedata <= 32'h00000008;
	#10
	write <= 1'b0;
	read <= 1;
	memoryaddress <= 32'h00000000;
	#10
	memoryaddress <= 32'h00000014;
	#10
	memoryaddress <= 32'h00000800;
	#10
	read <= 0;
	write <= 1;
	memoryaddress <= 32'h00000000;
	writedata <= 32'h11111111;
	#10
	memoryaddress <= 32'h00000400;
	writedata <= 32'h00000016;
	#10
	read <= 1;
	write <= 0;
	#10 
	memoryaddress <= 32'h00000000;
	#10
	memoryaddress <= 32'h42069000;
	writedata <= 32'hbeefbeef;
	read <= 0;
	write <= 1;
	#10 
	read <= 1;
	write <= 0;

end // initial
endmodule // cache_tb