`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/24/2026 02:46:19 PM
// Design Name: 
// Module Name: mac_pe
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

(* use_dsp = "yes" *)
module mac_pe (
    input  logic               clk,
    input  logic               rst,
    input  logic               en,
    input  logic signed [7:0]  a_in,
    input  logic signed [7:0]  b_in,
    output logic signed [7:0]  a_out,
    output logic signed [7:0]  b_out,
    output logic signed [31:0] acc
);
    always_ff @(posedge clk) begin
        if (rst) begin
            a_out <= '0;
            b_out <= '0;
            acc   <= '0;
        end else if (en) begin
            a_out <= a_in;      // hand a to the right neighbour
            b_out <= b_in;      // hand b to the neighbour below
            acc   <= acc + (a_in * b_in);
        end
    end
endmodule

 
