module inst_memory_tb();
	reg [31:0] address;
	wire [31:0] read_data; 

inst_memory DUT(address, read_data);

initial
	begin
	address = 32'h0;
	#3 address = 32'h00000001;
	#3 address = 32'h00000002;
	#3 address = 32'h00000003;
	#3 address = 32'h00000004;
	#3 address = 32'h00000005;
	#3 address = 32'h00000006;
	#3 address = 32'h00000007;
	#3 address = 32'h00000008;
	#3 address = 32'h00000009;
	#3 address = 32'h0000000a;
	#3 address = 32'h0000000b;
	#3 address = 32'h0000000c;
	#3 address = 32'h0000000d;
	#3 address = 32'h0000000e;
	#3 address = 32'h0000000f;
	#3 address = 32'h00000010;
	#3 address = 32'h00000011;
	end
endmodule

	 