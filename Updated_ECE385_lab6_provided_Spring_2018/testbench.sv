module testbench();

timeunit 10ns;

timeprecision 1ns;

	logic [15:0]	S;
	logic 			Clk;
	logic				Reset;
	logic				Run;
	logic				Continue;
	logic	[15:0]	LED;
	logic [6:0]		HEX0;
	logic [6:0]		HEX1;
	logic [6:0]		HEX2;
	logic [6:0]		HEX3;
	logic [6:0]		HEX4;
	logic [6:0]		HEX5;
	logic [6:0]		HEX6;
	logic [6:0]		HEX7;
	logic 			CE;
	logic 			UB;
	logic				LB;
	logic 			OE;
	logic 			WE;
	logic [19:0]	ADDR;
	wire [15:0]	Data;
	logic [15:0] IR_show, PC_show;
	logic [10:0] state_show, next_state_show;
	logic [15:0] MAR_show, MDR_show;
	
always begin : CLOCK_GENERATION
 
 #1 Clk = ~Clk;
 
 end
 
initial begin : CLOCK_INITIALIZATION
	
    Clk = 0;
	
 end
 
 lab6_toplevel tp(.*);
 
 initial begin : TEST_VECTORS
	Reset = 0;
	Run = 1;
	Continue=1;


	#2 Reset = 1;
		
	#2 S = 16'h0031;
		
	#2 Run = 0;
		
	
//	#15 Continue = 0;
//
//	#2 Continue = 1;
//		Run = 0;

	#80 S = 16'h0001;
	
	#80 Continue = 0;
	
	#5 Continue = 1;
	
	#30 S = 16'h0002;
	
	#50 Continue = 0;
	
	#5 Continue = 1;
	
	#3;
	 
	
	end

endmodule	