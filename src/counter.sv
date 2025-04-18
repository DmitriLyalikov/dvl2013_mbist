`timescale 1ns/1ps

module counter #(
    parameter length = 10
)(
    input  logic [length-1:0] d_in,    // Load value
    input  logic              clk,     // Clock
    input  logic              ld,      // Load enable
    input  logic              u_d,     // Up/down control (1 = up, 0 = down)
    input  logic              cen,     // Count enable
    output logic [length-1:0] q,       // Counter output
    output logic              cout     // Carry out
);

    always_ff @(posedge clk) begin
        if (cen) begin
            if (ld) begin
                q <= d_in;
            end else begin
                if (u_d) begin
                    q <= q + 1;
                end else begin
                    q <= q - 1;
                end
            end
        end
    end

    always_comb begin
        if (u_d)
            cout = (q == {length{1'b1}});  // Max value
        else
            cout = (q == {length{1'b0}});  // Min value
    end

endmodule
