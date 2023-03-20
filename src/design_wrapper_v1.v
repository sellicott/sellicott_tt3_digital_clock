/* design_wrapper_v1: module to take all the digital inputs/outputs from the tiny-tapeout inputs
 * and give them sensible names for the clock design. Contains all submodules and connects them
 * together.  
 * author: Samuel Ellicott
 * date: 03-20-23
 */

module design_wrapper_v1 (
    input wire clk,
    
    // clock inputs
    input wire military_time,
    input wire set_fast,
    input wire set_hours,
    input wire set_minutes,

    output wire serial_out,
    output wire latch_out,
    output wire clk_out
);

wire pm;
wire [3:0] hours_msd;
wire [3:0] hours_lsd;
wire [3:0] minutes_msd;
wire [3:0] minutes_lsd;
wire [3:0] seconds_msd;
wire [3:0] seconds_lsd;

wire clk_sr;
wire clk_set;
wire clk_1hz;

wire clk_set_int = set_fast ? clk_set : clk_1hz;

clock_divider clk_div (
    .clk(clk),
    .clk_sr(clk_sr),
    .clk_set(clk_set),
    .clk_1hz(clk_1hz)
);

time_register clock_inst(
    .en(1'h1),
    .clk(clk_1hz),
    .military_time(military_time),

    .set_clk(clk_set_int),
    .set_hours(set_hours),
    .set_minutes(set_minutes),

    .pm(pm),
    .hours_msd(hours_msd),
    .hours_lsd(hours_lsd),
    .minutes_msd(minutes_msd),
    .minutes_lsd(minutes_lsd),
    .seconds_msd(seconds_msd),
    .seconds_lsd(seconds_lsd)
);

output_wrapper output_inst (
    .en(1'h1),
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
endmodule