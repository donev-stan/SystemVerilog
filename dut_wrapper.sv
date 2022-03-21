module dut_wrapper (writeIntf write, readIntf read);

   parameter DATA_WIDTH = 8;
   parameter MEM_DEPTH = 2;
      
   fifo 
     #(
       .DATA_SIZE(DATA_WIDTH),
       .MEM_DEPTH(MEM_DEPTH)
       )
   u_fifo
     (
      .clk(write.clk),
      .rst(write.rst),

      // write
      .we(write.we),
      .wrdata(write.wrdata),
      //.wrdata({write.wrdata[DATA_WIDTH-1:1], ~write.wrdata[0]}),
      .full(write.full),

      // read
      .re(read.re),
      .rddata(read.rddata),
      .empty(read.empty)
      );

endmodule