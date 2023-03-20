/* clock_divider: module to divide the 12.5KHz clock and produce a 4-5Hz and 1Hz clock
 * author: Samuel Ellicott
 * date: 03-20-23
 */

module clock_divider (
    input wire clk,
    output wire clk_sr,
    output wire clk_set,
    output wire clk_1hz
);


reg [6:0] main_div = 0;
reg [3:0] second_div = 0;
reg [2:0] clk_set_div = 0;

reg clk_50hz = 0;
reg clk_5hz_reg = 0;
reg clk_1hz_reg = 0;

assign clk_sr = clk;
assign clk_set = clk_5hz_reg;
assign clk_1hz = clk_1hz_reg;

always @(negedge clk)
begin
    if (main_div == 7'd124)
    begin
        main_div <= 7'h0;
        clk_50hz <= ~clk_50hz;
    end
    else
    begin
        main_div <= main_div + 1'h1;
    end
end

always @(negedge clk_50hz)
begin
    if (second_div == 4'd4)
    begin
        second_div <= 4'h0;
        clk_5hz_reg <= ~clk_5hz_reg;
    end
    else
    begin
        second_div <= second_div + 1'h1;
    end
end

always @(negedge clk_5hz_reg)
begin
    if (clk_set_div == 3'd4)
    begin
        clk_set_div <= 3'h0;
    end
    else
    begin
        clk_set_div <= clk_set_div + 1'h1;
    end
end

reg trig_on = 0;
reg trig_off = 0;

wire trig_2hz = trig_on || trig_off;

always @(posedge clk_set)
begin
    trig_on <= (clk_set_div == 3'd2);
end

always @(negedge clk_set)
begin
    trig_off <= (clk_set_div == 3'd4);
end


always @(posedge trig_2hz)
begin
    clk_1hz_reg <= ~clk_1hz_reg;
end

endmodule