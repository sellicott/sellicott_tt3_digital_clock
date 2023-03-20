/* bcd_to_7seg_tb: Module to test the bcd to 7-segment decoder, cycle through all segments
 * author: Samuel Ellicott
 * date: 03-04-23
 */

`define default_netname none
`timescale 1ns/100ps

module shift_register_controller_tb;

reg enable = 0;

wire [6:0] led_out;
wire serial_out;

wire pm;
wire [3:0] hours_msd;
wire [3:0] hours_lsd;
wire [3:0] minutes_msd;
wire [3:0] minutes_lsd;
wire [3:0] seconds_msd;
wire [3:0] seconds_lsd;

wire [2:0] bcd_select;
wire sr_load;

wire ext_latch;
wire ext_clk;

// make a counter to go through all the 4-bit numbers
reg clk = 0;


shift_register_controller sr_controller (
    .en(enable),
    .clk(clk),

    .bcd_select(bcd_select),
    .sr_load(sr_load),

    .ext_latch(ext_latch),
    .ext_clk(ext_clk)
);

time_register clock_inst(
    .en(enable),
    .clk(clk),
    .military_time(1'h0),

    .set_clk(clk),
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

bcd_segment_mux segment_mux(
    .en(enable),
    .hours_msd(hours_msd),
    .hours_lsd(hours_lsd),
    .minutes_msd(minutes_msd),
    .minutes_lsd(minutes_lsd),
    .seconds_msd(seconds_msd),
    .seconds_lsd(seconds_lsd),
    .segment_select(bcd_select),
    .led_out(led_out)
);

digit_shift_register shift_reg (
    .en(enable),
    .load(sr_load),
    .clk(clk),

    .dp_in(1'h0),
    .led_in(led_out),
    .serial_out(serial_out)
);

always begin
    #1 clk <= ~clk;
end

initial begin
    enable <= 1;
    $dumpfile("shift_register_controller_tb.vcd");
    $dumpvars(0, shift_register_controller_tb);

    repeat (60) begin
        @(negedge clk);
    end

    $finish;
end

endmodule