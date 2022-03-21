module fifo(clk, rst, we, re, wrdata, rddata, full, empty);

   parameter DATA_SIZE = 8;
   parameter MEM_DEPTH = 2; 
   // Representing the number of bits needed in order to access a number of locations
   // Example: 2'b (00,01,10,11) = can access a total of 4 locations
      
   input clk, rst;
   input we, re;
   input [DATA_SIZE-1:0] wrdata; 
   output [DATA_SIZE-1:0] rddata;
   output full;
   output empty;

   // 3'b Pointers --- MEM_DEPTH = 2 => [2:0] == 3'b
   reg [MEM_DEPTH:0] wp; 
   reg [MEM_DEPTH:0] rp;

   // Write enable for memory
   wire 	     we_dual;
   assign we_dual = (we & ~full) ? 1 : 0;

     dual_port_memory
     #(
       .DATA_WIDTH(DATA_SIZE),
       .MEM_DEPTH(MEM_DEPTH)
       )
   u_dual_port_memory
     (
      .clk(clk),

      // write
      .we0(we_dual),
      .addr0(wp[MEM_DEPTH-1:0]),
      .wdata0(wrdata),
      .rdata0(),

      // read
      .we1(1'b0),
      .addr1(rp[MEM_DEPTH-1:0]),
      .wdata1({DATA_SIZE{1'b0}}),
      .rdata1(rddata)
      );

   // Full & Empty изходи
   assign full = ((wp[MEM_DEPTH-1:0] == rp[MEM_DEPTH-1:0]) & (wp[MEM_DEPTH] != rp[MEM_DEPTH])) ? 1 : 0;
   assign empty = ((rp[MEM_DEPTH-1:0] == wp[MEM_DEPTH-1:0]) & (rp[MEM_DEPTH] == wp[MEM_DEPTH])) ? 1 : 0;

   // Write Pointer Register
   always @(posedge clk or negedge rst) begin
      if (~rst) begin
	 wp <= 0;
      end
      else if (we & ~full) begin
	 wp <= wp + 1;
      end
      else begin
	 wp <= wp;
      end
   end

   // Read Pointer Register
   always @(posedge clk or negedge rst) begin
      if (~rst) begin
	 rp <= 0;
      end
      else if (re & ~empty) begin
	 rp <= rp + 1;
      end
      else begin
	 rp <= rp;
      end
   end
   
endmodule