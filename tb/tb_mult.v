`timescale 1ns/1ps
module tb_mult;
    reg        clk;
    reg        rst_n;
    reg  [3:0] a, b;
    wire [7:0] p;
    reg  [7:0] expected;
    integer    i, j, errors, count;

    mult_array dut (.clk(clk), .rst_n(rst_n), .a(a), .b(b), .p(p));

    // 10 ns clock
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // waveform dump
    initial begin
        $dumpfile("mult.vcd");
        $dumpvars(0, tb_mult);
    end

    initial begin
        errors = 0;
        count  = 0;
        rst_n  = 1'b0;
        a      = 4'd0;
        b      = 4'd0;

        // hold reset low for 2 clock cycles
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst_n = 1'b1;

        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                // apply inputs at a falling edge
                a = i;
                b = j;
                // 2-cycle latency: input regs at edge 1, output reg at edge 2
                @(posedge clk);
                @(posedge clk);
                // check at the next falling edge
                @(negedge clk);
                expected = i * j;
                count = count + 1;
                if (p !== expected) begin
                    errors = errors + 1;
                    $display("MISMATCH: a=%0d b=%0d p=%0d expected=%0d",
                             a, b, p, expected);
                end
            end
        end

        if (errors == 0)
            $display("PASS: %0d vectors checked, %0d errors", count, errors);
        else
            $display("FAIL: %0d vectors checked, %0d errors", count, errors);
        $finish;
    end
endmodule
