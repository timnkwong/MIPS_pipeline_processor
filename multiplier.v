module multiplier(input         clk, start, 
                  input         [31:0]  multiplier,multiplicand,
                  output        ready, 
                  output reg [63:0] product);


   reg  lsb;
   reg [31:0]    abs_multiplicand;

   reg [5:0]     bit; 
   assign      ready = !bit;
   
   initial bit = 0;

   always @( posedge clk ) begin

     if( ready && start ) begin
        
        bit     = 32;
        product = { 32'd0, multiplier[31] ? -multiplier : multiplier };
        abs_multiplicand = multiplicand[31] ? -multiplicand : multiplicand;
         
     end else if( bit ) begin:A

        lsb     = product[0];
        product = product >> 1;
        bit     = bit - 1;

        if( lsb ) product[63:31] = product[62:31] + abs_multiplicand;

        if( !bit && multiplicand[31] ^ multiplier[31] ) product = -product;
     end
   end

endmodule