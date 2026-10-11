`timescale 1ns/1ps
module mac_pe_tb;
    logic clk = 0;
    logic rst = 1;
    logic en  = 0;
    logic signed [7:0]  a_in = 0, b_in = 0;
    logic signed [7:0]  a_out, b_out;
    logic signed [31:0] acc;
    int errors = 0;

    mac_pe dut (.clk(clk), .rst(rst), .en(en),
                .a_in(a_in), .b_in(b_in),
                .a_out(a_out), .b_out(b_out), .acc(acc));

    always #5 clk = ~clk;

    task check(input string name, input int got, input int exp);
        if (got !== exp) begin
            $display("FAIL %s: got %0d, expected %0d", name, got, exp);
            errors++;
        end else begin
            $display("PASS %s = %0d", name, got);
        end
    endtask

    initial begin
        @(negedge clk);
        rst = 0;
        en  = 1;

        a_in = 3; b_in = 6;          // this is cell c22 from the walkthrough
        @(negedge clk);
        check("acc after 3x6", acc, 18);
        check("a_out", a_out, 3);
        check("b_out", b_out, 6);

        a_in = 4; b_in = 8;
        @(negedge clk);
        check("acc after +4x8", acc, 50);
        check("a_out", a_out, 4);
        check("b_out", b_out, 8);

        a_in = -5; b_in = 7;         // negative number check
        @(negedge clk);
        check("acc after -5x7", acc, 15);

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d FAILURES", errors);
        $finish;
    end
endmodule