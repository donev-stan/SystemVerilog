module dual_port_memory(clk, we0, we1, addr0, addr1, wdata0, wdata1, rdata0, rdata1);

   parameter DATA_WIDTH = 8;
   parameter MEM_DEPTH = 2;
   // Representing the number of bits needed in order to access a number of locations
   // Example: 2'b (00,01,10,11) = can access a total of 4 locations
   
   input clk;
   input we0, we1;
   input [MEM_DEPTH-1:0] addr0, addr1;
   input [DATA_WIDTH-1:0] wdata0, wdata1;
   output reg [DATA_WIDTH-1:0] rdata0, rdata1;

   reg [DATA_WIDTH-1:0] memory [0:(1<<MEM_DEPTH)-1]; // 2^N == 1<<N

   // Write data
   always @(posedge clk) begin
      if ((we0) & (we1) & (addr0 == addr1)) begin
	 memory[addr0] <= {DATA_WIDTH{1'bx}};
      end
      else begin
	 if (we0) 
	   memory[addr0] <= wdata0;

	 if (we1)
	   memory[addr1] <= wdata1;
      end
   end
  

   // Read
   always @(posedge clk) begin
      // Port 0
      if ((~we0 & we1) & (addr0 == addr1))
	rdata0 = {DATA_WIDTH{1'bx}};
      else
	rdata0 = memory[addr0];

      // Port 1
      if ((~we1 & we0) & (addr0 == addr1))
	rdata1 = {DATA_WIDTH{1'bx}};
      else
	rdata1 = memory[addr1];
   end

endmodule