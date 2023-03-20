/* sellicott_digital_clock: top level module for tiny-tapeout, instantiates the design wrapper
 * and connects it to the tiny-tapeout names
 * author: Samuel Ellicott
 * date: 03-20-23
 */

module sellicott_digital_clock (
    input  wire [7:0] io_in,
    output wire [7:0] io_out
);

design_wrapper_v1 digital_clock(
    .clk(io_in[0]),
    
    // clock inputs
    .military_time(io_in[1]),
    .set_fast(io_in[2]),
    .set_hours(io_in[3]),
    .set_minutes(io_in[4]),

    .serial_out(io_out[0]),
    .latch_out(io_out[1]),
    .clk_out(io_out[2]),
    .pm(io_out[3])
);

endmodule