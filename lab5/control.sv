module control ( input logic Clk, Reset, Run, ClearA_LoadB, M_in, output logic LoadA, LoadB, LoadX, ClearA, ClearB, ClearX, Shift, Add, Subtract, 
output logic [4:0] current_state_value, next_state_value);

enum logic [4:0] {A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, ClearXA} current_state,next_state;

// A for start-up, B for clearXA, C,D,E,F,G,H,I for first 7 shift and add, J for the last shift and add, K for the hold state 

assign current_state_value=current_state; 
assign next_state_value=next_state;

always_ff @ (posedge Clk) begin  

if (Reset==1)
	current_state <= A; 
else
	current_state <= next_state;
	
end

always_comb begin 

unique case (current_state)
	A:
		if (ClearA_LoadB == 1 & Reset == 0)
			next_state = B;
		else 
			next_state = A;

	B:
		if (Run ==1)
			next_state = C;
		else 
			next_state = B;
			
	ClearXA:	
		next_state=C;
	C:
		next_state=D;
	D:
		next_state=E;
	E:
		next_state=F;
	F: 
		next_state=G;
	G:
		next_state=H;
	H:
		next_state=I;
	I:
		next_state=J;	
	J: 
		next_state=K;
		
	K:
		next_state=L;	
	L:
		next_state=M;
	M:
		next_state=N;
	N:
		next_state=O;
	O:
		next_state=P;
	P:
		next_state=Q;
	Q:
		next_state=R;
	R:
		next_state=S;
			
	S:
		if(Run == 0)         //buffer state
			next_state= T;
		
		else 
			next_state= S; 
		
	T:
		if (Run == 1 )
			next_state = ClearXA;
		else 
			next_state = T;
		
	endcase
	
case(current_state) 
	A:										//reset
		begin
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 1;
		ClearB= 1;
		ClearX= 1;
		Shift = 0;
		Add   = 0;
		Subtract=0;
		end
	B:										//clearA_LoadB
		begin
		LoadA = 0;       
		LoadB = 1'b1 & ClearA_LoadB;		  
		LoadX = 0;
		ClearA= 1'b1 & ClearA_LoadB;
		ClearB= 0;
		ClearX= 1'b1 & ClearA_LoadB;
		Shift = 0;
		Add   = 0;
		Subtract=0;
		end
				
		
	D:										//move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end
	
	F:										//move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end		

		
	H:										//move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end		
		
	J:									   //move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end		

	L:									   //move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end	

	N:									   //move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end	
		
	P:									   //move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end	
		
	R:									   //move
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 1;
		Add   = 0;
		Subtract=0;
		end	
		
	Q:                            //subtract
		begin
		
		if(M_in==1) begin 
		LoadA = 1;       
		LoadB = 0;		  
		LoadX = 1;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 0;
		Add   = 0;
		Subtract=1;
		end
		
		else begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 0;
		Add   = 0;
		Subtract=0;
		end
		
		end
	S:
		begin
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 0;
		Add   = 0;
		Subtract=0;
		end
		
	T:
		begin
		LoadA = 0;       
		LoadB = 1'b1 & ClearA_LoadB;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 0;
		Add   = 0;
		Subtract=0;
		end	
		
ClearXA:
		begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 1;
		ClearB= 0;
		ClearX= 1;
		Shift = 0;
		Add   = 0;
		Subtract=0;
		end
		
	default: 
		
		if(M_in==1)begin
		LoadA = 1;       
		LoadB = 0;		  
		LoadX = 1;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 0;
		Add   = 1;
		Subtract=0;
		end
		
		else begin 
		LoadA = 0;       
		LoadB = 0;		  
		LoadX = 0;
		ClearA= 0;
		ClearB= 0;
		ClearX= 0;
		Shift = 0;
		Add   = 0;
		Subtract=0;
		end	
		
	endcase

end 

endmodule
