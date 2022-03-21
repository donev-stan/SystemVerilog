module assertions(clk, rst, wp, rp, full, empty);

   parameter DEPTH = 2;
   
   input clk, rst;
   
   input [DEPTH:0] wp;
   input [DEPTH:0] rp;
   
   input full;
   input empty;

   property empty_prop;
      @(posedge clk)
	((rp[DEPTH-1:0] == wp[DEPTH-1:0]) & (rp[DEPTH] == wp[DEPTH])) |-> empty;
   endproperty

   property full_prop;
      @(posedge clk)
	((wp[DEPTH-1:0] == rp[DEPTH-1:0]) & (wp[DEPTH] != rp[DEPTH])) |-> full;
   endproperty


   empty_check: assert property (empty_prop)
     else $error("Empty not ok!");
      
   full_check: assert property (full_prop)
     else $error("Full not ok!");
   
endmodule : assertions