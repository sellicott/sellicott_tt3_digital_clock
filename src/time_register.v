/* time_register: module to store binary-coded-decimal time data. 
 * Hours and minutes can be set independently using the various time-set modes
 * Hours count can be switched between 12h/24h modes using military_time input.
 * When setting the hours/minutes, they use the "set_clk" input as a clock so that the values can be
 * updated more quickly than by just using the standard 1Hz clock input.
 * author: Samuel Ellicott
 * date: 03-18-23
 */

 module time_register (
    input wire en,
    input wire clk,
    input wire military_time,

    input wire set_clk,
    input wire set_hours,
    input wire set_minutes,
    
    output wire pm,
    output wire [3:0] hours_msd,
    output wire [3:0] hours_lsd,
    output wire [3:0] minutes_msd,
    output wire [3:0] minutes_lsd,
    output wire [3:0] seconds_msd,
    output wire [3:0] seconds_lsd
 );

wire minutes_overflow;
wire seconds_overflow_int;
// don't "double add" to the minutes register when we are setting it
wire seconds_overflow = seconds_overflow_int && ~set_minutes;

// disable the hours count from incrimenting from a minutes rollover when setting the hours value 
wire hours_enable   = (set_hours   || (minutes_overflow && seconds_overflow && ~set_minutes)) && en;
wire minutes_enable = (set_minutes || seconds_overflow) && en;

// select the appropriate clock when setting the register
wire hours_clk    = set_hours   ? set_clk : clk;
wire minutes_clk  = set_minutes ? set_clk : clk;

hours_register2 hour_reg_inst(
    .en(hours_enable),
    .clk(hours_clk),
    .military_time(military_time),

    .pm(pm),
    .data_msd(hours_msd),
    .data_lsd(hours_lsd)
);

minutes_seconds_register minutes_register (
    .en(minutes_enable),
    .clk(minutes_clk),
    .overflow(minutes_overflow),
    .data_msd(minutes_msd),
    .data_lsd(minutes_lsd)
);

minutes_seconds_register seconds_register (
    .en(en),
    .clk(clk),
    .overflow(seconds_overflow_int),
    .data_msd(seconds_msd),
    .data_lsd(seconds_lsd)
);

 endmodule