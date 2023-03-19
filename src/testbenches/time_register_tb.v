/* bcd_register_tb.v: Module to test the bcd register, cycle through all values and load some values
 * author: Samuel Ellicott
 * date: 03-17-23
 */


`define default_netname none
`timescale 1ns/100ps

module time_register_tb;

reg enable = 0;
reg load   = 0;
reg clk    = 0;

reg military_time = 0;

reg set_hours = 0;
reg set_minutes = 0;

wire pm;

wire [3:0] hours_msd;
wire [3:0] hours_lsd;
wire [3:0] minutes_msd;
wire [3:0] minutes_lsd;
wire [3:0] seconds_msd;
wire [3:0] seconds_lsd;

time_register clock_inst(
    .en(enable),
    .clk(clk),
    .military_time(military_time),

    .set_clk(clk),
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


always begin
    #1 clk <= ~clk;
end

initial begin
    // dump stuff to a vcd file
    $dumpfile("time_register_tb.vcd");
    $dumpvars(0, time_register_tb);

    $monitor("time, pm, %d, %d, %d%d:%d%d",
        $time, pm, hours_msd, hours_lsd, minutes_msd, minutes_lsd);

    $display("Data hold Test");
    enable = 0;
    military_time = 0;
    repeat (10) begin
        @(negedge clk);
    end

    $display("12H time test");
    enable = 1;
    repeat (24) begin
        repeat(60) begin
            repeat(60) begin
                @(negedge clk);
            end
        end
    end

    $display("\n24H Time Test");
    enable = 1;
    military_time = 1;
    repeat (24) begin
        repeat(60) begin
            repeat(60) begin
                @(negedge clk);
            end
        end
    end

    $display("\nTest setting minutes");
    set_minutes = 1;
    repeat (7) begin
        @(negedge clk);
    end
    set_minutes = 0;
    repeat(60) begin
        repeat(60) begin
            @(negedge clk);
        end
    end
    set_minutes = 1;
    repeat (1) begin
        @(negedge clk);
    end
    set_minutes = 0;

    $display("\nTest setting Hours");
    set_hours = 1;
    repeat (7) begin
        @(negedge clk);
    end
    set_hours = 0;
    repeat(60) begin
        repeat(60) begin
            @(negedge clk);
        end
    end
    set_hours = 1;
    repeat (1) begin
        @(negedge clk);
    end
    set_hours = 0;
    
    $finish;
end

endmodule
