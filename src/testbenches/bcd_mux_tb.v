/* bcd_to_7seg_tb: Module to test the bcd to 7-segment decoder, cycle through all segments
 * author: Samuel Ellicott
 * date: 03-04-23
 */

`define default_netname none
`timescale 1ns/100ps

module bcd_mux_tb;

reg  [2:0] bcd_select = 0;
reg        enable     = 0;

wire [6:0] led_out;

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


// make a counter to go through all the 4-bit numbers
reg clk = 0;
always @(posedge clk) begin
    if (bcd_select == 5)
        bcd_select <= 0;
    else
        bcd_select <= bcd_select + 1;
end

always begin
    #1 clk <= ~clk;
end

initial begin
    enable <= 1;
    $dumpfile("bcd_mux_tb.vcd");
    $dumpvars(0, bcd_mux_tb);

    // display the time register value on every change
    $monitor("time, pm, %d, %d, %d%d:%d%d.%d%d",
        $time, pm, hours_msd, hours_lsd, minutes_msd, minutes_lsd, seconds_msd, seconds_lsd);

    repeat (60) begin
        @(negedge clk);
        display_7seg(led_out);
    end

    $finish;
end

reg [7:0] f_seg;
reg [7:0] b_seg;

reg [7:0] e_seg;
reg [7:0] c_seg;

task display_7seg(input [7:0] led_out);
begin
    c_seg = " ";
    b_seg = " ";
    e_seg = " ";
    f_seg = " ";

    if (led_out & (1 << 5)) b_seg = "x";
    if (led_out & (1 << 4)) c_seg = "x";
    if (led_out & (1 << 1)) f_seg = "x";
    if (led_out & (1 << 2)) e_seg = "x";

    $display("bcd_segment: %d\n", bcd_select);

    if (led_out & (1 << 6))
        $display(" xxx ");
    else
        $display("     ");
    
    $display("%s   %s", f_seg, b_seg);
    $display("%s   %s", f_seg, b_seg);

    if (led_out & (1 << 0))
        $display(" xxx ");
    else
        $display("     ");
    
    $display("%s   %s", e_seg, c_seg);
    $display("%s   %s", e_seg, c_seg);

    if (led_out & (1 << 3))
        $display(" xxx ");
    else
        $display("     ");
end
endtask

endmodule