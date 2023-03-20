/* bcd_to_7seg_tb: Module to test the bcd to 7-segment decoder, cycle through all segments
 * author: Samuel Ellicott
 * date: 03-04-23
 */

`define default_netname none
`timescale 1ns/100ps

module shift_register_tb;

reg  [2:0] bcd_select = 0;
reg enable = 0;

wire [6:0] led_out;

wire pm;
wire [3:0] hours_msd;
wire [3:0] hours_lsd;
wire [3:0] minutes_msd;
wire [3:0] minutes_lsd;
wire [3:0] seconds_msd;
wire [3:0] seconds_lsd;

// make a counter to go through all the 4-bit numbers
reg clk = 0;
reg clk_slow = 0;

reg [3:0] sr_count = 0;

always @(posedge clk) begin
    if (sr_count == 4'h8)
    begin
        sr_count <= 1'h0;
        clk_slow <= ~clk_slow;
    end
    else
    begin
        sr_count <= sr_count + 1'h1;
    end
end

always @(posedge clk_slow) begin
    if (bcd_select == 3'h5)
        bcd_select <= 3'h0;
    else
        bcd_select <= bcd_select + 3'h1;
end

time_register clock_inst(
    .en(enable),
    .clk(clk_slow),
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

wire load = sr_count == 4'h7;
digit_shift_register shift_reg (
    .en(enable),
    .load(load),
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
    $dumpfile("shift_register_tb.vcd");
    $dumpvars(0, shift_register_tb);

    // display the time register value on every change
    $monitor("time, pm, %d, %d, %d%d:%d%d.%d%d",
        $time, pm, hours_msd, hours_lsd, minutes_msd, minutes_lsd, seconds_msd, seconds_lsd);

    repeat (60) begin
        @(negedge clk_slow);
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