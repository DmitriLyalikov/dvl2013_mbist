`timescale 1ns/1ps

module decoder (
    input  logic [2:0] q,         // pattern selector
    output logic [7:0] data_t     // corresponding pattern
);

    always_comb begin
        case (q)
            3'b000: data_t = 8'b10101010;
            3'b001: data_t = 8'b01010101;
            3'b010: data_t = 8'b11110000;
            3'b011: data_t = 8'b00001111;
            3'b100: data_t = 8'b00000000;
            3'b101: data_t = 8'b11111111;
            default: data_t = 8'bxxxxxxxx;
        endcase
    end

endmodule
