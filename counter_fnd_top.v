`timescale 1ns / 1ps

module counter_fnd_top(                                          //test
     input clk, reset_p, btn1,
     output [7:0] seg_7,
     output [3:0] com    
);
    
    wire [11:0] count;      
    reg [25:0] clk_div;
//    wire seg_7_font;
    always@(posedge clk) clk_div = clk_div + 1;                   //분주기 클락을 일정주기로 반복시킴
//    assign seg_7 = ~seg_7_font;
    d_flip_flop_p D_flip(.d(btn1), .clk(clk_div[16]), .reset_p(reset_p), .q(up_down));
    wire up_down_p;
//    wire up_down;
    always@(posedge clk) clk_div = clk_div +1;
    edge_detector_n(.clk(clk), .cp_in(up_down), .reset_p(reset_p), .p_edge(up_down_p));
    wire up;
    t_flip_flop_p T_up(.clk(clk), .t(up_down_p), .reset_p(reset_p), .q(up));

    up_down_counter_Nbit_p #(.N(12)) counter_fnd(.clk(clk_div[25]), .reset_p(reset_p), .up_down(~up), .count(count));    //clk_div의 25번째로 지정하여 updown카운터의 주기를 늦게 함

    wire [15:0] dec_value;
    bin_to_dec binto(.bin(count), .bcd(dec_value));

    fnd_4digit_cntr fnd_cntr(.clk(clk), .reset_p(reset_p), .value(dec_value), .com(com), .seg_7(seg_7));

endmodule
