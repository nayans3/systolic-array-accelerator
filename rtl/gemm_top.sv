module gemm_top #(
    parameter int N = 8
) (
    input  logic               clk,
    input  logic               rst,
    input  logic               en,
    input  logic signed [7:0]  a_col [N],    // one column of A per cycle, all at once
    input  logic signed [7:0]  b_row [N],    // one row of B per cycle, all at once
    output logic signed [31:0] c     [N][N]
);
    logic signed [7:0] a_skewed [N];
    logic signed [7:0] b_skewed [N];

    // stagger A's rows and B's columns
    skew_buffer #(.N(N)) skew_a (
        .clk(clk), .rst(rst), .en(en),
        .din(a_col), .dout(a_skewed)
    );
    skew_buffer #(.N(N)) skew_b (
        .clk(clk), .rst(rst), .en(en),
        .din(b_row), .dout(b_skewed)
    );

    
    systolic_array #(.N(N)) array (
        .clk(clk), .rst(rst), .en(en),
        .a_left(a_skewed), .b_top(b_skewed), .c(c)
    );
endmodule
