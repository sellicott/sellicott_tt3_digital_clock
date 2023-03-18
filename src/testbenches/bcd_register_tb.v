/* bcd_register_tb.v: Module to test the bcd register, cycle through all values and load some values
 * author: Samuel Ellicott
 * date: 03-17-23
 */


`define default_netname none
`timescale 1ns/100ps

module bcd_register_tb;

reg  [3:0] bcd_in0 = 0;
reg  [3:0] bcd_in1 = 0;

reg enable = 0;
reg load   = 0;
reg clk    = 0;

wire [3:0] bcd_out0;
wire [3:0] bcd_out1;
wire bcd0_overflow;
wire bcd1_overflow;

wire bcd1_enable = (bcd0_overflow && enable) || load;

bcd_register bcd_reg0_inst (
    .en(enable),
    .load(load),
    .clk(clk),
    .data_in(bcd_in0),
    .overflow(bcd0_overflow),
    .data_out(bcd_out0)
);

bcd_register bcd_reg1_inst (
    .en(bcd1_enable),
    .load(load),
    .clk(clk),
    .data_in(bcd_in1),
    .overflow(bcd1_overflow),
    .data_out(bcd_out1)
);


always begin
    #1 clk <= ~clk;
end

initial begin
    // dump stuff to a vcd file
    $dumpfile("bcd_register_tb.vcd");
    $dumpvars(0, bcd_register_tb);

    $monitor("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    $monitor("bcd1_enable %d, bcd_in0, bcd_in1: %d, %d", bcd1_enable, bcd_in0, bcd_in1);

    $display("Data hold Test");
    enable = 0;
    repeat (10) begin
        @(negedge clk);
        $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    end
    $display("Previous result should be 0, 0\n");

    $display("Data Count Test");
    enable = 1;
    repeat (100) begin
        @(negedge clk);
        $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    end
    
    @(negedge clk);
    $display("\nHold test 2");
    // load some values into the registers
    load = 1;
    enable = 1;
    bcd_in0 = 4'h3;
    bcd_in1 = 4'h2;
    @(negedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    load = 0;
    enable = 0;
    @(negedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    $display("Data should be 3, 2 for two cycles\n");

    @(negedge clk);
    load = 1;
    enable = 1;
    bcd_in0 = 4'h9;
    bcd_in1 = 4'h0;
    @(negedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    load = 0;
    enable = 0;
    @(negedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    enable = 1;
    @(negedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    $display("Data should be 9, 0, then 0, 0\n");

    @(negedge clk);
    load = 1;
    enable = 1;
    bcd_in0 = 4'h9;
    bcd_in1 = 4'h9;
    @(negedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    load = 0;
    enable = 0;
    @(negedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    enable = 1;
    @(posedge clk);
    $display("time, bcd_out0, bcd_out1: %d, %d, %d", $time, bcd_out0, bcd_out1);
    $display("Data should be 9, 9, then 0, 0\n");

    // enable <= 0;
    
    // repeat (16) begin
    //     @(posedge clk);
    //     display_7seg;
    // end
    $finish;
end

endmodule
