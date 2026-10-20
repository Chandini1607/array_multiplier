
module mult_array(
    input clk,
    input rst_n,
    input [3:0] a,
    input [3:0] b,
    output reg [7:0] p
);

reg [3:0] a_reg, b_reg;
wire [3:0] pp0, pp1, pp2, pp3;
wire [7:0] row0, row1, row2, row3;
wire [7:0] product_comb;

wire [3:0] s1, s2, s3;
wire [4:0] c1, c2, c3;

assign pp0 = a_reg & {4{b_reg[0]}};
assign pp1 = a_reg & {4{b_reg[1]}};
assign pp2 = a_reg & {4{b_reg[2]}};
assign pp3 = a_reg & {4{b_reg[3]}};

assign row0 = {4'b0000, pp0};
assign row1 = {3'b000, pp1, 1'b0};
assign row2 = {2'b00, pp2, 2'b00};
assign row3 = {1'b0, pp3, 3'b000};

assign c1[0] = 1'b0;
assign c2[0] = 1'b0;
assign c3[0] = 1'b0;

full_adder fa10(pp1[0], pp0[1], 1'b0, s1[0], c1[1]);
full_adder fa11(pp1[1], pp0[2], c1[1], s1[1], c1[2]);
full_adder fa12(pp1[2], pp0[3], c1[2], s1[2], c1[3]);
full_adder fa13(pp1[3], 1'b0, c1[3], s1[3], c1[4]);

full_adder fa20(pp2[0], s1[1], 1'b0, s2[0], c2[1]);
full_adder fa21(pp2[1], s1[2], c2[1], s2[1], c2[2]);
full_adder fa22(pp2[2], s1[3], c2[2], s2[2], c2[3]);
full_adder fa23(pp2[3], c1[4], c2[3], s2[3], c2[4]);

full_adder fa30(pp3[0], s2[1], 1'b0, s3[0], c3[1]);
full_adder fa31(pp3[1], s2[2], c3[1], s3[1], c3[2]);
full_adder fa32(pp3[2], s2[3], c3[2], s3[2], c3[3]);
full_adder fa33(pp3[3], c2[4], c3[3], s3[3], c3[4]);

assign product_comb = {c3[4],s3[3:0], s2[0], s1[0], pp0[0]};

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        a_reg <= 0;
        b_reg <= 0;
        p <= 0;
    end
    else begin
        a_reg <= a;
        b_reg <= b;
        p <= product_comb;
    end
end

endmodule
