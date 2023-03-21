/* design_wrapper_v1: module to take all the digital inputs/outputs from the tiny-tapeout inputs
 * and give them sensible names for the clock design. Contains all submodules and connects them
 * together.  
 * v2 adds a second time register for an alarm along with circuitry to select whether to display the
 * time or alarm time.
 * author: Samuel Ellicott
 * date: 03-20-23
 */

module design_wrapper_v2 (
    input wire clk,
    
    // clock inputs
    input wire military_time,
    input wire set_fast,
    input wire set_hours,
    input wire set_minutes,
    input wire set_alarm,
    input wire alarm_en,
    input wire alarm_reset,

    output wire serial_out,
    output wire latch_out,
    output wire clk_out,
    output reg  pm,
    output wire set_alarm_out,
    output wire alarm_en_out,
    output wire alarm_beep_out
);

// display wires that go to the output wrapper module
reg [3:0] hours_msd;
reg [3:0] hours_lsd;
reg [3:0] minutes_msd;
reg [3:0] minutes_lsd;
reg [3:0] seconds_msd;
reg [3:0] seconds_lsd;

wire clock_pm;
wire [3:0] clock_hours_msd;
wire [3:0] clock_hours_lsd;
wire [3:0] clock_minutes_msd;
wire [3:0] clock_minutes_lsd;
wire [3:0] clock_seconds_msd;
wire [3:0] clock_seconds_lsd;

// alarm wires
wire alarm_pm;
wire [3:0] alarm_hours_msd;
wire [3:0] alarm_hours_lsd;
wire [3:0] alarm_minutes_msd;
wire [3:0] alarm_minutes_lsd;
wire [3:0] alarm_seconds_msd;
wire [3:0] alarm_seconds_lsd;

always @*
begin
    if (set_alarm)
    begin
        pm <= alarm_pm;
        hours_msd <= alarm_hours_msd;
        hours_lsd <= alarm_hours_lsd;
        minutes_msd <= alarm_minutes_msd;
        minutes_lsd <= alarm_minutes_lsd;
        seconds_msd <= 4'h0;
        seconds_lsd <= 4'h0;
    end
    else
    begin
        pm <= clock_pm;
        hours_msd <= clock_hours_msd;
        hours_lsd <= clock_hours_lsd;
        minutes_msd <= clock_minutes_msd;
        minutes_lsd <= clock_minutes_lsd;
        seconds_msd <= clock_seconds_msd;
        seconds_lsd <= clock_seconds_lsd;
    end
end

// select between setting the alarm or setting the clock
wire alarm_set_hours   = set_alarm ? set_hours   : 1'h0;
wire alarm_set_minutes = set_alarm ? set_minutes : 1'h0;
wire clock_set_hours   = set_alarm ? 1'h0 : set_hours;
wire clock_set_minutes = set_alarm ? 1'h0 : set_minutes;

assign set_alarm_out = set_alarm;
assign alarm_en_out  = alarm_en;

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
    .set_hours(alarm_set_hours),
    .set_minutes(alarm_set_minutes),

    .pm(clock_pm),
    .hours_msd(clock_hours_msd),
    .hours_lsd(clock_hours_lsd),
    .minutes_msd(clock_minutes_msd),
    .minutes_lsd(clock_minutes_lsd),
    .seconds_msd(clock_seconds_msd),
    .seconds_lsd(clock_seconds_lsd)
);

time_register alarm_inst(
    .en(1'h1),
    .clk(1'h0), // disable the main clock so that the value doesn't get updated every second
    .military_time(military_time),

    .set_clk(clk_set_int),
    .set_hours(alarm_set_hours),
    .set_minutes(alarm_set_minutes),

    .pm(alarm_pm),
    .hours_msd(alarm_hours_msd),
    .hours_lsd(alarm_hours_lsd),
    .minutes_msd(alarm_minutes_msd),
    .minutes_lsd(alarm_minutes_lsd),
    .seconds_msd(alarm_seconds_msd),
    .seconds_lsd(alarm_seconds_lsd)
);

clock_alarm alarm_compare (
    .en(alarm_en),
    .clk_fast(clk_sr),
    .clk_1hz(clk_1hz),
    .alarm_reset(alarm_reset),

    // time register inputs
    .clock_pm(clock_pm),
    .clock_hours_msd(clock_hours_msd),
    .clock_hours_lsd(clock_hours_lsd),
    .clock_minutes_msd(clock_minutes_msd),
    .clock_minutes_lsd(clock_minutes_lsd),
    .clock_seconds_msd(clock_seconds_msd),
    .clock_seconds_lsd(clock_seconds_lsd),

    .alarm_pm(alarm_pm),
    .alarm_hours_msd(alarm_hours_msd),
    .alarm_hours_lsd(alarm_hours_lsd),
    .alarm_minutes_msd(alarm_minutes_msd),
    .alarm_minutes_lsd(alarm_minutes_lsd),
    .alarm_seconds_msd(alarm_seconds_msd),
    .alarm_seconds_lsd(alarm_seconds_lsd),

    .output_blank(output_blank), // 0 for blanked display, 1 for enabled display
    .beep(alarm_beep_out)
);

output_wrapper output_inst (
    .en(output_blank),
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