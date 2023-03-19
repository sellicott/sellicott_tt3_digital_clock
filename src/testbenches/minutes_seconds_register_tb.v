/* bcd_register_tb.v: Module to test the bcd register, cycle through all values and load some values
 * author: Samuel Ellicott
 * date: 03-17-23
 */


`define default_netname none
`timescale 1ns/100ps

module minutes_seconds_register_tb;

reg enable = 0;
reg load   = 0;
reg clk    = 0;

wire [3:0] msd_minutes;
wire [3:0] lsd_minutes;
wire [3:0] msd_seconds;
wire [3:0] lsd_seconds;

wire minutes_overflow;
wire seconds_overflow;
wire minutes_enable = seconds_overflow && enable;

minutes_seconds_register minutes_register (
    .en(minutes_enable),
    .clk(clk),
    .overflow(minutes_overflow),
    .data_msd(msd_minutes),
    .data_lsd(lsd_minutes)
);

minutes_seconds_register seconds_register (
    .en(enable),
    .clk(clk),
    .overflow(seconds_overflow),
    .data_msd(msd_seconds),
    .data_lsd(lsd_seconds)
);


always begin
    #1 clk <= ~clk;
end

initial begin
    // dump stuff to a vcd file
    $dumpfile("minutes_seconds_register_tb.vcd");
    $dumpvars(0, minutes_seconds_register_tb);

    $monitor("time, minutes.seconds %d, %d%d.%d%d", $time, msd_minutes, lsd_minutes, msd_seconds, lsd_seconds);

    $display("Data hold Test");
    enable = 0;
    repeat (10) begin
        @(negedge clk);
    end
    $display("Previous result should be 0, 0\n");

    $display("Data Count Test");
    enable = 1;
    repeat (60) begin
        repeat (60) begin
            @(negedge clk);
        end
    end
    
    $finish;
end

endmodule
