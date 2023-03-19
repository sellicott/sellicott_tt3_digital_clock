/* minutes_seconds_register: module to store binary-coded-decimal seconds and minutes data. 
 * rolls over when a count of '59' is reached and signals an overflow. Has two bcd segments as outputs
 * author: Samuel Ellicott
 * date: 03-17-23
 */

module minutes_seconds_register (
    input wire en,
    input wire clk,
    
    output wire overflow,
    output wire [3:0] data_msd,
    output wire [3:0] data_lsd
);

wire lsd_overflow;
wire msd_enable = (lsd_overflow && en);
wire msd_overflow = data_msd >= 4'h5;
assign overflow = msd_overflow && lsd_overflow;

bcd_register bcd_msd_inst (
    .en(msd_enable),
    .load(overflow),
    .clk(clk),
    .data_in(4'h0),
    .data_out(data_msd)
);

bcd_register bcd_lsd_inst (
    .en(en),
    .load(1'h0),
    .clk(clk),
    .data_in(4'h0),
    .overflow(lsd_overflow),
    .data_out(data_lsd)
);

endmodule