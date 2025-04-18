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
    logic [6:0]           q;
    logic                 cout, NbarT, ld;
    logic                 we_select;
    logic                 eq, gt, lt;

    // Counter
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

    // Decoder
    decoder u_decoder (
        .q(q[6:4]),         // MSBs select pattern
        .data_t(ref_data)   // reference test data
    );

    // Comparator
    comparator u_comparator (
        .data_t(ref_data),
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
        .bist_in(ref_data),
        .NbarT(NbarT),
        .out(bist_data)
    );

    // Write Enable Select
    assign we_select = (NbarT) ? ~q[6] : ~rwbarin;

    // Memory
    single_port_ram u_ram (
        .clk(clk),
        .we(we_select),
        .ramaddr(bist_addr),
        .ramin(bist_data),
        .ramout(ramout)
    );

    // Output assignment
    assign dataout = ramout;

    // Fail logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            fail <= 0;
        else if (NbarT && opr && q[6] && !eq)
            fail <= 1;  // BIST mode fail
        else if (NbarT && !opr && rwbarin && !eq)
            fail <= 1;  // Normal mode fail
    end

endmodule
