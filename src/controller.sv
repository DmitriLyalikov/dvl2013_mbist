`timescale 1ns/1ps

module controller (
    input  logic clk,        // Clock signal
    input  logic rst,        // Reset signal
    input  logic start,      // Trigger BIST test
    input  logic cout,       // Counter overflow/completion

    output logic NbarT,      // 1 during test phase
    output logic ld          // 1 during reset phase
);

    typedef enum logic [1:0] {RESET, TEST} state_t;
    state_t state, next;

    // Sequential logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            state <= RESET;
        else
            state <= next;
    end

    // Combinational logic
    always_comb begin
        // Default outputs
        NbarT = 0;
        ld = 0;

        case (state)
            RESET: begin
                ld = 1;
                if (start)
                    next = TEST;
                else
                    next = RESET;
            end
            TEST: begin
                NbarT = 1;
                if (cout)
                    next = RESET;
                else
                    next = TEST;
            end
            default: next = RESET;
        endcase
    end

endmodule
