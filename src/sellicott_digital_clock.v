/* sellicott_digital_clock: top level module for tiny-tapeout, instantiates the design wrapper
 * and connects it to the tiny-tapeout names
 * author: Samuel Ellicott
 * date: 03-20-23
 */

module sellicott_digital_clock (
    input  wire [7:0] io_in,
    output wire [7:0] io_out
);

assign io_out[7] = 1'h0;

design_wrapper_v2 digital_clock(
    .clk(io_in[0]),
    
    // clock inputs
    .military_time(io_in[1]),
    .set_fast(io_in[2]),
    .set_hours(io_in[3]),
    .set_minutes(io_in[4]),
    .set_alarm(io_in[5]),
    .alarm_en(io_in[6]),
    .alarm_reset(io_in[7]),

    // clock outputs
    .serial_out(io_out[0]),
    .latch_out(io_out[1]),
    .clk_out(io_out[2]),
    .pm(io_out[3]),
    .set_alarm_out(io_out[4]),
    .alarm_en_out(io_out[5]),
    .alarm_beep_out(io_out[6])
);

// design_wrapper_v1 digital_clock(
//     .clk(io_in[0]),
    
//     // clock inputs
//     .military_time(io_in[1]),
//     .set_fast(io_in[2]),
//     .set_hours(io_in[3]),
//     .set_minutes(io_in[4]),

//     .serial_out(io_out[0]),
//     .latch_out(io_out[1]),
//     .clk_out(io_out[2]),
//     .pm(io_out[3])
// );

endmodule