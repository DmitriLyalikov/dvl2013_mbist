`timescale 1ns/1ps

module tb_decoder;

    logic [2:0] q;
    logic [7:0] data_t;

    // Instantiate the DUT
    decoder uut (
        .q(q),
        .data_t(data_t)
    );

    initial begin
        $display("Starting Decoder Testbench...");
        $monitor("Selector q = %b => data_t = %b", q, data_t);

        q = 3'b000; #10; assert(data_t == 8'b10101010) else $error("Failed for q = 000");
        q = 3'b001; #10; assert(data_t == 8'b01010101) else $error("Failed for q = 001");
        q = 3'b010; #10; assert(data_t == 8'b11110000) else $error("Failed for q = 010");
        q = 3'b011; #10; assert(data_t == 8'b00001111) else $error("Failed for q = 011");
        q = 3'b100; #10; assert(data_t == 8'b00000000) else $error("Failed for q = 100");
        q = 3'b101; #10; assert(data_t == 8'b11111111) else $error("Failed for q = 101");

        // Undefined pattern
        q = 3'b110; #10;
        if (^data_t !== 1'bx) $error("Expected undefined output for q = 110");

        $display("All tests passed.");
        $finish;
    end

endmodule
