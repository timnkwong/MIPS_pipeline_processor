module inst_memory_ss(	input	[31:0] PCF, //[5:0] address,
					   output	[63:0] read_data);
	reg	[31:0]  RAM[63:0];

	initial
		begin
			$readmemh("memdata.dat", RAM); //read memory of .dat and store in RAM
		end

	assign read_data[31:0] = RAM[PCF[7:2]];
	assign read_data[63:32] = RAM[PCF[7:2] + 1];
endmodule



