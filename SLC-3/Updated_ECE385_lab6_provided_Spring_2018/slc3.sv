//------------------------------------------------------------------------------
// Company:        UIUC ECE Dept.
// Engineer:       Stephen Kempf
//
// Create Date:    
// Design Name:    ECE 385 Lab 6 Given Code - SLC-3 
// Module Name:    SLC3
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 09-22-2015 
//    Revised 10-19-2017 
//    spring 2018 Distribution
//
//------------------------------------------------------------------------------
module slc3(
    input logic [15:0] S,
    input logic Clk, Reset, Run, Continue,
    output logic [15:0] LED,
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
    output logic CE, UB, LB, OE, WE,
    output logic [19:0] ADDR,
    inout wire [15:0] Data, //tristate buffers need to be of type wire
	 output logic [15:0] IR_show, PC_show,
	 output logic [10:0] state_show, next_state_show,
	 output logic [15:0] MAR_show, MDR_show
);

// Declaration of push button active high signals
logic Reset_ah, Continue_ah, Run_ah;

// sync buttons
always_ff @ (posedge Clk) begin

Reset_ah = ~Reset;
Continue_ah = ~Continue;
Run_ah = ~Run;

end

// Internal connections
//logic LD_LED;
logic BEN, BEN_buffer;
logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC;
logic GatePC, GateMDR, GateALU, GateMARMUX;
logic [1:0] PCMUX, ADDR2MUX, ALUK;
logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX;
logic MIO_EN;
logic [15:0] ALU, ALU_IR, ALU_A, ALU_B,ALU_IR_two,ALU_IR_one,ALU_0,ALU_1,ALU_2;
logic [2:0]NZP, NZP_buffer, reg_temp_dest;

logic [15:0] MDR_In;
logic [15:0] MAR, MDR, IR, PC, MDR_buffer, PC_buffer;
logic [15:0] Data_from_SRAM, Data_to_SRAM;

// Signals being displayed on hex display
logic [3:0][3:0] hex_4;

assign LED=IR[15:0];
assign IR_show=IR;
assign PC_show=PC;
assign MAR_show =MAR;
assign MDR_show=MDR;
assign ALU_IR=ALU_IR_one+ALU_IR_two;

// For week 1, hexdrivers will display IR. Comment out these in week 2.
//HexDriver hex_driver3 (IR[15:12], HEX3);
//HexDriver hex_driver2 (IR[11:8], HEX2);
//HexDriver hex_driver1 (IR[7:4], HEX1);
//HexDriver hex_driver0 (IR[3:0], HEX0);

// For week 2, hexdrivers will be mounted to Mem2IO
 HexDriver hex_driver3 (hex_4[3][3:0], HEX3);
 HexDriver hex_driver2 (hex_4[2][3:0], HEX2);
 HexDriver hex_driver1 (hex_4[1][3:0], HEX1);
 HexDriver hex_driver0 (hex_4[0][3:0], HEX0);

// The other hex display will show PC for both weeks.
HexDriver hex_driver7 (PC[15:12], HEX7);
HexDriver hex_driver6 (PC[11:8], HEX6);
HexDriver hex_driver5 (PC[7:4], HEX5);
HexDriver hex_driver4 (PC[3:0], HEX4);

// Connect MAR to ADDR, which is also connected as an input into MEM2IO.
// MEM2IO will determine what gets put onto Data_CPU (which serves as a potential
// input into MDR)
assign ADDR = { 4'b00, MAR }; //Note, our external SRAM chip is 1Mx16, but address space is only 64Kx16
assign MIO_EN = ~OE;
// You need to make your own datapath module and connect everything to the datapath
// Be careful about whether Reset is active high or low

//datapath d0 (.*,.Clk(Clk));

logic [15:0] databus;
logic [15:0] reg_file [7:0];

// part for reset everthing t0 0

//always_comb begin 
//if (Reset_ah)
//	PC=0;//         
//	IR=0;//
//	ALU=0;
//	ALU_IR=0;
//	ALU_A=0;
//	ALU_B=0;
//	ALU_IR_two=0;
//	ALU_IR_one=0;
//	NZP=0;//
//	MDR_In=0;
//	MAR=0;//
//	MDR=0;//
//	IR=0;//
//	PC=0;//
//	Data_from_SRAM=0;
//	Data_to_SRAM=0;
//	ALU_0=0;
//	ALU_1=0;
//	ALU_2=0;
// BEN=0;//
//Reg_file=0;//
//end

// part for load_registers
always_ff @(posedge Clk) begin
	
if (LD_MAR == 1 && Reset_ah ==0)
	MAR <= databus;
else if(LD_MAR == 0 && Reset_ah == 0)
	MAR <= MAR;
else 
	MAR <= 16'h0000;
	
	
if (LD_MDR==1 && Reset_ah == 0)
		MDR <= MDR_buffer;
		
else if (LD_MDR==0 && Reset_ah == 0)
		MDR <= MDR;
else
		MDR <= 16'h0000;



if (LD_IR == 1 && Reset_ah == 0)
	IR <= databus;
else if (LD_IR == 0 && Reset_ah == 0)
	IR <= IR;
else 
	IR <= 16'h0000;
	
	
	
if (LD_PC == 1 && Reset_ah == 0) 
	PC <= PC_buffer;
	
else if(LD_PC == 0 && Reset_ah ==0) 
	PC <= PC;
else 
	PC <= 16'h0000;
	


	
if (LD_BEN == 1 && Reset_ah ==0) 
	BEN <= BEN_buffer;
else if (LD_BEN == 0 && Reset_ah ==0)
	BEN <= BEN;
else 
	BEN <= 1'h0;



if (LD_REG == 1 && Reset_ah ==0) 
	reg_file[reg_temp_dest]<=databus;		

else if(LD_REG == 0 && Reset_ah == 0) begin
	reg_file[3'b000]<= reg_file[3'b000];
	reg_file[3'b001]<= reg_file[3'b001];
	reg_file[3'b010]<= reg_file[3'b010];
	reg_file[3'b011]<= reg_file[3'b011];
	reg_file[3'b100]<= reg_file[3'b100];
	reg_file[3'b101]<= reg_file[3'b101];
	reg_file[3'b110]<= reg_file[3'b110];
	reg_file[3'b111]<= reg_file[3'b111];
	
	end 

else begin
	reg_file[3'b000]<= 16'h0000;
	reg_file[3'b001]<= 16'h0000;
	reg_file[3'b010]<= 16'h0000;
	reg_file[3'b011]<= 16'h0000;
	reg_file[3'b100]<= 16'h0000;
	reg_file[3'b101]<= 16'h0000;
	reg_file[3'b110]<= 16'h0000;
	reg_file[3'b111]<= 16'h0000;
end
	
if (LD_CC == 1 && Reset_ah == 0) 
	NZP<=NZP_buffer;

else if(LD_CC == 0 && Reset_ah == 0) 
	NZP<=NZP;
	
else 
	NZP<=3'b000;
	
	
end

// part for databus
always_comb begin

if(GatePC == 1 && GateMDR == 0 && GateALU == 0 && GateMARMUX == 0)
	databus = PC;
else if (GatePC == 0 && GateMDR == 1 && GateALU == 0 && GateMARMUX == 0)
	databus = MDR;
else if (GatePC == 0 && GateMDR == 0 && GateALU == 1 && GateMARMUX == 0)
	databus = ALU;  
else if (GatePC == 0 && GateMDR == 0 && GateALU == 0 && GateMARMUX == 1)
	databus = ALU_IR; 
else
	databus = 16'hxxxx;
	
end 


// part for mux
always_comb begin 

ALU_0 = ALU_A + ALU_B;
ALU_1 = ALU_A & ALU_B;
ALU_2 = ~ALU_A;
BEN_buffer=IR[11] & NZP[2] | IR[10] & NZP[1] | IR[9] & NZP[0];

if(MIO_EN == 1)
	MDR_buffer = MDR_In;		
else
	MDR_buffer = databus;
	
if (PCMUX ==2'b00)
	PC_buffer = PC + 16'h0001;
else if (PCMUX == 2'b01)
	PC_buffer = ALU_IR;
else                                 // only could be 2
	PC_buffer = databus; 
		
if(DRMUX == 0)
	reg_temp_dest=IR[11:9] ;
else
	reg_temp_dest=3'b111;
		
if ( reg_file[reg_temp_dest] == 16'h0000)                  //zero
	NZP_buffer=3'b010;
else if ( reg_file[reg_temp_dest][15] ==1)					  // negative
	NZP_buffer=3'b100;
else 																		 // positive
	NZP_buffer=3'b001;
	
		
if (SR1MUX == 0 )
	ALU_A = reg_file[IR[8:6]];
else
	ALU_A = reg_file[IR[11:9]];
	
if (SR2MUX == 0)
	ALU_B = reg_file[IR[2:0]];
else
	ALU_B = {{11{IR[4]}},IR[4:0]};
	
	
if (ALUK == 0)                             // for add instructino
	ALU=ALU_0;
else if (ALUK ==1)								 // for and instruction
	ALU=ALU_1;
else 													// for not instruction
	ALU=ALU_2;

	
if (ADDR2MUX == 0)								// make it 0
	ALU_IR_two = 16'h0000;	
else if (ADDR2MUX == 1)							// IR[5:0]
	ALU_IR_two = {{10{IR[5]}},IR[5:0]};   
else if (ADDR2MUX == 2)							// IR[8:0]
	ALU_IR_two = {{7{IR[8]}},IR[8:0]};	  
else 													// IR[10:0]
	ALU_IR_two = {{5{IR[10]}},IR[10:0]};  
	
	
if(ADDR1MUX == 0)									// PC								
	ALU_IR_one = PC;
else 													// SR1
	ALU_IR_one= ALU_A;

	
end



// Our SRAM and I/O controller
Mem2IO memory_subsystem(
    .*, .Reset(Reset_ah), .ADDR(ADDR), .Switches(S),
    .HEX0(hex_4[0][3:0]), .HEX1(hex_4[1][3:0]), .HEX2(hex_4[2][3:0]), .HEX3(hex_4[3][3:0]),
    .Data_from_CPU(MDR), .Data_to_CPU(MDR_In),
    .Data_from_SRAM(Data_from_SRAM), .Data_to_SRAM(Data_to_SRAM)
);

// The tri-state buffer serves as the interface between Mem2IO and SRAM
tristate #(.N(16)) tr0(
    .Clk(Clk), .tristate_output_enable(~WE), .Data_write(Data_to_SRAM), .Data_read(Data_from_SRAM), .Data(Data)
);

// State machine and control signals
ISDU state_controller(
    .*, .Reset(Reset_ah), .Run(Run_ah), .Continue(Continue_ah),
    .Opcode(IR[15:12]), .IR_5(IR[5]), .IR_11(IR[11]),
    .Mem_CE(CE), .Mem_UB(UB), .Mem_LB(LB), .Mem_OE(OE), .Mem_WE(WE)
);

endmodule
