module register_8(input  logic Clk, Reset, Shift_In, Load, Shift_En,
              input  logic [7:0]  D,
              output logic Shift_Out,
              output logic [7:0]  Data_Out);

always_ff @(posedge Clk) begin 

if (Reset==1) 
	Data_Out <= 8'h00;
	
else if (Load==1)
	Data_Out <= D;
	
else if (Shift_En==1)
	Data_Out <= {Shift_In, Data_Out[7:1]};
	
else
	Data_Out <= Data_Out;
	
end
	
assign Shift_Out=Data_Out[0];



endmodule 


module register_1(input logic Clk,Reset,Load,Shift_En,
						input logic D,
						output logic Shift_Out, 
						output logic Data_Out);

always_ff @ (posedge Clk) begin 

if(Reset==1)
	Data_Out<=1'b0;
	
else if (Load==1)
	Data_Out<=D;
	
else if (Shift_En==1)
	Data_Out<=Data_Out;         // shift out is always its internal value
	
else
	Data_Out<=Data_Out;

end

assign Shift_Out=Data_Out;

endmodule
