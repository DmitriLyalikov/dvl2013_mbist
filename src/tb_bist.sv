`timescale 1ns/1ps

module tb_bist;

    logic clk, rst, start, csin, rwbarin, opr;
    logic [5:0] address;
    logic [7:0] datain;
    logic [7:0] dataout;
    logic fail;

    // Instantiate BIST DUT (Device Under Test)
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

    // Clock generation: 100MHz
    always #5 clk = ~clk;

    initial begin
        $display("🧪 Starting BIST Full Integration Test...");

        // Initialize
        clk = 0;
        rst = 1;
        start = 0;
        csin = 0;
        rwbarin = 0;
        opr = 0;
        address = 6'd0;
        datain = 8'h00;

        // Release reset
        #10 rst = 0;

        // Optional: write and read test in normal mode
        address = 6'd3;
        datain = 8'h5A;
        rwbarin = 0;  // write
        csin = 1;
        #10;
        rwbarin = 1;  // read
        #10;
        $display("🔧 Normal mode readback: address=%0d, dataout=%h", address, dataout);

        // Start BIST mode
        opr = 1;   // enter BIST mode
        start = 1;
        #10;
        start = 0;

        // Wait for BIST to complete
        repeat (600) @(posedge clk);  // Enough cycles for 8 patterns × 64 addresses

        // Check result
        if (fail) begin
            $display("❌ BIST FAILED: Self-test reported a fault.");
            $error("Testbench FAILED.");
        end else begin
            $display("✅ BIST PASSED: All memory patterns verified successfully.");
        end

        $finish;
    end

endmodule

