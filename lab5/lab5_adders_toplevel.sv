module lab5_adders_toplevel(
    input   logic           Clk,        // 50MHz clock is only used to get timing estimate data
    input   logic           Reset,      // From push-button 0.  Remember the button is active low (0 when pressed)
    input   logic           ClearA_LoadB,      // From push-button 1
    input   logic           Run,        // From push-button 3.
    input   logic[7:0]      SW,         // From slider switches
    
    // all outputs are registered
	 output logic[7:0]   Aval,Bval,
	 output logic        Xval,
    output logic[6:0]   AhexL,
                        AhexU,
                        BhexL,
                        BhexU
//	 output logic [4:0]  current_state,
//							   next_state,
//	 output logic 			shift
	 );
	 
	 logic Reset_SH, Run_SH, ClearA_LoadB_SH;                                                           // input synchronization
	 logic LoadX, LoadA, LoadB, ClearA, ClearB, ClearX, Shift, Addsignal, Subsignal, CO;	        					 // internal signal, CO is useless
	 logic X, A_Shift_Out, B_Shift_Out, X_Shift_Out;                                                                                          
	 logic [8:0] Sum_Add, Sum_Sub, Sum;
	 logic [7:0] A,B;
	 logic [4:0] current_state,next_state;
    logic 		 shift;
	 
	 //We can use the "assign" statement to do simple combinational logic
	 assign Aval = A;
	 assign Bval = B;
	 assign Xval = X;
	 assign shift=Shift;

	 control control_unit( .Clk(Clk), .Reset(Reset_SH), .Run(Run_SH), .ClearA_LoadB(ClearA_LoadB_SH), .M_in(B_Shift_Out), .LoadA(LoadA), .LoadB(LoadB),
	 .LoadX(LoadX), .ClearA(ClearA), .ClearB(ClearB), .ClearX(ClearX), .Shift(Shift), .Add(Addsignal), .Subtract(Subsignal),
	 .current_state_value(current_state), .next_state_value(next_state));	 
	 
	 ripple_adder_and_subtractor eachaddition( .A(A) , .SW(SW), .Addsignal(Addsignal) , .Subsignal(Subsignal) , .Sum_Add(Sum_Add) , .Sum_Sub(Sum_Sub));  //CO is useless
	 
	 always_comb begin
	 
	 if (Addsignal == 1) 
		Sum = Sum_Add;
	 else if (Subsignal == 1)
		Sum = Sum_Sub;
	 else 
		Sum = 9'b000000000;
	 
	 end 
	 
	 register_8 Areg( .Clk(Clk), .Reset(ClearA), .Shift_In(X_Shift_Out), .Load(LoadA), .Shift_En(Shift), .D(Sum[7:0]) , .Shift_Out(A_Shift_Out) , .Data_Out(A));
	 register_8 Breg( .Clk(Clk), .Reset(ClearB), .Shift_In(A_Shift_Out), .Load(LoadB), .Shift_En(Shift), .D(SW[7:0]) , .Shift_Out(B_Shift_Out) , .Data_Out(B));
	 register_1 Xreg( .Clk(Clk), .Reset(ClearX), .Load(LoadX), .Shift_En(Shift), .D(Sum[8]), .Shift_Out(X_Shift_Out), .Data_Out(X));
	 
	 sync hex_sync [2:0](Clk, {~Reset, ~Run, ~ClearA_LoadB}, {Reset_SH, Run_SH, ClearA_LoadB_SH});
	 
	 HexDriver        HexAL (
                        .In0(Aval[3:0]),
                        .Out0(AhexL) );
	 HexDriver        HexBL (
                        .In0(Bval[3:0]),
                        .Out0(BhexL) );
								
	 HexDriver        HexAU (
                        .In0(Aval[7:4]),
                        .Out0(AhexU) );	
	 HexDriver        HexBU (
                       .In0(Bval[7:4]),
                        .Out0(BhexU) );
	 
endmodule 
