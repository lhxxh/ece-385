module carry_select_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a carry select.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
logic c0,c1,c2;

four_bit_ra one(.x(A[3:0]), .y(B[3:0]), .cin(0), .s(Sum[3:0]), .cout(c0));

onepart first (.a(A[7:4]), .b(B[7:4]), .select(c0), .sum(Sum[7:4]), .cout(c1));
onepart second(.a(A[11:8]), .b(B[11:8]), .select(c1), .sum(Sum[11:8]), .cout(c2));
onepart third (.a(A[15:12]), .b(B[15:12]), .select(c2), .sum(Sum[15:12]), .cout(CO));    
	  
endmodule


module onepart(input logic [3:0]a, input logic [3:0]b, input logic select, output logic [3:0] sum, output logic cout);

logic [3:0] sum1,sum0;
logic cout0,cout1;
four_bit_ra cinwithzero(.x(a[3:0]), .y(b[3:0]), .cin(0), .s(sum0[3:0]), .cout(cout0));
four_bit_ra cinwithone (.x(a[3:0]), .y(b[3:0]), .cin(1), .s(sum1[3:0]), .cout(cout1));

always_comb
if (select==0)
	sum=sum0;
else
	sum=sum1;

assign cout= (select & cout1) | cout0;

endmodule 