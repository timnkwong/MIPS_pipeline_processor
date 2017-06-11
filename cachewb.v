`define MEM_SIZE 1024

module cache_wb(input clk, reset, read, write,
                input [31:0] memoryaddress, writedata,
                input [127:0] mainmemorydata,
                input cachewrite_enable, stall_en,
                output reg hit,
                output reg [31:0] readdata,
                output reg [31:0] writeback_address,
                output reg [127:0] writeback_data,
                output reg writeback_enable,
                output reg stall);


reg [147:0] SRAM [`MEM_SIZE-1:0] [1:0];
integer i, j;

initial stall = 0;

initial begin
    for (i = 0; i < `MEM_SIZE; i = i + 1) begin
        for (j = 0; j < 2; j = j + 1)
            SRAM[i][j] = 0;
    end
end

wire [16:0] tag;
wire [9:0] idx;
wire [1:0] offset;
assign tag = memoryaddress[31:16];
assign idx = memoryaddress[13:4];
assign offset = memoryaddress[3:2];

    
always @(posedge clk) begin
    /*if(reset) begin

    end
    */
    stall = 0;
    #1
    if((SRAM[idx][0][144:128] == tag && SRAM[idx][0][146] == 1) || (SRAM[idx][1][144:128] == tag && SRAM[idx][1][146] == 1)) begin	//assign hit criteria
        assign hit = 1'b1;
    end
    else begin
        assign hit = 1'b0;
    end

    if(read) begin
        if(hit && SRAM[idx][0][144:128] == tag && SRAM[idx][0][146] == 1) begin			//hit: read current data
        	SRAM[idx][0][147] = 1;
            case (offset)
                2'b00: assign readdata = SRAM[idx][0][31:0];
                2'b01: assign readdata = SRAM[idx][0][63:32];
                2'b10: assign readdata = SRAM[idx][0][95:64];
                2'b11: assign readdata = SRAM[idx][0][127:96];
        	endcase // offset
        end

        else if(hit && SRAM[idx][1][144:128] == tag && SRAM[idx][1][146] == 1) begin		//hit: read current data
        	SRAM[idx][0][147] = 0;
            case (offset)
                2'b00: assign readdata = SRAM[idx][1][31:0];
                2'b01: assign readdata = SRAM[idx][1][63:32];
                2'b10: assign readdata = SRAM[idx][1][95:64];
                2'b11: assign readdata = SRAM[idx][1][127:96];
        	endcase // offset
        end
       /* 
        else if(~hit && SRAM[idx][0] == 0 && cachewrite_enable) begin
            SRAM[idx][SRAM[idx][0][147]][127:0] = mainmemorydata;
        end
        
        if(~hit && SRAM[idx][1] == 0 && cachewrite_enable) begin
            SRAM[idx][SRAM[idx][0][147]][127:0] = mainmemorydata;
        end
*/
        else if(~hit && ~SRAM[idx][SRAM[idx][0][147]][145]) begin // && cachewrite_enable) begin		//miss but not dirty: just read
        	if(cachewrite_enable)
            	SRAM[idx][SRAM[idx][0][147]][127:0] = mainmemorydata;     
            else
                stall = 1;
        end

        else if(~hit && SRAM[idx][SRAM[idx][0][147]][145]) begin		//miss and dirty replace and read
        	SRAM[idx][SRAM[idx][0][147]][145] = 0;
            SRAM[idx][0][147] = ~SRAM[idx][0][147];
            assign writeback_data = SRAM[idx][SRAM[idx][0][147]][127:0];
            assign writeback_enable = 1'b1;
            assign writeback_address = {tag,idx,offset, 2'b00};//offset,SRAM[idx][SRAM[idx][0][147]][146], SRAM[idx][SRAM[idx][0][147]][145]};
            if (cachewrite_enable)
                SRAM[idx][SRAM[idx][0][147]][127:0] = mainmemorydata;         
            else 
            	stall = 1;
        end
    end

    if(write) begin
        if(hit && SRAM[idx][0][144:128] == tag) begin							///hit way 2: read into cache
            SRAM[idx][0][147] = 1'b1;
            SRAM[idx][0][146] = 1'b1;
            SRAM[idx][0][145] = 1'b1;
            case (offset)
                2'b00: SRAM[idx][0][31:0] = writedata;
                2'b01: SRAM[idx][0][63:32] = writedata;
                2'b10: SRAM[idx][0][95:64] = writedata;
                2'b11: SRAM[idx][0][127:96] = writedata;
        	endcase
        end


        else if(hit && SRAM[idx][1][144:128] == tag) begin						//hit way 1: read into cache
            SRAM[idx][0][147] = 1'b0;
            SRAM[idx][1][146] = 1'b1;
            SRAM[idx][1][145] = 1'b1;
            case (offset)
                2'b00: SRAM[idx][1][31:0] = writedata;
                2'b01: SRAM[idx][1][63:32] = writedata;
                2'b10: SRAM[idx][1][95:64] = writedata;
                2'b11: SRAM[idx][1][127:96] = writedata;
            endcase
        end
        
        else if(~hit && SRAM[idx][0] == 0 )begin //&& cachewrite_enable) begin		//case: miss but empty way 0: just store
            SRAM[idx][0][147] = 1'b1;
            SRAM[idx][0][146] = 1'b1;
            SRAM[idx][0][145] = 1'b1;        
            case(offset)
                2'b00: SRAM[idx][0][31:0] = writedata;
                2'b01: SRAM[idx][0][63:32] = writedata;
                2'b10: SRAM[idx][0][95:64] = writedata;
                2'b11: SRAM[idx][0][127:96] = writedata;
            endcase
        end
        
        else if(~hit && SRAM[idx][1] == 0) begin //&& cachewrite_enable) begin 		//case: miss but empty way 1: just store
            SRAM[idx][0][147] = 1'b0;
            SRAM[idx][1][146] = 1'b1;
            SRAM[idx][1][145] = 1'b1;   
            case(offset)
                2'b00: SRAM[idx][1][31:0] = writedata;
                2'b01: SRAM[idx][1][63:32] = writedata;
                2'b10: SRAM[idx][1][95:64] = writedata;
                2'b11: SRAM[idx][1][127:96] = writedata;
            endcase
        end
        
        else if(~hit && ~SRAM[idx][SRAM[idx][0][147]][145]) begin	//case: miss and not dirty: just replace
            SRAM[idx][0][147] = 1'b0;
            SRAM[idx][SRAM[idx][0][147]][146] = 1'b1;
            SRAM[idx][SRAM[idx][0][147]][145] = 1'b1;  
            if(cachewrite_enable) 
 	           SRAM[idx][SRAM[idx][0][147]][127:0] = mainmemorydata;
        	else
               stall = 1;
            case(offset)
                2'b00: SRAM[idx][SRAM[idx][0][147]][31:0] = writedata;
                2'b01: SRAM[idx][SRAM[idx][0][147]][63:32] = writedata;
                2'b10: SRAM[idx][SRAM[idx][0][147]][95:64] = writedata;
                2'b11: SRAM[idx][SRAM[idx][0][147]][127:96] = writedata;
            endcase
        end
        
        
        else if(~hit && SRAM[idx][SRAM[idx][0][147]][145]) begin	//case: miss and dirty bit: evict memory and store new in cache
            assign writeback_data = SRAM[idx][SRAM[idx][0][147]][127:0];
            assign writeback_enable = 1'b1;
            assign writeback_address = {tag,idx,offset, 2'b00};//offset,SRAM[idx][SRAM[idx][0][147]][146], SRAM[idx][SRAM[idx][0][147]][145]};
            if (cachewrite_enable)
                SRAM[idx][SRAM[idx][0][147]][127:0]  = mainmemorydata;
        	else 
               	stall = 1;
            case(offset)
                2'b00: SRAM[idx][SRAM[idx][0][147]][31:0] = writedata;
                2'b01: SRAM[idx][SRAM[idx][0][147]][63:32] = writedata;
                2'b10: SRAM[idx][SRAM[idx][0][147]][95:64] = writedata;
                2'b11: SRAM[idx][SRAM[idx][0][147]][127:96] = writedata;
            endcase
        	end
        end
    end
 

endmodule

module mainmemory(	input 		clk, write, readmem,
					input 		[31:0] read_address,
				   	input		[31:0] write_address, 
				   	input 		[127:0] write_data,
				   	output reg	[127:0] read_data);
	reg [127:0] RAM[65536:0]; //RAM to store address-based memory
	reg [5:0] cycles;
/*	integer i;
	initial begin
		for (i = 0; i < `MEM_SIZE; i = i + 1)
			RAM[i] = 0;
	end
*/
	initial cycles = 0;

	//assign read_data = RAM[address[31:2]];
	always @(write_address or read_address) begin
		if (write)
			RAM[write_address[31:2]] <= write_data; //store data in address RAM
		if (readmem)
			read_data <= RAM[read_address[31:2]];
/*		if(read) begin
			if(cycles == 20) begin
				cycles = 0;
				stall <= 0;
			end
			else begin
				cycles = cycles + 1;
				stall <= 1;
			end
		end
		*/
	end
endmodule	

module memory_control_ss(input clk, write, read, reset,
                      input [31:0] memoryaddress, writedata,
                      output	 [31:0] read_data,
                      output reg stall);

	wire [127:0] mainmemorydata, writeback_data;	
	wire [31:0] writeback_address;
	wire c_stall, m_stall;
	wire writeback_enable;
	reg cachewrite_enable, read_main;
	reg [5:0] cycles;
	initial cycles = 0;
	initial stall = 0;
	initial cachewrite_enable = 0;
	initial read_main = 0;

	cache_wb cache(	clk, reset, read, write,
                	memoryaddress, writedata,
                	mainmemorydata,
                	cachewrite_enable, stall,
                	hit, 
                	read_data,
                	writeback_address,
                	writeback_data,
                	writeback_enable,
                	c_stall);

	mainmemory main(	clk, writeback_enable, read_main,
						memoryaddress,
						writeback_address, 
				   		writeback_data,
				   		mainmemorydata);

	always@(posedge clk) begin
		cachewrite_enable = 0;
		read_main = 0;
		if(cycles == 19) begin		//access main memory after stalling
			cycles = 0;
			cachewrite_enable = 1;
			read_main = 1;
			stall <= 0;
		end
		else if(c_stall || cycles > 0) begin 	//stalls the pipeline if we have to enter main memory
			cycles = cycles + 1;
			stall <= 1;
		end
	end
	endmodule