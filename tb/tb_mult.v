
`timescale 1ns/1ps

module tb_mult;

reg clk;
reg rst_n;
reg [3:0] a;
reg [3:0] b;
wire [7:0] p;

integer i, j;
integer errors;
integer checked;
reg [7:0] expected;

mult_array uut (
    .clk(clk),
    .rst_n(rst_n),
    .a(a),
    .b(b),
    .p(p)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    $dumpfile("mult.vcd");
    $dumpvars(0, tb_mult);

    rst_n = 0;
    a = 0;
    b = 0;
    errors = 0;
    checked = 0;

    repeat (2) @(posedge clk);
    @(negedge clk);
    rst_n = 1;

    for (i = 0; i < 16; i = i + 1) begin
        for (j = 0; j < 16; j = j + 1) begin
            @(negedge clk);
            a = i;
            b = j;
            expected = i * j;

            @(posedge clk);
            @(posedge clk);
            #2;

            checked = checked + 1;

            if (p !== expected) begin
                errors = errors + 1;
                $display("FAIL: a=%0d b=%0d p=%0d expected=%0d",
                         i, j, p, expected);
            end
        end
    end

    if (errors == 0)
        $display("PASS: %0d vectors checked, %0d errors", checked, errors);
    else
        $display("FAIL: %0d vectors checked, %0d errors", checked, errors);

    $finish;
end

endmodule
