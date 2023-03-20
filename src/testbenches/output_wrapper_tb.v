/* output_wrapper: testbench for output wrapper, makes sure we can shift data out correctly and that
 * data is blanked correctly when enable is low.
 * author: Samuel Ellicott
 * date: 03-20-23
 */

`define default_netname none
`timescale 10us/10us

module output_wrapper_tb;

reg enable = 0;

wire serial_out;
wire latch_out;
wire clk_out;

wire pm;
wire [3:0] hours_msd;
wire [3:0] hours_lsd;
wire [3:0] minutes_msd;
wire [3:0] minutes_lsd;
wire [3:0] seconds_msd;
wire [3:0] seconds_lsd;

reg clk = 0;
wire clk_sr;
wire clk_set;
wire clk_1hz;

clock_divider clk_div (
    .clk(clk),
    .clk_sr(clk_sr),
    .clk_set(clk_set),
    .clk_1hz(clk_1hz)
);

time_register clock_inst(
    .en(1'h1),
    .clk(clk_1hz),
    .military_time(1'h0),

    .set_clk(clk_set),
    .set_hours(1'h0),
    .set_minutes(1'h0),

    .pm(pm),
    .hours_msd(hours_msd),
    .hours_lsd(hours_lsd),
    .minutes_msd(minutes_msd),
    .minutes_lsd(minutes_lsd),
    .seconds_msd(seconds_msd),
    .seconds_lsd(seconds_lsd)
);

output_wrapper output_inst (
    .en(enable),
    .sr_clk(clk_sr),

    .hours_msd(hours_msd),
    .hours_lsd(hours_lsd),
    .minutes_msd(minutes_msd),
    .minutes_lsd(minutes_lsd),
    .seconds_msd(seconds_msd),
    .seconds_lsd(seconds_lsd),

    .serial_out(serial_out),
    .latch_out(latch_out),
    .clk_out(clk_out)
);


always begin
    #4 clk <= ~clk;
end

initial begin
    enable = 1;
    $dumpfile("output_wrapper_tb.vcd");
    $dumpvars(0, output_wrapper_tb);

    repeat (60) begin
        @(negedge clk_1hz);
    end

    enable = 0;
    repeat (60) begin
        @(negedge clk_1hz);
    end

    $finish;
end

endmodule