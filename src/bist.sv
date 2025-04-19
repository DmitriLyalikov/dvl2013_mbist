`timescale 1ns/1ps

module bist #(
    parameter size   = 6,  // address width (64 locations)
    parameter length = 8   // data width
)(
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 start,
    input  logic                 csin,
    input  logic                 rwbarin,
    input  logic                 opr,           // 1 = BIST, 0 = normal
    input  logic [size-1:0]      address,
    input  logic [length-1:0]    datain,
    output logic [length-1:0]    dataout,
    output logic                 fail
);

    // Internal signals
    logic [size-1:0]      bist_addr;
    logic [length-1:0]    bist_data;
    logic [length-1:0]    ramout;
    logic [length-1:0]    ref_data;
    logic [length-1:0]    pattern_latched;
    logic [6:0]           q;
    logic                 cout, NbarT, ld;
    logic                 we_select;
    logic                 eq, gt, lt;
    logic [2:0]           selector;

    // Counter (7 bits: 6 for address, 1 for rw)
    counter #(.length(7)) u_counter (
        .clk(clk),
        .ld(ld),
        .u_d(1'b1),
        .cen(1'b1),
        .d_in(7'd0),
        .q(q),
        .cout(cout)
    );

    // Controller FSM
    controller u_controller (
        .clk(clk),
        .rst(rst),
        .start(start),
        .cout(cout),
        .NbarT(NbarT),
        .ld(ld)
    );

    // Limit selector to valid patterns only (0–5)
    assign selector = (q[6:4] <= 3'b101) ? q[6:4] : 3'b000;

    // Decoder
    decoder u_decoder (
        .q(selector),
        .data_t(ref_data)
    );

    // Latch decoder pattern at start of each write phase
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pattern_latched <= 0;
        else if (NbarT && q[6] == 1'b0 && q[5:0] == 6'd0)
            pattern_latched <= ref_data;
    end

    // Comparator
    comparator u_comparator (
        .data_t(pattern_latched),
        .ramout(ramout),
        .gt(gt),
        .eq(eq),
        .lt(lt)
    );

    // Address MUX
    multiplexer #(.WIDTH(size)) u_addr_mux (
        .normal_in(address),
        .bist_in(q[size-1:0]),
        .NbarT(NbarT),
        .out(bist_addr)
    );

    // Data MUX
    multiplexer #(.WIDTH(length)) u_data_mux (
        .normal_in(datain),
        .bist_in(pattern_latched),
        .NbarT(NbarT),
        .out(bist_data)
    );

    // Write Enable Selection
    assign we_select = (NbarT) ? ~q[6] : ~rwbarin;

    // Memory Instance
    single_port_ram u_ram (
        .clk(clk),
        .we(we_select),
        .ramaddr(bist_addr),
        .ramin(bist_data),
        .ramout(ramout)
    );

    // Output for observing
    assign dataout = ramout;

    // Fail Logic: Only trigger fail during BIST reads with valid pattern
    always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        fail <= 0;
    end 
    // Reset fail at the start of a new pattern write (address 0, write phase)
    else if (NbarT && q[6] == 0 && q[5:0] == 6'd0) begin
        fail <= 0;
    end 
    // Set fail only during BIST read phase
    else if (NbarT && opr && q[6] && (^pattern_latched !== 1'bx) && !eq) begin
        fail <= 1;
    end
    end

endmodule

