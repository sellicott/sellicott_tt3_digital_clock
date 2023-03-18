/* bcd_register_tb.v: Module to test the bcd register, cycle through all values and load some values
 * author: Samuel Ellicott
 * date: 03-17-23
 */


`define default_netname none
`timescale 1ns/100ps

module hours_register_tb;

reg enable = 0;
reg load   = 0;
reg clk    = 0;

reg military_time = 0;

wire [3:0] msd_hours;
wire [3:0] lsd_hours;
wire pm;

hours_register2 hour_reg_inst(
    .en(enable),
    .clk(clk),
    .military_time(military_time),

    .pm(pm),
    .data_msd(msd_hours),
    .data_lsd(lsd_hours)
);


always begin
    #1 clk <= ~clk;
end

initial begin
    // dump stuff to a vcd file
    $dumpfile("hours_register_tb.vcd");
    $dumpvars(0, hours_register_tb);

    $monitor("time, pm, hours %d, %d, %d%d", $time, pm, msd_hours, lsd_hours);

    $display("Data hold Test");
    enable = 0;
    military_time = 0;
    repeat (10) begin
        @(negedge clk);
    end

    $display("12H time test");
    enable = 1;
    repeat (24) begin
        @(negedge clk);
    end

    $display("\n24H Time Test");
    enable = 1;
    military_time = 1;
    repeat (24) begin
        @(negedge clk);
    end

    $display("\nTest switching between 12H and 24H time");
    repeat (3) begin
        @(negedge clk);
    end
    $display("Switch to 12H time");
    military_time = 0;
    repeat (1) begin
        @(negedge clk);
    end
    $display("Switch to 24H time");
    military_time = 1;

    repeat (12) begin
        @(negedge clk);
    end
    $display("Switch to 12H time");
    military_time = 0;
    repeat (1) begin
        @(negedge clk);
    end
    $display("Switch to 24H time");
    military_time = 1;
    repeat (12) begin
        @(negedge clk);
    end
    $display("Switch to 12H time");
    military_time = 0;
    repeat (1) begin
        @(negedge clk);
    end
    
    $finish;
end

endmodule
