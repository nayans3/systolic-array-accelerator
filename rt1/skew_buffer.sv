module skew_buffer #(
    parameter int N = 2
) (
    input  logic              clk,
    input  logic              rst,
    input  logic              en,
    input  logic signed [7:0] din  [N],   // N values arriving at the same time
    output logic signed [7:0] dout [N]    // lane i comes out i cycles later
);
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : g_lane
            if (i == 0) begin : g_nodelay
                // lane 0: no delay, wire straight through
                assign dout[0] = din[0];
            end else begin : g_delay
                // lane i: a chain of i registers
                logic signed [7:0] sr [i];

                always_ff @(posedge clk) begin
                    if (rst) begin
                        for (int s = 0; s < i; s++) sr[s] <= '0;
                    end else if (en) begin
                        sr[0] <= din[i];                                   // new value enters
                        for (int s = 1; s < i; s++) sr[s] <= sr[s-1];      // everything shifts one step
                    end
                end

                assign dout[i] = sr[i-1];   // value leaves from the end of the chain
            end
        end
    endgenerate
endmodule