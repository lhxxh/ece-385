//------------------------------------------------------------------------------
// Company:          UIUC ECE Dept.
// Engineer:         Stephen Kempf
//
// Create Date:    17:44:03 10/08/06
// Design Name:    ECE 385 Lab 6 Given Code - Incomplete ISDU
// Module Name:    ISDU - Behavioral
//
// Comments:
//    Revised 03-22-2007
//    Spring 2007 Distribution
//    Revised 07-26-2013
//    Spring 2015 Distribution
//    Revised 02-13-2017
//    Spring 2017 Distribution
//------------------------------------------------------------------------------


module ISDU (   input logic         Clk, 
									Reset,
									Run,
									Continue,
									
				input logic[3:0]    Opcode, 
				input logic         IR_5,
				input logic         IR_11,
				input logic         BEN,
				  
				output logic        LD_MAR,
									LD_MDR,
									LD_IR,
									LD_BEN,
									LD_CC,
									LD_REG,
									LD_PC,
//									LD_LED, // for PAUSE instruction
									
				output logic        GatePC,
									GateMDR,
									GateALU,
									GateMARMUX,
									
				output logic [1:0]  PCMUX,
				output logic        DRMUX,
									SR1MUX,
									SR2MUX,
									ADDR1MUX,
				output logic [1:0]  ADDR2MUX,
									ALUK,
				  
				output logic        Mem_CE,
									Mem_UB,
									Mem_LB,
									Mem_OE,
									Mem_WE,
				output logic [10:0] state_show, next_state_show
				);

	enum logic [10:0] {  Halted=11'd100, 
						PauseIR1=11'd101, 
						PauseIR2=11'd102, 
						S_18=11'd18, 
						S_33_1=11'd331, 
						S_33_2=11'd332,
						S_33_3=11'd333,
						S_35=11'd35, 
						S_32=11'd32, 
						S_01=11'd1,
						S_05=11'd5,
						S_09=11'd9,
						S_00=11'd0,
						S_22=11'd22,
						S_06=11'd6,
						S_25_1=11'd251,
						S_25_2=11'd252,
						S_25_3=11'd253,
						S_27=11'd27,			
						S_07=11'd7,
						S_23=11'd23,
						S_16_1=11'd161,
						S_16_2=11'd162,
						S_16_3=11'd163,
						S_04=11'd4,
						S_21=11'd21,
						S_12=11'd12,
						S_set_cc=11'd88
//						S_01_1=11'd11,
//						S_05_1=11'd51,
//						S_09_1=11'd91
						
//						S_check_1=11'd501,
//						S_check_2=11'd502
												}   State, Next_state;   // Internal state logic
	
//	logic Ben_buffer;
//	
//	assign Ben = Ben_buffer;					
	assign state_show=State;
	assign next_state_show=Next_state;
		
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else 
			State <= Next_state;
	end
   
	always_comb
	begin 
		// Default next state is staying at current state
		Next_state = State;
		
		// Default controls signal values
		LD_MAR = 1'b0;
		LD_MDR = 1'b0;
		LD_IR = 1'b0;
		LD_BEN = 1'b0;
		LD_CC = 1'b0;
		LD_REG = 1'b0;
		LD_PC = 1'b0;
//		LD_LED = 1'b0;
		 
		GatePC = 1'b0;
		GateMDR = 1'b0;
		GateALU = 1'b0;
		GateMARMUX = 1'b0;
		 
		ALUK = 2'b00;
		 
		PCMUX = 2'b00;
		DRMUX = 1'b0;
		SR1MUX = 1'b0;
		SR2MUX = 1'b0;
		ADDR1MUX = 1'b0;
		ADDR2MUX = 2'b00;
		 
		Mem_OE = 1'b1;
		Mem_WE = 1'b1;
	
		// Assign next state
		unique case (State)
			Halted : 
				if (Run == 1 && Reset== 0) 
					Next_state = S_18;
			S_18 : 
				Next_state = S_33_1;					
//			S_18 : 
//				Next_state = S_check_1;
				
//			S_check_1 : 
//				if (~Continue) 
//					Next_state = S_check_1;
//				else 
//					Next_state = S_check_2;
//			S_check_2 : 
//				if (Continue) 
//					Next_state = S_check_2;
//				else 
//					Next_state = S_32;
			// Any states involving SRAM require more than one clock cycles.
			// The exact number will be discussed in lecture.
			S_33_1 : 
				Next_state = S_33_3;
			S_33_3:
				Next_state = S_33_2;      // for memory have enough time to load
			S_33_2 : 
				Next_state = S_35;
			S_35 : 
				Next_state = S_32;        // been modified since week 1 pass
			// PauseIR1 and PauseIR2 are only for Week 1 such that TAs can see 
			// the values in IR.
			PauseIR1 : 
				if (~Continue) 
					Next_state = PauseIR1;
				else 
					Next_state = PauseIR2;
			PauseIR2 : 
				if (Continue) 
					Next_state = PauseIR2;
				else 
					Next_state = S_18;
			S_32 : 
				case (Opcode)
					4'b0001 : 
						Next_state = S_01;

					4'b0101 :
						Next_state = S_05;
					
					4'b1001 :
						Next_state = S_09;
						
					4'b0000 :
						Next_state = S_00;
						
					4'b0110 :
						Next_state = S_06;
						
					4'b0111 :
						Next_state = S_07;
					
					4'b0100 :
						Next_state = S_04;
						
					4'b1100:
						Next_state = S_12;
						
					4'b1101:
						Next_state = PauseIR1;
						
					default : 
						Next_state = S_18;
				endcase
//			S_01 : 
//				Next_state = S_01_1;
//
//			S_05 :
//				Next_state = S_05_1;
//				
//			S_09:
//				Next_state = S_09_1;
//				
//			S_01_1:
//				Next_state = S_18;
//			
//			S_05_1:
//				Next_state = S_18;
//				
//			S_09_1:
//				Next_state = S_18;
			S_01 : 
				Next_state = S_set_cc;

			S_05 :
				Next_state = S_set_cc;
			
			S_09:
				Next_state = S_set_cc;
				
			S_set_cc:
				Next_state = S_18;
				
			S_00:
				if(BEN)
					Next_state = S_22;
				else
					Next_state= S_18;
					
			S_06:
				Next_state = S_25_1;
				
			S_25_1:
				Next_state = S_25_2;
				
			S_25_2:
				Next_state = S_25_3;
				
			S_25_3:
				Next_state = S_27;
					
			S_22:
				Next_state = S_18;
			
			S_27:
				Next_state = S_set_cc; 
			
			S_07:
				Next_state = S_23;
			
			S_23:
				Next_state = S_16_1;
				
			S_16_1:
				Next_state = S_16_2;
				
			S_16_2:
				Next_state = S_16_3;
				
			S_16_3:
				Next_state = S_18;
				
			S_04:
				Next_state = S_21;
				
			S_21:
				Next_state =S_18;
				
			S_12:
				Next_state =S_18;

		endcase
		
		// Assign control signals based on current state
		unique case (State)
			Halted: ;
			S_18 : 
				begin 
					GatePC = 1'b1;
					LD_MAR = 1'b1;
					PCMUX = 2'b00;
					LD_PC = 1'b1;
				end
			S_33_1 : 
				Mem_OE = 1'b0;
			S_33_2 : 
				begin 
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
			S_33_3 :									// for memory has enough time to load
				Mem_OE = 1'b0;
			S_35 : 
				begin 
					GateMDR = 1'b1;
					LD_IR = 1'b1;
				end
			PauseIR1: ;
			PauseIR2: ;
//			S_check_1: ;
//			S_check_2: ;
			S_32 : 
				LD_BEN = 1'b1;	
			S_01 : 										// ADD
				begin 
					SR1MUX = 1'b0;					   // IR[8:6]
					SR2MUX = IR_5;
					ALUK = 2'b00;
					GateALU = 1'b1;
					DRMUX = 1'b0; 					  // IR[11:9]
					LD_REG = 1'b1;
				end

			S_05 :									  // AND
				begin
					SR1MUX = 1'b0;
					SR2MUX = IR_5;
					ALUK = 2'b01;
					GateALU=1'b1;
					DRMUX=1'b0;
					LD_REG=1'b1;
				end
		
			S_09:										 // not
				begin
					SR1MUX = 1'b0;
					ALUK = 2'b10;
					GateALU = 1'b1;
					DRMUX=1'b0;
					LD_REG=1'b1;
				end
			S_set_cc:
				begin
					LD_CC = 1'b1;
				end
			
			S_00:                            // judge state of branch (do nothing but judge)
				;
				
			S_22:																															// true state of branch  
				begin
				PCMUX=2'b01;                                                                               // try to invert two lines to confirm my guess 
				LD_PC=1'b1;
				ADDR1MUX=1'b0;
				ADDR2MUX=2'b10;	
				end
			S_06:
				begin
				SR1MUX=1'b0;
				ADDR1MUX=1'b1;
				ADDR2MUX=2'b01;
				GateMARMUX=1'b1;
				LD_MAR=1'b1;
				end
			S_25_1:
				Mem_OE = 1'b0;
			
			S_25_2:
				Mem_OE = 1'b0;
				
			S_25_3:
				begin 
					Mem_OE = 1'b0;
					LD_MDR = 1'b1;
				end
				
			S_27:
				begin 
					GateMDR = 1'b1;
					DRMUX= 1'b0;
					LD_REG = 1'b1;
				end
			
			S_07:
				begin
				SR1MUX=1'b0;
				ADDR1MUX=1'b1;
				ADDR2MUX=2'b01;
				GateMARMUX=1'b1;
				LD_MAR=1'b1;
				end
			S_23:
				begin
				SR1MUX=1'b1;
				ADDR1MUX=1'b1;
				ADDR2MUX=2'b00;
				GateMARMUX=1'b1;
				Mem_OE = 1'b1;
				LD_MDR = 1'b1;
				end
			S_16_1:
				Mem_WE=1'b0;
			
			S_16_2:
				Mem_WE=1'b0;
				
			S_16_3:
				Mem_WE=1'b0;
				
			S_04:
				begin
				GatePC=1'b1;
				DRMUX=1'b1 ;
				LD_REG=1'b1;
				end
			S_21:
				begin
				ADDR1MUX=1'b0;
				ADDR2MUX=2'b11;
				PCMUX=2'b01;
				LD_PC=1'b1;
				end
			S_12:
				begin
				SR1MUX=1'b0;
				ADDR1MUX=1'b1;
				ADDR2MUX=2'b00;
				PCMUX=2'b01;
				LD_PC=1'b1;
				end
//			S_01_1:
//				begin
//				SR1MUX = 1'b0;					   // IR[8:6]
//				SR2MUX = IR_5;
//				ALUK = 2'b00;
//				GateALU = 1'b1;
//				DRMUX = 1'b0; 					  // IR[11:9]
//				LD_REG = 1'b1;
//				LD_CC = 1'b1; 
//				end
//			S_05_1:
//				begin
//				SR1MUX = 1'b0;
//				SR2MUX = IR_5;
//				ALUK = 2'b01;
//				GateALU=1'b1;
//				DRMUX=1'b0;
//				LD_REG=1'b1;
//				LD_CC=1'b1;				
//				end
//			S_09_1:
//				begin
//				SR1MUX = 1'b0;
//				ALUK = 2'b10;
//				GateALU = 1'b1;
//				DRMUX=1'b0;
//				LD_REG=1'b1;
//				LD_CC=1'b1;
//				end
		endcase
	end 

	 // These should always be active
	assign Mem_CE = 1'b0;
	assign Mem_UB = 1'b0;
	assign Mem_LB = 1'b0;
	
endmodule