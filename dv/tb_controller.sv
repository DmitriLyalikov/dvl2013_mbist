`timescale 1ns/1ps

module tb_controller;

    logic clk, rst, start, cout;
    logic NbarT, ld;

    // Instantiate DUT
    controller uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cout(cout),
        .NbarT(NbarT),
        .ld(ld)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting Controller Testbench...");
        clk = 0;
        rst = 1; start = 0; cout = 0;
        #10;

        rst = 0;
        #10;

        // Should still be in RESET
        assert(ld == 1 && NbarT == 0) else $error("RESET state failed");

        // Start the test
        start = 1;
        #10;
        start = 0;

        // Should be in TEST state
        assert(ld == 0 && NbarT == 1) else $error("TEST state entry failed");

        // Remain in TEST
        #10;
        assert(NbarT == 1 && ld == 0) else $error("Stuck in TEST failed");

        // End of test
        cout = 1;
        #10;
        cout = 0;

        // Should go back to RESET
        assert(ld == 1 && NbarT == 0) else $error("Return to RESET failed");

        $display("All tests passed.");
        $finish;
    end

endmodule
