/* clock_divider_tb: testbench for the clock divider module. 
 * author: Samuel Ellicott
 * date: 03-20-23
 */

`timescale 10us/10us
module clock_divider_tb;

reg clk = 0;
wire clk_sr;
wire clk_set;
wire clk_1hz;

clock_divider clk_div (
    .clk(clk),
    .clk_sr(clk_sr),
    .clk_set(clk_set),
    .clk_1hz(clk_1hz)
);

always begin
    #4 clk <= ~clk;
end

initial begin
    $dumpfile("clock_divider_tb.vcd");
    $dumpvars(0, clock_divider_tb);

    repeat (8) begin
        repeat (50) begin
            repeat (125) begin
                @(negedge clk);
            end
        end
    end

    $finish;
end

endmodule