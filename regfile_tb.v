module regfile_tb();
	reg clk, reset, we;
	reg [4:0] ra1, ra2, wa3;
	reg [31:0] wd3;
	wire [31:0] rd1, rd2;


regfile regtest(clk, reset, we, ra1, ra2, wa3, wd3, rd1, rd2);

always #10 clk <= !clk;

initial begin
	clk = 0;
	ra1 = 0;
	ra2 = 0;
	reset = 0;
	wa3 = 10;
	wd3 = 420;
	we = 1;
	#10 ra1 = 10; ra2 = 10;
	#5 wa3 = 23; wd3 = 143; 
	#15 ra2 = 23; 
	#5 wa3 = 2; wd3 = 2152;
	#15 ra1 = 2; 
	#5 wa3 = 10; wd3 = 421;
	#15 ra2 = 21; 
	#5 wa3 = 21; wd3 = 152;
	#15 reset = 1;
	#5 ra1 = 10; ra2 = 10;
	#15 ra1 = 21;	
end
endmodule // regfile_tb