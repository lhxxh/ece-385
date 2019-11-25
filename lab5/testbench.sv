module testbench();

timeunit 10ns;	// Half clock cycle at 50 MHz
			// This is the amount of time represented by #1 
timeprecision 1ns;

 logic[7:0]					SW;
 logic						Clk;
 logic						Reset;
 logic						Run;
 logic						ClearA_LoadB;

 logic[6:0]					AhexU;
 logic[6:0]					AhexL;
 logic[6:0]					BhexU;
 logic[6:0]					BhexL;
 logic[7:0]					Aval;
 logic[7:0]					Bval;
 logic						Xval;
// logic[4:0]					current_state;
// logic[4:0]					next_state;
// logic 						shift;


 always begin : CLOCK_GENERATION
 
 #1 Clk = ~Clk;
 
 end
 
 initial begin : CLOCK_INITIALIZATION
	Clk = 0;
 end

 lab5_adders_toplevel tp(.*);

 initial begin : TEST_VECTORS

 Reset = 0;
 Run = 1;
 ClearA_LoadB = 1;



 #2 Reset = 1;

 #2 SW = 8'h03;
    ClearA_LoadB = 0;

 #6 ClearA_LoadB = 1;
 #2 SW = 8'hFD;           // don't push switch between multiplication   

 #2 Run = 0;

 #5 Run = 1;
 
 #40 SW = 8'h03;     
 #2 Run = 0;
 #3 Run = 1;
 
 
 end

 endmodule

