`timescale 1ns/1ps

module multiplexer #(
    parameter WIDTH = 8
) (
    input  logic [WIDTH-1:0] normal_in,
    input  logic [WIDTH-1:0] bist_in,
    input  logic             NbarT,     // 0: normal mode, 1: BIST mode
    output logic [WIDTH-1:0] out
);

    always_comb begin
        if (NbarT)
            out = bist_in;
        else
            out = normal_in;
    end

endmodule
