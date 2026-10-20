module array_multiplier(
    input [3:0] a,
    input [3:0] b,
    output [7:0] product
);

wire [3:0] pp0, pp1, pp2, pp3;
wire [7:0] row0, row1, row2, row3;

assign pp0 = a & {4{b[0]}};
assign pp1 = a & {4{b[1]}};
assign pp2 = a & {4{b[2]}};
assign pp3 = a & {4{b[3]}};

assign row0 = {4'b0000, pp0};
assign row1 = {3'b000, pp1, 1'b0};
assign row2 = {2'b00, pp2, 2'b00};
assign row3 = {1'b0, pp3, 3'b000};

assign product = row0 + row1 + row2 + row3;

endmodule
