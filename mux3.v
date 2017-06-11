module mux3 #(parameter WIDTH = 8) //new mux3 module to accommodate for the new srcb signal requirement
            (input [WIDTH-1:0] d0, d1, d2,
            input [1:0] s,
            output [WIDTH-1:0] y);
            
          wire d3 = 2'bxx;
  assign y = (s == 0)? d0 :(s == 1)? d1 :(s == 2)? d2 : d3;
  //assign y = s ? d2 : d1 : d0; obsolete
endmodule