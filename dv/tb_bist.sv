`timescale 1ns/1ps

module tb_bist;

    logic clk, rst, start, csin, rwbarin, opr;
    logic [5:0] address;
    logic [7:0] datain, dataout;
    logic fail;

    // Instantiate BIST DUT
    bist uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .csin(csin),
        .rwbarin(rwbarin),
        .opr(opr),
        .address(address),
        .datain(datain),
        .dataout(dataout),
        .fail(fail)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting BIST Full Integration Test...");
        clk = 0; rst = 1; start = 0;
        csin = 0; rwbarin = 0;
        address = 0; datain = 8'h00;
        opr = 0; // normal mode

        #10 rst = 0;
        #10;

        // Write something in normal mode
        datain = 8'h5A;
        address = 6'd3;
        rwbarin = 0; // write
        csin = 1;
        #10;
        rwbarin = 1; // read
        #10;
        assert(dataout == 8'h5A) else $error("Normal mode memory read failed.");

        // Start BIST mode
        opr = 1;
        start = 1;
        #10;
        start = 0;

        // Wait for test to complete
        repeat (100) @(posedge clk);

        if (fail)
            $error("BIST reported failure.");
        else
            $display("BIST Test PASSED.");

        $finish;
    end

endmodule
