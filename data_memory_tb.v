module data_memory_tb();
	reg clk, write, read;
	reg [31:0] address, write_data;
	wire [31:0] read_data;
	wire stall; 

data_memory DUT(clk, write, read, address, write_data, read_data, stall);

always #5 clk <= ~clk; 
initial
	begin
	clk <= 1'b1;
	write <= 1'b1;
	read <= 0;
	address <= 32'h00000000;
	write_data <= 32'h00000004;
	#10
	address <= 32'h00000004;
	write_data <= 32'h00000008;
	#10
	write <= 1'b0;
	address <= 32'h00000000;
	#10
	read <= 1;
	address <= 32'h00000004;
	#205
	address <= 32'h00000000;

	end
endmodule