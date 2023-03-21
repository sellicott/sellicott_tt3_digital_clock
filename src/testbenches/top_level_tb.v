/* top_level_tb: testbench for top-level design, we want to be able to test the synthesized design
 * as well, hopefully this will let us do that.
 * author: Samuel Ellicott
 * date: 03-20-23
 */


`define default_netname none
`timescale 10us/10us

module top_level_tb;

reg clk = 0;
reg military_time = 0;

reg set_hours = 0;
reg set_minutes = 0;

wire [7:0] io_in = {4'h0, set_minutes, set_hours, military_time, clk};
wire [7:0] io_out;

wire serial_out = io_out[0];
wire latch_out  = io_out[1];
wire clk_out    = io_out[2];
wire pm         = io_out[3];

sellicott_digital_clock top (
    .io_in(io_in),
    .io_out(io_out)
);

always begin
    #4 clk <= ~clk;
end

initial begin
    $dumpfile("top_level_tb.vcd");
    $dumpvars(0, top_level_tb);

    repeat (500) begin
        @(posedge latch_out);
    end

    $finish;
end

endmodule