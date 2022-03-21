bind fifo assertions 
  #(.DEPTH(MEM_DEPTH))
u_assertions 
  (
   .clk(clk), 
   .rst(rst), 
   .wp(wp), 
   .rp(rp), 
   .full(full), 
   .empty(empty)
   );