`timescale 1ns / 1ps

module button_cntr(
    input clk, reset_p,
    input btn,
    output btn_pe, btn_ne
    );
    
    reg [16:0] clk_div = 0;                                 //시뮬레이션 아니면 0초기화안됨
    always@(posedge clk) clk_div = clk_div +1;
    
    wire debounced_btn;
    d_flip_flop_p db(.d(btn), .clk(clk_div[16]), .reset_p(reset_p), .q(debounced_btn));
    edge_detector_n ed_btn(.clk(clk), .cp_in(debounced_btn), .reset_p(reset_p), .p_edge(btn_pe), .n_edge(btn_ne));

    
endmodule
