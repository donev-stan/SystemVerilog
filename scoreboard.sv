class Scoreboard #(parameter DEPTH = 2, parameter WIDTH = 8);
   mailbox #(WriteTrans) wrMbox;
   mailbox #(ReadTrans) rdMbox;
   
   WriteTrans wrTrx_fetched, wrTrx_cloned;
   ReadTrans rdTrx_fetched, rdTrx_cloned;

   bit [WIDTH-1 : 0] writtenDataQueue [$];
   bit [WIDTH-1 : 0] writtenData;
          
   task build();
      wrTrx_fetched = new();
      rdTrx_fetched = new();
   endtask : build

   task run();
      fork
	 // Get Written Data
	 forever
	   begin
	      if (~wrMbox.try_get(wrTrx_fetched)) begin

		 // Get Transaction from Mailbox
		 wrMbox.get(wrTrx_fetched);

		 // Clone Transaction
		 wrTrx_cloned = new();
		 wrTransClone(wrTrx_fetched, wrTrx_cloned);

		 // Add Write Data to Queue
		 writtenDataQueue.push_back(wrTrx_cloned.wrdata);

		 // Check Full Signal on the Cloned Transaction based on the number of Writes still not Read
		 checkFullSignal(wrTrx_cloned, writtenDataQueue.size());

		 // Display Info
		 //displayWrTransInfo(wrTrx_cloned, writtenDataQueue.size());
	      end
	   end 

	 // Get Read Data
	 forever
	   begin
	      if (~rdMbox.try_get(rdTrx_fetched)) begin

		 // Get Transaction from Mailbox
		 rdMbox.get(rdTrx_fetched);

		 // Clone Transaction
		 rdTrx_cloned = new();
		 rdTransClone(rdTrx_fetched, rdTrx_cloned);

		 // Check Empty Signal on the Cloned Transaction based on the number of Writes still not Read
		 checkEmptySignal(rdTrx_cloned, writtenDataQueue.size());

		 // If there are Writes -> take the first...
		 if (writtenDataQueue.size()) writtenData = writtenDataQueue.pop_front();
		  
		 // Compare it to the Read Transaction Read Data
		 checkDataInOut(writtenData, rdTrx_cloned.rddata);

		 // Display Info
		 //displayRdTransInfo(rdTrx_cloned, writtenDataQueue.size());
	      end
	   end 
      join
   endtask : run


   
   // Error Case 1: Number of Writes < Locations+1 AND FIFO indicates Full 
   // ---> ((numOfWrites < (1<<DEPTH)) & wrTrx_cloned.full)
   // Error Case 2: Number of Writes > Locations AND FIFO DOES NOT indicate Full
   // ---> ((numOfWrites >= (1<<DEPTH)) &  ~wrTrx_cloned.full)
   
   task checkFullSignal(WriteTrans wrTrx_cloned, int numOfWrites);

      bit hasSpaceInFIFO = 0;
      bit hasNoSpaceInFIFO = 0;

      bit indicatesFull = wrTrx_cloned.full;

      // FIFO not Full
      if (numOfWrites < ((1<<DEPTH) + 1)) 
	hasSpaceInFIFO = 1;

      // FIFO is Full
      if (numOfWrites > (1<<DEPTH))
	hasNoSpaceInFIFO = 1;
           
      if ((hasSpaceInFIFO & indicatesFull) | (hasNoSpaceInFIFO & ~indicatesFull))
	begin
	   $error("\n=================== Error With Full Signal =================",
		  "\n Transaction:",
		  "\n -wrTrx_cloned.we = %b", wrTrx_cloned.we,
		  "\n -wrTrx_cloned.wrdata = %h", wrTrx_cloned.wrdata,
		  "\n -wrTrx_cloned.full = %b", wrTrx_cloned.full,
		  "\n -Number of writes that are still not read = %d \n", numOfWrites,
		  "\n -Time = %0t", $realtime,
		  "\n============================================================");
	end
   endtask : checkFullSignal

   // Error Case 1: There are Writes AND Empty Singnal
   // Error Case 2: There are NO Writes AND NO Empty Signal
   task checkEmptySignal(ReadTrans rdTrx_cloned, int numOfWrites);

      bit indicatesEmpty = rdTrx_cloned.empty;
      
      bit writtenData = 0;
      if (numOfWrites != 0) writtenData = 1;

      if ((writtenData & indicatesEmpty) | (~writtenData & ~indicatesEmpty))
	begin
	   $error("\n================ Error With Empty Signal ===================",
		  "\n Transaction:", 
		  "\n -rdTrx_cloned.re = %b", rdTrx_cloned.re,
		  "\n -rdTrx_cloned.rddata = %h", rdTrx_cloned.rddata,
		  "\n -rdTrx_cloned.empty = %b", rdTrx_cloned.empty,
		  "\n -Written data to be read = %d", numOfWrites,
		  "\n -Time = %0t", $realtime,
		  "\n============================================================",);
	end 
   endtask : checkEmptySignal
   
   task checkDataInOut(bit [WIDTH-1:0] writtenData, bit [WIDTH-1:0] readData);
      if (writtenData != readData) 
	$error("\n======================== ERROR_DATA ========================",
	       "\n Write Data != Read Data",
	       "\n -(hex) Write Data is: %h",  writtenData,
	       "\n -(hex) Read Data is: %h",  rdTrx_cloned.rddata,
	       "\n ----------------------------------------------------------",
	       "\n -(bin) Write Data is: %b",  writtenData,
	       "\n -(bin) Read Data is: %b",  rdTrx_cloned.rddata,
	       "\n ----------------------------------------------------------",
	       "\n -(dec) Write Data is: %d",  writtenData,
	       "\n -(dec) Read Data is: %d",  rdTrx_cloned.rddata,
	       "\n -Time = %0t", $realtime,
	       "\n============================================================",);
   endtask : checkDataInOut
   

   // Clone Transactions
   task wrTransClone(WriteTrans source, WriteTrans destination);
      destination.we = source.we;
      destination.wrdata = source.wrdata;
      destination.full = source.full;
   endtask : wrTransClone

   task rdTransClone(ReadTrans source, ReadTrans destination);
      destination.re = source.re;
      destination.rddata = source.rddata;
      destination.empty = source.empty;
   endtask : rdTransClone


   // Display Info
   task displayWrTransInfo(WriteTrans wrTrx_cloned, int numOfWrites);
      $display();
      $display("================= Scoreboard =================");
      $display("------------------ WRITE_TRX -----------------");
      $display(" wrTrx_cloned.we = %b", wrTrx_cloned.we);
      $display(" wrTrx_cloned.wrdata = %h", wrTrx_cloned.wrdata);
      $display(" wrTrx_cloned.full = %b", wrTrx_cloned.full);
      $display(" writtenDataQueue = %d", numOfWrites);
      $display(" Time = %t", $realtime);
      $display("==============================================");
      $display();
   endtask : displayWrTransInfo

    task displayRdTransInfo(ReadTrans rdTrx_cloned, int numOfWrites);
       $display();
       $display("================= Scoreboard =================");
       $display("------------------ READ_TRX ------------------");
       $display(" rdTrx_cloned.re = %b", rdTrx_cloned.re);
       $display(" rdTrx_cloned.rddata = %h", rdTrx_cloned.rddata);
       $display(" rdTrx_cloned.empty = %b", rdTrx_cloned.empty);
       $display(" writtenDataQueue after ONE read = %d", numOfWrites);
       $display(" Time = %t", $realtime);
       $display("==============================================");
       $display();
   endtask : displayRdTransInfo
   
endclass : Scoreboard