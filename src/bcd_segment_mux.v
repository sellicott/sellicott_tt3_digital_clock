/* bcd_segment_mux: module to select the outputs from a time_register to a 7-segment output to a 
 * shift register. 
 * author: Samuel Ellicott
 * date: 03-19-23
 */

module bcd_segment_mux (
    input wire en,
    input wire [3:0] hours_msd,
    input wire [3:0] hours_lsd,
    input wire [3:0] minutes_msd,
    input wire [3:0] minutes_lsd,
    input wire [3:0] seconds_msd,
    input wire [3:0] seconds_lsd,
    input wire [2:0] segment_select,

    output wire [6:0] led_out
);

reg [3:0] bcd_int;

bcd_to_7seg inst (
    .en(en),
    .bcd(bcd_int),
    .led_out(led_out)
);

// select between the various time_register segments starting from the least-significant-digit of
// the seconds and working up to the hours most-significant-digit.
always @*
begin
    case(segment_select)
    3'h0: bcd_int <= seconds_lsd;
    3'h1: bcd_int <= seconds_msd;
    3'h2: bcd_int <= minutes_lsd;
    3'h3: bcd_int <= minutes_msd;
    3'h4: bcd_int <= hours_lsd;
    3'h5: bcd_int <= hours_msd;
    // if we aren't one of the predefined outputs, put converter into an "invalid" state so we turn
    // the outputs off. 
    default: bcd_int <= 4'hA;
    endcase
end

endmodule