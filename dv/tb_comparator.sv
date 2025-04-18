// tb_comparator.sv
`timescale 1ns/1ps

module tb_comparator;

    logic [7:0] data_t;
    logic [7:0] ramout;
    logic       gt, eq, lt;

    // Instantiate the DUT
    comparator uut (
        .data_t(data_t),
        .ramout(ramout),
        .gt(gt),
        .eq(eq),
        .lt(lt)
    );

    initial begin
        $display("Starting Comparator Testbench...");
        $monitor("data_t=%0d, ramout=%0d => gt=%b, eq=%b, lt=%b", data_t, ramout, gt, eq, lt);

        // Test equality
        data_t = 8'hAA; ramout = 8'hAA; #10;
        assert (eq && !gt && !lt) else $error("Failed equality test");

        // Test greater than
        data_t = 8'hF0; ramout = 8'h0F; #10;
        assert (gt && !eq && !lt) else $error("Failed greater-than test");

        // Test less than
        data_t = 8'h10; ramout = 8'h20; #10;
        assert (lt && !eq && !gt) else $error("Failed less-than test");

        // Edge values
        data_t = 8'h00; ramout = 8'hFF; #10;
        assert (lt) else $error("Edge case 00 < FF failed");

        data_t = 8'hFF; ramout = 8'h00; #10;
        assert (gt) else $error("Edge case FF > 00 failed");

        $display("All tests passed.");
        $finish;
    end

endmodule
