/* bcd_to_7seg_tb: Module to test the bcd to 7-segment decoder, cycle through all segments
 * author: Samuel Ellicott
 * date: 03-04-23
 */

`define default_netname none
`timescale 1ns/100ps

module bcd_to_7seg_tb;

reg  [3:0] bcd_reg = 0;
reg        enable  = 0;

wire [6:0] led_out;


bcd_to_7seg inst (
    .bcd(bcd_reg),
    .en(enable),
    .led_out(led_out)
);

// make a counter to go through all the 4-bit numbers
reg clk = 0;
always @(posedge clk) begin
    bcd_reg <= bcd_reg + 1;
end

always begin
    #1 clk <= ~clk;
end

initial begin
    enable <= 1;

    repeat (16) begin
        @(posedge clk);
        display_7seg(led_out);
    end

    // enable <= 0;
    
    // repeat (16) begin
    //     @(posedge clk);
    //     display_7seg;
    // end
    $finish;
end

/* 
 *   aaa
 *  f   b
 *  f   b
 *   ggg
 *  e   c
 *  e   c
 *   ddd  
 */
task write_header;
begin
    $display("   aaa ");
    $display("  f   b");
    $display("  f   b");
    $display("   ggg ");
    $display("  e   c");
    $display("  e   c");
    $display("   ddd ");
    $display("\nvalue, segments");
    $display("     abcdefg");
    $monitor("0x%h, %b", bcd_reg, led_out);
end
endtask

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

    $display("\nbcd: %d", bcd_reg);
    $display("led_out: %b\n", led_out);

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