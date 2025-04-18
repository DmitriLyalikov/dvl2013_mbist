`timescale 1ns/1ps

module single_port_ram (
    input  logic         clk,
    input  logic         we,         // write enable
    input  logic [5:0]   ramaddr,    // 6-bit address (64 locations)
    input  logic [7:0]   ramin,      // data input
    output logic [7:0]   ramout      // data output
);

    logic [7:0] ram [0:63];          // 64 x 8-bit memory
    logic [5:0] addr_reg;

    always_ff @(posedge clk) begin
        addr_reg <= ramaddr;
        if (we)
            ram[ramaddr] <= ramin;
    end

    assign ramout = ram[addr_reg];

endmodule
