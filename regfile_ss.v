module regfile_ss( input clk,
                input reset,
                input we3_1, we3_2,

                input [31:0] instrD1, 
                input [4:0] wa3_1,
                input [31:0] wd3_1,

                input [31:0] instrD2, 
                input [4:0] wa3_2,
                input [31:0] wd3_2,
                
                output [31:0] rd1_1, rd2_1, rd1_2, rd2_2);

    reg [31:0] rf[31:0];
    integer i;

// three ported register file
// read two ports combinationally
// write third port on rising edge of clk
// register 0 hardwired to 0
// note: for pipelined processor, write third port
// on falling edge of clk
always @(*)
  if (reset)
    for(i = 0; i < 32; i = i + 1)
      rf[i] <= 32'hxxxxxxxx;

always @(posedge clk) begin
      if (we3_1) rf[wa3_1] <= wd3_1;
   	  if (we3_2) rf[wa3_2] <= wd3_2;
  end
  assign rd1_1 = (instrD1[25:21] != 0) ? rf[instrD1[25:21]] : 0;
  assign rd2_1 = (instrD1[20:16] != 0) ? rf[instrD1[20:16]] : 0;
  assign rd1_2 = (instrD2[25:21] != 0) ? rf[instrD2[25:21]] : 0;
  assign rd2_2 = (instrD2[20:16] != 0) ? rf[instrD2[20:16]] : 0;

endmodule
