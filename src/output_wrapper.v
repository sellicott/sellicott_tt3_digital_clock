/* output_wrapper: module to take a time register input and generate serialized output data
 * enable signal will blank the led outputs (shift register will always shift out 0's)
 * author: Samuel Ellicott
 * date: 03-20-23
 */

module output_wrapper (
    input wire en,
    input wire sr_clk,

    input wire [3:0] hours_msd,
    input wire [3:0] hours_lsd,
    input wire [3:0] minutes_msd,
    input wire [3:0] minutes_lsd,
    input wire [3:0] seconds_msd,
    input wire [3:0] seconds_lsd,

    output wire serial_out,
    output wire latch_out,
    output wire clk_out
);

wire [6:0] led_out;
wire [2:0] bcd_select;
wire sr_load;

shift_register_controller sr_controller (
    .en(1'h1),
    .clk(sr_clk),

    .bcd_select(bcd_select),
    .sr_load(sr_load),

    .ext_latch(latch_out),
    .ext_clk(clk_out)
);

bcd_segment_mux segment_mux(
    .en(en),
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
    .en(1'h1),
    .load(sr_load),
    .clk(sr_clk),

    .dp_in(1'h0),
    .led_in(led_out),
    .serial_out(serial_out)
);

endmodule