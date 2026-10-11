`timescale 1ns/1ps
module gemm_top_tb;
    localparam int N         = 8;
    localparam int K         = 8;
    localparam int NUM_TESTS = 20;

    logic clk = 0;
    logic rst = 1;
    logic en  = 0;
    logic signed [7:0]  a_col [N];
    logic signed [7:0]  b_row [N];
    logic signed [31:0] c     [N][N];

    int A        [N][K];
    int B        [K][N];
    int expected [N][N];
    int errors = 0;

    gemm_top #(.N(N)) dut (
        .clk(clk), .rst(rst), .en(en),
        .a_col(a_col), .b_row(b_row), .c(c)
    );

    always #5 clk = ~clk;

    task make_matrices(input int mode);
        for (int i = 0; i < N; i++)
            for (int k = 0; k < K; k++)
                A[i][k] = (mode == 1) ? -128 : $urandom_range(0, 255) - 128;
        for (int k = 0; k < K; k++)
            for (int j = 0; j < N; j++)
                B[k][j] = (mode == 1) ? -128 : $urandom_range(0, 255) - 128;
    endtask

    task compute_expected();
        for (int i = 0; i < N; i++)
            for (int j = 0; j < N; j++) begin
                expected[i][j] = 0;
                for (int k = 0; k < K; k++)
                    expected[i][j] += A[i][k] * B[k][j];
            end
    endtask

    task run_one(input int test_num);
        rst = 1;
        en  = 0;
        for (int i = 0; i < N; i++) begin
            a_col[i] = 0;
            b_row[i] = 0;
        end
        @(negedge clk);
        rst = 0;
        en  = 1;

        // NO stagger here anymore: send column t of A and row t of B, all at once
        for (int t = 0; t < K + 2*N; t++) begin
            for (int i = 0; i < N; i++) begin
                if (t < K) a_col[i] = A[i][t];
                else       a_col[i] = 0;
            end
            for (int j = 0; j < N; j++) begin
                if (t < K) b_row[j] = B[t][j];
                else       b_row[j] = 0;
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
        make_matrices(1);
        compute_expected();
        run_one(0);

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