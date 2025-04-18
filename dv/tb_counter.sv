`timescale 1ns/1ps

module tb_counter;

    parameter length = 4;

    logic clk;
    logic ld, u_d, cen;
    logic [length-1:0] d_in;
    logic [length-1:0] q;
    logic cout;

    // Instantiate DUT
    counter #(.length(length)) uut (
        .clk(clk),
        .ld(ld),
        .u_d(u_d),
        .cen(cen),
        .d_in(d_in),
        .q(q),
        .cout(cout)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting Counter Testbench...");
        clk = 0;
        cen = 0;
        ld  = 0;
        u_d = 1;
        d_in = 0;

        // Load value into counter
        @(posedge clk);
        ld  = 1;
        cen = 1;
        d_in = 4'b0011; // Load 3
        @(posedge clk);
        ld = 0;

        // Up-count
        repeat(3) @(posedge clk);
        
        // Down-count
        u_d = 0;
        repeat(3) @(posedge clk);

        // Load max value and test overflow
        ld = 1;
        d_in = 4'b1111;
        @(posedge clk);
        ld = 0;
        u_d = 1;
        @(posedge clk); // Expect overflow cout = 1
        assert(cout == 1) else $error("Overflow test failed");

        // Load 0 and test underflow
        ld = 1;
        d_in = 4'b0000;
        @(posedge clk);
        ld = 0;
        u_d = 0;
        @(posedge clk); // Expect underflow cout = 1
        assert(cout == 1) else $error("Underflow test failed");

        $display("All tests complete.");
        $finish;
    end

endmodule
