/* clock_alarm: module to generate alarm signals (display blanking, beeping, etc) by comparing
 * the time and the alarm setting, will produce alarm for 5-minutes or the alarm is reset, whatever
 * is shorter. 
 * author: Samuel Ellicott
 * date: 03-20-23
 */

module clock_alarm (
    input wire en,
    input wire clk_fast,
    input wire clk_1hz,
    input wire alarm_reset,

    // time register inputs
    input wire clock_pm,
    input wire [3:0] clock_hours_msd,
    input wire [3:0] clock_hours_lsd,
    input wire [3:0] clock_minutes_msd,
    input wire [3:0] clock_minutes_lsd,
    input wire [3:0] clock_seconds_msd,
    input wire [3:0] clock_seconds_lsd,

    input wire alarm_pm,
    input wire [3:0] alarm_hours_msd,
    input wire [3:0] alarm_hours_lsd,
    input wire [3:0] alarm_minutes_msd,
    input wire [3:0] alarm_minutes_lsd,
    input wire [3:0] alarm_seconds_msd,
    input wire [3:0] alarm_seconds_lsd,

    output wire output_blank, // 0 for blanked display, 1 for enabled display
    output wire beep
);

wire pm_equal      = (clock_pm == alarm_pm);
wire hours_equal   = (clock_hours_msd == alarm_hours_msd) && (clock_hours_lsd == alarm_hours_lsd);
wire minutes_equal = (clock_minutes_msd == alarm_minutes_msd) 
                  && (clock_minutes_lsd == alarm_minutes_lsd);

wire alarm_trigger = pm_equal && hours_equal && minutes_equal;
wire alarm_on;

reg clk_2hz = 0;

always @(posedge clk_1hz)
begin
    clk_2hz <= ~clk_2hz;
end

// if the alarm module is not enabled, never blank the display
assign output_blank = (alarm_on && clk_2hz) || ~en;

// if the alarm module is not enabled, never beep
// TODO make the beep something more reasonable like 880 Hz
assign beep = alarm_on && (clk_fast && clk_2hz) || en;

alarm_countdown timer(
    .en(en),
    .start(alarm_trigger),
    .reset(alarm_reset),
    .clk_1hz(clk_1hz),
    .alarm(alarm_on)
);

endmodule

module alarm_countdown (
    input wire en,
    input wire start,
    input wire reset,
    input wire clk_1hz,

    output wire alarm
);

reg [5:0] seconds_reg = 0;
reg [2:0] minutes_reg = 0;
wire seconds_overflow = seconds_reg == 6'd59;
reg running = 0;
assign alarm = running;

// block for the seconds register
always @(posedge clk_1hz, posedge reset, posedge start)
begin
    if(reset)
    begin
        seconds_reg <= 6'h0;
    end
    else if(en && running)
    begin
        if (seconds_reg >= 59 )
            seconds_reg <= 6'h0;
        else
            seconds_reg <= seconds_reg + 1'h1;
    end
    else if(en && start)
    begin
        seconds_reg <= 6'h0;
    end
    else
    begin
        seconds_reg <= 6'h0;
    end
end

// block for the minutes register
always @(posedge seconds_overflow, posedge reset, posedge start)
begin
    if(reset)
    begin
        minutes_reg <= 3'h0; 
    end
    else if(en && running)
    begin
        if (minutes_reg > 3'h0)
            minutes_reg <= minutes_reg - 1'h1;
        else
            minutes_reg <= 3'h0;
    end
    else if(en && start)
    begin
        minutes_reg <= 3'h5; 
    end
    else
    begin
        minutes_reg <= 3'h0;
    end
end

// block for the running register
always @(posedge seconds_overflow, posedge reset, posedge start)
begin
    if (reset)
    begin
        running <= 1'h0;
    end
    else if(en && running && seconds_overflow)
    begin
        if(minutes_reg == 0)
            running <= 1'h0;
    end
    else if(en && start)
    begin
        running <= 1'h1;
    end
    else
    begin
        running <= 1'h0;
    end
end

endmodule