`timescale 1ns/1ps

module tb_multiplexer;

    parameter WIDTH = 8;

    logic [WIDTH-1:0] normal_in;
    logic [WIDTH-1:0] bist_in;
    logic             NbarT;
    logic [WIDTH-1:0] out;

    // DUT instantiation
    multiplexer #(.WIDTH(WIDTH)) uut (
        .normal_in(normal_in),
        .bist_in(bist_in),
        .NbarT(NbarT),
        .out(out)
    );

    initial begin
        $display("Starting Multiplexer Testbench...");
        normal_in = 8'hAA;
        bist_in   = 8'h55;

        // Normal mode
        NbarT = 0; #10;
        assert(out == normal_in) else $error("Normal mode failed");

        // BIST mode
        NbarT = 1; #10;
        assert(out == bist_in) else $error("BIST mode failed");

        // Change inputs and test again
        normal_in = 8'h0F;
        bist_in   = 8'hF0;

        NbarT = 0; #10;
        assert(out == normal_in) else $error("Normal mode change failed");

        NbarT = 1; #10;
        assert(out == bist_in) else $error("BIST mode change failed");

        $display("All multiplexer tests passed.");
        $finish;
    end

endmodule
