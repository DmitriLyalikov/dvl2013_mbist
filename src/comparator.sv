// comparator.sv
`timescale 1ns/1ps
module comparator (
    input  logic [7:0] data_t,   // expected data
    input  logic [7:0] ramout,   // actual SRAM output
    output logic       gt,       // data_t > ramout
    output logic       eq,       // data_t == ramout
    output logic       lt        // data_t < ramout
);

    always_comb begin
        gt = 0;
        eq = 0;
        lt = 0;

        if (data_t > ramout)
            gt = 1;
        else if (data_t < ramout)
            lt = 1;
        else
            eq = 1;
    end

endmodule
