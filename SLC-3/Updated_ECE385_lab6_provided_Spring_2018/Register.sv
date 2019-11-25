//module register(input logic Clk, Reset, Enable,
//			 input logic [15:0] Data_in,
//			 output logic [15:0] Data_out);
//			 
//			 always_ff @ (posedge Clk)
//			 begin
//				if (!Enable)                              // enable is active high
//					Data_out <= 16'hxxxx;
//				else 
//					if(Reset)                                // reset is active high
//					Data_out <= 16'h0000;
//					
//					else
//					Data_out <= Data_in;
//							
//			 end
//			 
//endmodule 