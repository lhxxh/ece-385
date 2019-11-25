module ripple_adder_and_subtractor(   
	 input   logic[7:0]     A,
    input   logic[7:0]     SW,
	 input   logic          Addsignal,
	 input   logic 			Subsignal,
    output  logic[8:0]     Sum_Add,Sum_Sub);

	 
	logic [8:0] A_Ninebit_Add, SW_Ninebit_Add;
	logic [8:0] A_Ninebit_Sub, SW_Ninebit_Sub;
	logic CO_Add, CO_Subone,CO_Subtwo;  // CO_ADD and CO_Sub are useless
	logic [8:0] Inverting_Sum;
	
	 always_comb begin    //  adder part
	 
	 if (Addsignal==1) begin
			A_Ninebit_Add = {A[7],A[7:0]};
	      SW_Ninebit_Add = {SW[7],SW[7:0]};
		end
		
	 else begin
			A_Ninebit_Add = 9'b000000000;
			SW_Ninebit_Add = 9'b000000000;        // discard condition
		end
		
	 end
	  
	 ripple_adder_incomplete addresult( .A(A_Ninebit_Add) , .B(SW_Ninebit_Add) , .Sum(Sum_Add) , .CO(CO_Add));
	 
	 
	always_comb begin    // subtractor part
	
	if (Subsignal==1) begin
			A_Ninebit_Sub = {A[7],A[7:0]};
	      SW_Ninebit_Sub = {SW[7],SW[7:0]};
			SW_Ninebit_Sub = ~SW_Ninebit_Sub;
		end
	
	else begin
			A_Ninebit_Sub = 9'b000000000;
			SW_Ninebit_Sub = 9'b000000000;			//discard condition
		end

	end
	ripple_adder_incomplete inverting( .A(SW_Ninebit_Sub), .B(9'b000000001), .Sum(Inverting_Sum), .CO(CO_Subone));
	ripple_adder_incomplete getnegative(.A(Inverting_Sum), .B(A_Ninebit_Sub), .Sum(Sum_Sub), .CO(CO_Subtwo));

	
endmodule



module ripple_adder_incomplete
(
    input   logic[8:0]     A,
    input   logic[8:0]     B,
    output  logic[8:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a ripple adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */

	  logic C0, C1;
	  
	  four_bit_ra FRA0(.x(A[3:0]), .y(B[3:0]), .cin(1'b0), .s(Sum[3:0]), .cout(C0));
	  four_bit_ra FRA1(.x(A[7:4]), .y(B[7:4]), .cin(C0), .s(Sum[7:4]), .cout(C1));
	  full_adder msb  (.x(A[8])  , .y(B[8])  , .cin(C1), .s(Sum[8]) , .cout(CO));
     
endmodule



module four_bit_ra(
			input [3:0] x,
			input [3:0] y,
			input cin,
			output logic [3:0] s,
			output logic cout
);

	logic c0, c1, c2;
	
	full_adder fa0(.x(x[0]), .y(y[0]), .cin(cin), .s(s[0]), .cout(c0));
	full_adder fa1(.x(x[1]), .y(y[1]), .cin(c0), .s(s[1]), .cout(c1));
	full_adder fa2(.x(x[2]), .y(y[2]), .cin(c1), .s(s[2]), .cout(c2));
	full_adder fa3(.x(x[3]), .y(y[3]), .cin(c2), .s(s[3]), .cout(cout));
	
endmodule


module full_adder
(
	 input   x,
	 input	y,
	 input	cin,
	 output	logic s,
	 output	logic cout
);
	assign s = x ^ y ^ cin;
	assign cout = (x & y) | (x & cin) | (y & cin);

endmodule 