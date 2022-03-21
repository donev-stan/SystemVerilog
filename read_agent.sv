class ReadMonitor;
   virtual readIntf mRdIntf;
   mailbox #(ReadTrans) rdMbox;
   ReadTrans rdTrx;
   bit 	   dataToBeRead;  
   
   task build();
      dataToBeRead = 0;
   endtask : build
   
   task run();
      forever begin
	 @(posedge mRdIntf.clk);

	 if (dataToBeRead) begin
	    rdTrx.setReadData(mRdIntf.rddata);
	    rdMbox.put(rdTrx);

	    dataToBeRead = 0;
 	 end

	 if((mRdIntf.re) & (~mRdIntf.empty)) begin
	    rdTrx = new();
	    rdTrx.setReadSignals(mRdIntf.re, mRdIntf.empty);
	    dataToBeRead = 1;
	 end
	 
      end
   endtask : run

   task displayInterfaceData();
      $display();
      $display("================== INTERFACE: =================");
      $display("--------------------- READ --------------------");
      $display("mRdIntf.re = ", mRdIntf.re);
      $display("mRdIntf.rddata = ", mRdIntf.rddata);
      $display("mRdIntf.empty = ", mRdIntf.empty);
      $display("===============================================");
      $display();
   endtask : displayInterfaceData

   task displayTransObjData(ReadTrans rdTrx);
      $display();
      $display("================= TRANSACTION: ================");
      $display("--------------------- READ --------------------");
      $display("rdTrx.re = ", rdTrx.re);
      $display("rdTrx.rddata = ", rdTrx.rddata);
      $display("rdTrx.empty = ", rdTrx.empty);
      $display("===============================================");
      $display();
   endtask : displayTransObjData
      
endclass : ReadMonitor

// ---Driver---
class ReadDriver;
   virtual readIntf dRdIntf;

   task run();
      forever begin
	 @(posedge dRdIntf.clk);
	 dRdIntf.re <= $random();
      end
   endtask : run

endclass : ReadDriver

// ---Agent---
class ReadAgent;
   virtual readIntf rdIntf;
   ReadDriver rdDriver;
   ReadMonitor rdMonitor;
   mailbox #(ReadTrans) rdMailbox;
   
   task build();
      rdDriver = new();
      rdMonitor = new();

      rdMonitor.build();
   endtask : build

   task connect();
      rdDriver.dRdIntf = rdIntf;
      rdMonitor.mRdIntf = rdIntf;

      rdMonitor.rdMbox = rdMailbox;
   endtask : connect

   task run();
      fork
	 rdDriver.run();
	 rdMonitor.run();
      join
   endtask : run
endclass : ReadAgent