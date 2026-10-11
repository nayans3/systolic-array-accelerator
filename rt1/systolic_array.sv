module systolic_array #(
    parameter int N = 2                     // grid size: N x N cells
) (
    input  logic               clk,
    input  logic               rst,
    input  logic               en,
    input  logic signed [7:0]  a_left [N],  // one input per row, enters from the left
    input  logic signed [7:0]  b_top  [N],  // one input per column, enters from the top
    output logic signed [31:0] c      [N][N] // every cell's running total
);
    // The wires between cells.
    // a_wire[i][j] = the a value going INTO cell (i,j) from its left
    // b_wire[i][j] = the b value going INTO cell (i,j) from above
    wire signed [7:0] a_wire [N][N+1];
    wire signed [7:0] b_wire [N+1][N];

    genvar i, j;
    generate
        // connect the outside inputs to the edges of the grid
        for (i = 0; i < N; i++) begin : g_left
            assign a_wire[i][0] = a_left[i];
        end
        for (j = 0; j < N; j++) begin : g_top
            assign b_wire[0][j] = b_top[j];
        end

        // stamp out N x N cells and wire each one to its neighbours
        for (i = 0; i < N; i++) begin : g_row
            for (j = 0; j < N; j++) begin : g_col
                mac_pe pe (
                    .clk  (clk),
                    .rst  (rst),
                    .en   (en),
                    .a_in (a_wire[i][j]),      // from the left
                    .b_in (b_wire[i][j]),      // from above
                    .a_out(a_wire[i][j+1]),    // to the right
                    .b_out(b_wire[i+1][j]),    // to below
                    .acc  (c[i][j])
                );
            end
        end
    endgenerate
endmodule