//module datapath(
//input   logic Clk,
//input   logic BEN,
//input   logic Reset_ah, Continue_ah, Run_ah,
//input   logic LD_MAR, LD_MDR, LD_IR, LD_BEN, LD_CC, LD_REG, LD_PC, LD_LED,
//input   logic GatePC, GateMDR, GateALU, GateMARMUX,
//input   logic [1:0] PCMUX, ADDR2MUX, ALUK,
//input   logic DRMUX, SR1MUX, SR2MUX, ADDR1MUX,
//input   logic MIO_EN,
//input   logic [15:0] ALU_IR, ALU,
//input   logic [15:0] MDR_In,
//input   logic [15:0] MAR, MDR, IR, PC,
//input   logic [15:0] Data_from_SRAM, Data_to_SRAM,
//
//output   logic BEN_buffer,
//output   logic Reset_ah_buffer, Continue_ah_buffer, Run_ah_buffer,
//output   logic LD_MAR_buffer, LD_MDR_buffer, LD_IR_buffer, LD_BEN_buffer, LD_CC_buffer, LD_REG_buffer, LD_PC_buffer, LD_LED_buffer,
//output   logic GatePC_buffer, GateMDR_buffer, GateALU_buffer, GateMARMUX_buffer,
//output   logic [1:0] PCMUX_buffer, ADDR2MUX_buffer, ALUK_buffer,
//output   logic DRMUX_buffer, SR1MUX_buffer, SR2MUX_buffer, ADDR1MUX_buffer,
//output   logic MIO_EN_buffer,
//output   logic [15:0] ALU_IR_buffer, ALU_buffer,
//output   logic [15:0] MDR_In_buffer,
//output   logic [15:0] MAR_buffer, MDR_buffer, IR_buffer, PC_buffer,
//output   logic [15:0] Data_from_SRAM_buffer, Data_to_SRAM_buffer
//);
//
//logic [15:0] databus;
//
//// for registers
//always_ff @ (posedge Clk) begin
//
//if (LD_MAR)
//	MAR_buffer <= databus;
//	
//if (LD_MDR) begin
//	if(MIO_EN)
//		MDR_buffer <= MDR_In;		
//	else
//		MDR_buffer <= databus;
//	end 
//
//if (LD_IR)
//	IR_buffer <= databus;
//	
//if (LD_PC) begin
//	if (PCMUX ==2'b00)
//		PC_buffer <= PC + 1;
//	else if (PCMUX == 2'b01)
//		PC_buffer <= ALU_IR;
//	else if (PCMUX == 2'b10)
//		PC_buffer <= databus; 
//	else 
//		$display("PCMUX cannot be 11");
//	end
//
//end
//
//// part for databus
//always_comb begin
//
//if(GatePC == 1 && GateMDR == 0 && GateALU == 0 && GateMARMUX == 0)
//	databus = PC;
//else if (GatePC == 0 && GateMDR == 1 && GateALU == 0 && GateMARMUX == 0)
//	databus = MDR;
//else if (GatePC == 0 && GateMDR == 0 && GateALU == 1 && GateMARMUX == 0)
//	databus = ALU;  
//else if (GatePC == 0 && GateMDR == 0 && GateALU == 0 && GateMARMUX == 1)
//	databus = ALU_IR; 
//else
//	databus = 16'hxxxx;
//	
//end 
//
////part for lower part
//
//
//
//endmodule 