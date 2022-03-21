interface writeIntf (input bit clk, rst);

   parameter DATA_WIDTH = 8;
   
   logic we;
   logic [DATA_WIDTH-1:0] wrdata;
   logic full;

endinterface : writeIntf


interface readIntf (input bit clk, rst);

   parameter DATA_WIDTH = 8;
   
   logic re;
   logic [DATA_WIDTH-1:0] rddata;
   logic empty;

endinterface : readIntf