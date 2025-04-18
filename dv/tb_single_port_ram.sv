`timescale 1ns/1ps

module tb_single_port_ram;

    logic clk, we;
    logic [5:0] ramaddr;
    logic [7:0] ramin, ramout;

    // Instantiate DUT
    single_port_ram uut (
        .clk(clk),
        .we(we),
        .ramaddr(ramaddr),
        .ramin(ramin),
        .ramout(ramout)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $display("Starting Single Port RAM Testbench...");
        clk = 0;
        we = 0;
        ramaddr = 0;
        ramin = 0;

        // Write to address 0
        @(posedge clk);
        ramaddr = 6'd0;
        ramin = 8'hA5;
        we = 1;

        @(posedge clk);
        we = 0;

        // Wait and read from address 0
        @(posedge clk);
        assert(ramout == 8'hA5) else $error("Read from addr 0 failed: got %h", ramout);

        // Write to another address
        ramaddr = 6'd10;
        ramin = 8'h3C;
        we = 1;

        @(posedge clk);
        we = 0;

        // Read back
        @(posedge clk);
        assert(ramout == 8'h3C) else $error("Read from addr 10 failed: got %h", ramout);

        // Ensure other address is unchanged
        ramaddr = 6'd0;
        @(posedge clk);
        assert(ramout == 8'hA5) else $error("Addr 0 should still be 0xA5: got %h", ramout);

        $display("All single-port RAM tests passed.");
        $finish;
    end

endmodule
