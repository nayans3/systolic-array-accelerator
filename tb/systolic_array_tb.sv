`timescale 1ns/1ps
module systolic_array_tb;
    localparam int N         = 8;   // grid size (N x N cells)
    localparam int K         = 8;   // length of each dot product
    localparam int NUM_TESTS = 20;  // how many random tests

    logic clk = 0;
    logic rst = 1;
    logic en  = 0;
    logic signed [7:0]  a_left [N];
    logic signed [7:0]  b_top  [N];
    logic signed [31:0] c      [N][N];

    int A        [N][K];   // A is N rows, K columns
    int B        [K][N];   // B is K rows, N columns
    int expected [N][N];   // correct answer, computed by the testbench
    int errors = 0;

    systolic_array #(.N(N)) dut (
        .clk(clk), .rst(rst), .en(en),
        .a_left(a_left), .b_top(b_top), .c(c)
    );

    always #5 clk = ~clk;

    // Fill A and B. mode 0 = random numbers, mode 1 = every value is -128
    task make_matrices(input int mode);
        for (int i = 0; i < N; i++)
            for (int k = 0; k < K; k++)
                A[i][k] = (mode == 1) ? -128 : $urandom_range(0, 255) - 128;
        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++)
                B[k][j] = (mode == 1) ? -128 : $urandom_range(0, 255) - 128;
    endtask

    // The "golden model": plain matrix multiply, the slow obvious way
    task compute_expected();
        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++) begin
                expected[i][j] = 0;
                for (int k = 0; k < K; k++)
                    expected[i][j] += A[i][k] * B[k][j];
            end
    endtask

    // Reset, feed A and B in with the stagger, then check every cell
    task run_one(input int test_num);
        rst = 1;
        en  = 0;
        for (int i = 0; i < N; i++) begin
            a_left[i] = 0;
            b_top[i]  = 0;
        end
        @(negedge clk);
        rst = 0;
        en  = 1;

        for (int t = 0; t < K + 2*N; t++) begin
            for (int i = 0; i < N; i++) begin
                if (t - i >= 0 && t - i < K) a_left[i] = A[i][t - i];
                else                         a_left[i] = 0;
            end
            for (int j = 0; j < N; j++) begin
                if (t - j >= 0 && t - j < K) b_top[j] = B[t - j][j];
                else                         b_top[j] = 0;
            end
            @(negedge clk);
        end

        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++)
                if (c[i][j] !== expected[i][j]) begin
                    $display("FAIL test %0d, cell (%0d,%0d): got %0d, expected %0d",
                             test_num, i, j, c[i][j], expected[i][j]);
                    errors++;
                end
    endtask

    initial begin
        // test 0: the biggest possible values
        make_matrices(1);
        compute_expected();
        run_one(0);

        // tests 1..NUM_TESTS: random values
        for (int n = 1; n <= NUM_TESTS; n++) begin
            make_matrices(0);
            compute_expected();
            run_one(n);
        end

        if (errors == 0)
            $display("ALL %0d TESTS PASSED  (N=%0d, K=%0d)", NUM_TESTS + 1, N, K);
        else
            $display("%0d FAILURES", errors);
        $finish;
    end
endmodule