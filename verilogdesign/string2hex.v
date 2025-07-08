`timescale 1ns / 1ps
module string2hex (
    input [3:0] ascii_str,   // 7 characters * 8 bits = 56 bits
    output reg [63:0] hex_out
);


always @(*) begin
    hex_out = 64'd0;

    // Assign each byte manually
    hex_out[63:56] = {7'b0000000,ascii_str[3]}; // Byte 0
    hex_out[55:48] = {7'b0000000,ascii_str[2]}; // Byte 1
    hex_out[47:40] = {7'b0000000,ascii_str[1]}; // Byte 2
    hex_out[39:32] = {7'b0000000,ascii_str[0]}; // Byte 3
    hex_out[31:24] = 8'h00; // Byte 4
    hex_out[23:16] = 8'h00;  // Byte 5
    hex_out[15:8]  = 8'h00;   // Byte 6

    // Append 0x80 at the end (Byte 7)
    hex_out[7:0] = 8'h80;
end

endmodule
