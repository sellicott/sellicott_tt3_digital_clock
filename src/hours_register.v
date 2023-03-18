/* hours_register.v: module to store binary-coded-decimal hours data. 
 * rolls over when a count of '12' or '24' is reached depending on the 'military_time' signal. 
 * every other 12 hour cycle, the pm output will be toggled.
 * author: Samuel Ellicott
 * date: 03-17-23
 */

module hours_register (
    input wire en,
    input wire clk,
    input wire military_time,
    
    output wire pm,
    output wire [3:0] data_msd,
    output wire [3:0] data_lsd
);

wire lsd_overflow;
wire msd_enable = (lsd_overflow || hours_overflow) && en;
wire msd_overflow = military_time ? (data_msd >= 4'h2) : (data_msd >=4'h1);
wire hours_overflow = msd_overflow && (military_time ? (data_lsd >= 3) : (data_lsd >= 2));

wire en_lsd = en || (data_msd == 4'h0 && data_lsd == 4'h0);

reg pm_reg = 0;
assign pm = military_time ? 1'h0 : pm_reg;

always @(posedge clk)
begin
    if (en)
    begin
        if (military_time)
        begin
            pm_reg <= data_msd >= 4'h2;
        end
        else if (hours_overflow)
        begin
            pm_reg <= ~pm_reg;
        end
    end
end

bcd_register bcd_msd_inst (
    .en(msd_enable),
    .load(hours_overflow),
    .clk(clk),
    .data_in(4'h0),
    .data_out(data_msd)
);

bcd_register bcd_lsd_inst (
    .en(en_lsd),
    .load(hours_overflow),
    .clk(clk),
    .data_in(4'h1),
    .overflow(lsd_overflow),
    .data_out(data_lsd)
);

endmodule