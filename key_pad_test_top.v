`timescale 1ns / 1ps

module key_pad_test_top(
    input clk, reset_p,
    input [3:0] row,
    output [3:0] col,
    output [3:0] com,
    output [7:0] seg_7
    );
    
    wire [3:0] key_value;
    wire key_valid;
    key_pad_cntr(clk, reset_p, row, col, key_value, key_valid);
    reg [15:0] value;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            value = 0;
        end
        else if(key_valid)begin
            value = key_value;
        end
    end
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule
