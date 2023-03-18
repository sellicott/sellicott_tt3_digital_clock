/* hours_register.v: module to store binary-coded-decimal hours data. 
 * rolls over when a count of '12' or '24' is reached depending on the 'military_time' signal. 
 * every other 12 hour cycle, the pm output will be toggled.
 * author: Samuel Ellicott
 * date: 03-17-23
 */

module hours_register2 (
    input wire en,
    input wire clk,
    input wire military_time,
    
    output wire pm,
    output wire [3:0] data_msd,
    output wire [3:0] data_lsd
);

wire [3:0] data_msd_int;
wire [3:0] data_lsd_int;

wire lsd_overflow;
wire msd_overflow = data_msd_int >= 4'h2;
wire hours_overflow = msd_overflow && data_lsd_int >= 3;
wire msd_enable = (lsd_overflow || hours_overflow) && en;

bcd_register bcd_msd_inst (
    .en(msd_enable),
    .load(hours_overflow),
    .clk(clk),
    .data_in(4'h0),
    .data_out(data_msd_int)
);

bcd_register bcd_lsd_inst (
    .en(en),
    .load(hours_overflow),
    .clk(clk),
    .data_in(4'h0),
    .overflow(lsd_overflow),
    .data_out(data_lsd_int)
);

wire [5:0] hour_concat_in  = {data_msd_int[1:0], data_lsd_int};
reg [6:0] hour_concat_out = 0;

assign pm = hour_concat_out[6];
assign data_msd = {2'h0, hour_concat_out[5:4]};
assign data_lsd = hour_concat_out[3:0];

always @*
begin
    if (military_time)
    begin
        hour_concat_out <= {1'h0, data_msd_int[1:0], data_lsd_int};
    end
    else
    begin
        case (hour_concat_in)
        // AM
        6'h00 : hour_concat_out <= {1'h0, 2'h1, 4'h2};
        6'h01 : hour_concat_out <= {1'h0, 2'h0, 4'h1};
        6'h02 : hour_concat_out <= {1'h0, 2'h0, 4'h2};
        6'h03 : hour_concat_out <= {1'h0, 2'h0, 4'h3};
        6'h04 : hour_concat_out <= {1'h0, 2'h0, 4'h4};
        6'h05 : hour_concat_out <= {1'h0, 2'h0, 4'h5};
        6'h06 : hour_concat_out <= {1'h0, 2'h0, 4'h6};
        6'h07 : hour_concat_out <= {1'h0, 2'h0, 4'h7};
        6'h08 : hour_concat_out <= {1'h0, 2'h0, 4'h8};
        6'h09 : hour_concat_out <= {1'h0, 2'h0, 4'h9};
        6'h10 : hour_concat_out <= {1'h0, 2'h1, 4'h0};
        6'h11 : hour_concat_out <= {1'h0, 2'h1, 4'h1};
        // PM
        6'h12 : hour_concat_out <= {1'h1, 2'h1, 4'h2};
        6'h13 : hour_concat_out <= {1'h1, 2'h0, 4'h1};
        6'h14 : hour_concat_out <= {1'h1, 2'h0, 4'h2};
        6'h15 : hour_concat_out <= {1'h1, 2'h0, 4'h3};
        6'h16 : hour_concat_out <= {1'h1, 2'h0, 4'h4};
        6'h17 : hour_concat_out <= {1'h1, 2'h0, 4'h5};
        6'h18 : hour_concat_out <= {1'h1, 2'h0, 4'h6};
        6'h19 : hour_concat_out <= {1'h1, 2'h0, 4'h7};
        6'h20 : hour_concat_out <= {1'h1, 2'h0, 4'h8};
        6'h21 : hour_concat_out <= {1'h1, 2'h0, 4'h9};
        6'h22 : hour_concat_out <= {1'h1, 2'h1, 4'h0};
        6'h23 : hour_concat_out <= {1'h1, 2'h1, 4'h1};
        default: hour_concat_out <= {1'h0, 2'h0, 4'h0};
        endcase
    end
end

endmodule