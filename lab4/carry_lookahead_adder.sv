module carry_lookahead_adder
(
    input   logic[15:0]     A,
    input   logic[15:0]     B,
    output  logic[15:0]     Sum,
    output  logic           CO
);

    /* TODO
     *
     * Insert code here to implement a CLA adder.
     * Your code should be completly combinational (don't use always_ff or always_latch).
     * Feel free to create sub-modules or other files. */
logic pg0,pg4,pg8,pg12;
logic gg0,gg4,gg8;
logic cin;
assign cin=0;

fourbit_sum first (.a(A[3:0])  , .b(B[3:0]), .cin(cin),                                                      .gp(pg0), .gg(gg0), .s(Sum[3:0]));
fourbit_sum second(.a(A[7:4])  , .b(B[7:4]), .cin(cin & pg0 + gg0),                                          .gp(pg4), .gg(gg4), .s(Sum[7:4]));
fourbit_sum third (.a(A[11:8]) , .b(B[11:8]), .cin(cin & pg0 & pg4+ gg0 & pg4 + gg4),                        .gp(pg8), .gg(gg8), .s(Sum[11:8]));
fourbit_sum fourth(.a(A[15:12]), .b(B[15:12]), .cin(cin & pg0 & pg4 & pg8+ gg0 & pg4 & pg8 + gg4 & pg8),     .gp(pg12), .gg(CO), .s(Sum[15:12]));
	  
endmodule

module fourbit_sum(input logic [3:0]a, input logic[3:0]b, input logic cin, output logic gp, output logic gg, output logic [3:0]s);

logic c1,c2,c3;
logic p0,p1,p2,p3;
logic g0,g1,g2,g3;


onebit_pg first (.a(a[0]), .b(b[0]) ,.p(p0) ,.g(g0));
onebit_pg second(.a(a[1]), .b(b[1]) ,.p(p1) ,.g(g1));
onebit_pg third (.a(a[2]), .b(b[2]) ,.p(p2) ,.g(g2));
onebit_pg fourth(.a(a[3]), .b(b[3]) ,.p(p3) ,.g(g3));

always_comb 
begin
c1= (cin & p0) | g0;
c2= (cin & p0 & p1) | (g0 & p1) | g1;
c3= (cin & p0 & p1 & p2) | (g0 & p1 & p2) | (g1 & p2) | g2;

gg= (g0 & p1 & p2 & p3) | (g1 & p2 & p3) | (g2 & p3) | g3;
gp= p0 & p1 & p2 &p3;
end

onebit_sum first_result (.a(a[0]), .b(b[0]) ,.cin(cin), .s(s[0]));
onebit_sum second_result(.a(a[1]), .b(b[1]) ,.cin(c1), .s(s[1]));
onebit_sum third_result (.a(a[2]), .b(b[2]) ,.cin(c2), .s(s[2]));
onebit_sum fourth_result(.a(a[3]), .b(b[3]) ,.cin(c3), .s(s[3]));

 

endmodule

module onebit_sum(input logic a, input logic b, input logic cin, output logic s);

assign s=a ^ b ^ cin;

endmodule

module onebit_pg(input logic a, input logic b, output logic p,output logic g);

assign p=a ^ b;
assign g=a & b;

endmodule
