`timescale 1ns / 1ps
module fnd_4digit_cntr(                                        //fnd ���
    input clk, reset_p,
    input [15:0] value,
    output [3:0] com,
    output [7:0] seg_7
    );
    
    reg [16:0] clk_1ms;
//    wire [7:0] seg_7_temp;
    always@(posedge clk) clk_1ms = clk_1ms + 1;
    
    ring_counter_fnd ring_counter(.clk(clk_1ms[16]), .com(com));//.reset_p(reset_p), .com(com));
    
    reg [3:0] hex_value;
       
    decoder_7seg decoder(.hex_value(hex_value), .seg_7(seg_7));
//    assign seg_7 = ~seg_7_temp;                                           //seg_7���� �������� �ֱ����Ͽ� wire[7:0] seg_7_temp���ְ� assign���� �����ָ� ��.
    always@(posedge clk)begin
        case(com)
        4'b1110: hex_value = value[15:12];
        4'b1101: hex_value = value[11:8];
        4'b1011: hex_value = value[7:4];
        4'b0111: hex_value = value[3:0];
        endcase
    end 
    
endmodule

module fnd_4digit_cntr_4bitcalculator(                                        //fnd ���
    input clk, reset_p,
    input [15:0] value,
    output [3:0] com,
    output [7:0] seg_7
    );
    
    reg [16:0] clk_1ms;
//    wire [7:0] seg_7_temp;
    always@(posedge clk) clk_1ms = clk_1ms + 1;
    
    ring_counter_fnd ring_counter(.clk(clk_1ms[16]), .com(com));//.reset_p(reset_p), .com(com));
    
    reg [3:0] hex_value;
       
    decoder_7seg_4bitcalculator decoder(.hex_value(hex_value), .seg_7(seg_7));
//    assign seg_7 = ~seg_7_temp;                                           //seg_7���� �������� �ֱ����Ͽ� wire[7:0] seg_7_temp���ְ� assign���� �����ָ� ��.
    always@(posedge clk)begin
        case(com)
        4'b1110: hex_value = value[15:12];
        4'b1101: hex_value = value[11:8];
        4'b1011: hex_value = value[7:4];
        4'b0111: hex_value = value[3:0];
        endcase
    end 
    
endmodule
