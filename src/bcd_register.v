/* bcd_register: module to store binary-coded-decimal data, stores values between 0 and 9 before
 * rolling over. Has an output port that indicates when a rollover occurs.
 * author: Samuel Ellicott
 * date: 03-17-23
 */

module bcd_register (
    input wire en,
    input wire load,
    input wire clk,
    input wire [3:0] data_in,
    
    output wire overflow,
    output wire [3:0] data_out
);

reg [3:0] data_reg = 0;

// output a '1' on overflow if we are going to overflow next clock cycle
assign overflow = data_reg >= 4'h9;

// outputs always connect to the data register
assign data_out = data_reg;

always @(posedge clk)
begin
    if (en) begin
        if(load) begin
            data_reg <= data_in;
            //$display("loading data_in: %d", data_in);
        end
        else begin
            // reset to 0 if an overflow event is going to happen
            data_reg <= overflow ? 0 : data_reg + 1;
        end
    end
end

endmodule