/************************************************************************
Avalon-MM Interface for AES Decryption IP Core

Dong Kai Wang, Fall 2017

For use with ECE 385 Experiment 9
University of Illinois ECE Department

Register Map:

 0-3 : 4x 32bit AES Key
 4-7 : 4x 32bit AES Encrypted Message
 8-11: 4x 32bit AES Decrypted Message
   12: Not Used
	13: Not Used
   14: 32bit Start Register
   15: 32bit Done Register

************************************************************************/

module avalon_aes_interface (
	// Avalon Clock Input
	input logic CLK,
	
	// Avalon Reset Input
	input logic RESET,
	
	// Avalon-MM Slave Signals
	input  logic AVL_READ,					// Avalon-MM Read
	input  logic AVL_WRITE,					// Avalon-MM Write
	input  logic AVL_CS,						// Avalon-MM Chip Select
	input  logic [3:0] AVL_BYTE_EN,		// Avalon-MM Byte Enable
	input  logic [3:0] AVL_ADDR,			// Avalon-MM Address
	input  logic [31:0] AVL_WRITEDATA,	// Avalon-MM Write Data
	output logic [31:0] AVL_READDATA,	// Avalon-MM Read Data
	
	// Exported Conduit
	output logic [31:0] EXPORT_DATA		// Exported Conduit Signal to LEDs
);
	
	logic [127:0] temp_dec;
	logic temp_done;
	logic [31:0] reg_file [16];
	
	always_ff @ (posedge CLK) begin
	
	{reg_file[8], reg_file[9], reg_file[10], reg_file[11]} <= temp_dec;
	reg_file[15][0] <= temp_done;
	
	if(RESET == 1) begin                                                       // reset
	
		for (int i = 0; i< 8; i++)
			reg_file [i] <= 32'h00000000;
			
		for (int i = 12; i< 15; i++)
			reg_file [i] <= 32'h00000000;
			
	end
	
	else if (AVL_WRITE == 1 && AVL_CS == 1 && AVL_ADDR != 4'b1000 && AVL_ADDR !=4'b1001 && AVL_ADDR !=4'b1010 && AVL_ADDR !=4'b1011 && AVL_ADDR !=4'b1111 ) begin										//write
		
		if(AVL_BYTE_EN[0] == 1'b1)
			reg_file[AVL_ADDR][7:0] <= AVL_WRITEDATA[7:0];
		else
			reg_file[AVL_ADDR][7:0] <= 8'h00;
			
		if(AVL_BYTE_EN[1] == 1'b1)
			reg_file[AVL_ADDR][15:8] <= AVL_WRITEDATA[15:8];
		else 
			reg_file[AVL_ADDR][15:8] <= 8'h00;
			
		if(AVL_BYTE_EN[2] == 1'b1)
			reg_file[AVL_ADDR][23:16] <= AVL_WRITEDATA[23:16];
		else 
			reg_file[AVL_ADDR][23:16] <= 8'h00;
		
		if(AVL_BYTE_EN[3] == 1'b1)
			reg_file[AVL_ADDR][31:24] <= AVL_WRITEDATA[31:24];
		else
			reg_file[AVL_ADDR][31:24] <= 8'h00;
	end


	
	else begin 

		for (int i = 0; i< 15; i++)
			reg_file [i] <= reg_file[i];
	
	end
	
   end

	assign AVL_READDATA= (AVL_READ == 1 && AVL_CS == 1) ? reg_file[AVL_ADDR]: 16'h00000000;  // read
	assign EXPORT_DATA={reg_file[0][31:16],reg_file[3][15:0]};
	
//	AES aes_core(.CLK(CLK), .RESET(RESET), .AES_START(reg_file[14][0]), .AES_DONE(reg_file[15][0]),
//	.AES_KEY({reg_file[3],reg_file[2],reg_file[1],reg_file[0]}), .AES_MSG_ENC({reg_file[7],reg_file[6],reg_file[5],reg_file[4]}), 
//	.AES_MSG_DEC({reg_file[11], reg_file[10], reg_file[9], reg_file[8]}));

	AES aes_core(.CLK(CLK), .RESET(RESET), .AES_START(reg_file[14][0]), .AES_DONE(temp_done),
	.AES_KEY({reg_file[0],reg_file[1],reg_file[2],reg_file[3]}), .AES_MSG_ENC({reg_file[4],reg_file[5],reg_file[6],reg_file[7]}), 
	.AES_MSG_DEC(temp_dec));
	

endmodule
