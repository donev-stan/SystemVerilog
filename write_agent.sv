class WriteMonitor;
   virtual writeIntf mWrIntf;
   mailbox #(WriteTrans) wrMbox;

   task run();
      forever begin
	 @(posedge mWrIntf.clk);
	 
	 if ((mWrIntf.we) & (~mWrIntf.full)) begin
	    WriteTrans wrTrx;
	    wrTrx = new();
	    
	    wrTrx.setWriteData(mWrIntf.we, mWrIntf.wrdata, mWrIntf.full);
	    wrMbox.put(wrTrx);
	 end
      end
   endtask : run

   task displayInterfaceData();
      $display();
      $display("================== INTERFACE: =================");
      $display("-------------------- WRITE --------------------");
      $display("mWrIntf.we = ", mWrIntf.we);
      $display("mWrIntf.wrdata = ", mWrIntf.wrdata);
      $display("mWrIntf.full = ", mWrIntf.full);
      $display("===============================================");
      $display();
   endtask : displayInterfaceData

   task displayTransObjData(WriteTrans wrTrx);
      $display();
      $display("================== TRANSACTION: ================");
      $display("--------------------- WRITE --------------------");
      $display("wrTrx.we = ", wrTrx.we);
      $display("wrTrx.wrdata = ", wrTrx.wrdata);
      $display("wrTrx.full = ", wrTrx.full);
      $display("================================================");
      $display();
   endtask : displayTransObjData
   
endclass : WriteMonitor

// ---Driver---
class WriteDriver;
   virtual writeIntf dWrIntf;

   task run();
      forever begin
	 @(posedge dWrIntf.clk);
	 dWrIntf.we <= $random();
	 dWrIntf.wrdata <= $random();
      end
   endtask : run
   
endclass : WriteDriver

// ---Agent---
class WriteAgent;
   virtual writeIntf wrIntf;
   WriteDriver wrDriver;
   WriteMonitor wrMonitor;
   mailbox #(WriteTrans) wrMailbox;

   task build();
      wrDriver = new();
      wrMonitor = new();
   endtask : build

   task connect();
      wrDriver.dWrIntf = wrIntf;
      wrMonitor.mWrIntf = wrIntf;

      wrMonitor.wrMbox = wrMailbox; 
   endtask : connect

   task run();
      fork
	 wrDriver.run();
	 wrMonitor.run();
      join
   endtask : run
endclass : WriteAgent