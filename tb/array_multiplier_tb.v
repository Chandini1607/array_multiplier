`timescale 1ns/1ps

module array_multiplier_tb;

reg [3:0] a;
reg [3:0] b;
wire [7:0] product;

integer i, j;

array_multiplier uut (
    .a(a),
    .b(b),
    .product(product)
);

initial begin
    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            a = i;
            b = j;
            #10;
            if (product !== i * j)
                $display("FAIL: a=%d b=%d product=%d expected=%d",
                         a, b, product, i*j);
        end
    end

    $display("Testing completed");
    $finish;
end

endmodule

