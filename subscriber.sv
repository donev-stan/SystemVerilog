class Subscriber;
   
   virtual writeIntf wrIntf;
   virtual readIntf rdIntf;

   covergroup cg;
      we_0 : coverpoint wrIntf.we {bins we_0 = {0};}
      we_1 : coverpoint wrIntf.we {bins we_1 = {1};}
      
      re_0 : coverpoint rdIntf.re {bins re_0 = {0};}
      re_1 : coverpoint rdIntf.re {bins re_1 = {1};}

      full_0 : coverpoint wrIntf.full {bins full_0 = {0};}
      full_1 : coverpoint wrIntf.full {bins full_1 = {1};}
		  
      empty_0 : coverpoint rdIntf.empty {bins empty_0 = {0};}
      empty_1 : coverpoint rdIntf.empty {bins empty_1 = {1};}

      we_full_1_re_0 : cross we_1, full_1, re_0;
      re_empty_1_we_0 : cross re_1, empty_1, we_0;

      we_re_full_1 : cross we_1, re_1, full_1;
      we_re_empty_1 : cross we_1, re_1, empty_1;
   endgroup : cg
      
     function new();
	cg = new;
	return this;
     endfunction
   
   task sample_cg();
      forever 
	begin
	   if(wrIntf.rst) begin
              @(posedge wrIntf.clk);
              cg.sample();
	   end
	end
   endtask : sample_cg
   
endclass : Subscriber