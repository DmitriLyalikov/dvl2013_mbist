`timescale 1ns/1ps

module counter #(
    parameter length = 10
) (
    input  logic                  clk,
    input  logic                  ld,      // load enable
    input  logic                  u_d,     // up/down: 1 = up, 0 = down
    input  logic                  cen,     // count enable
    input  logic [length-1:0]     d_in,    // input load value
    output logic [length-1:0]     q,       // counter output
    output logic                  cout     // carry-out (overflow/underflow)
);

    logic [length-1:0] next_q;

    always_ff @(posedge clk) begin
        if (cen) begin
            if (ld) begin
                q <= d_in;
                cout <= 0;
            end else begin
                if (u_d) begin
                    next_q = q + 1;
                    cout <= (q == {length{1'b1}});
                    q <= next_q;
                end else begin
                    next_q = q - 1;
                    cout <= (q == {length{1'b0}});
                    q <= next_q;
                end
            end
        end
    end

endmodule

