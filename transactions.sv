class WriteTrans #(parameter DATA_WIDTH = 8);
   
   bit we;
   logic [DATA_WIDTH-1:0] wrdata;
   bit full;

   task setWriteData(bit we, logic [DATA_WIDTH-1:0] wrdata, bit full);
      this.we = we;
      this.wrdata = wrdata;
      this.full = full;
   endtask : setWriteData

endclass : WriteTrans

class ReadTrans #(parameter DATA_WIDTH = 8);

   bit re;
   logic [DATA_WIDTH-1:0] rddata;
   bit empty;

   task setReadSignals(bit re, bit empty);
      this.re = re;
      this.empty = empty;
   endtask : setReadSignals

   task setReadData(logic [DATA_WIDTH-1:0] rddata);
      this.rddata = rddata;
   endtask : setReadData
   
endclass : ReadTrans