`timescale 1ns / 1ps

module Multi_timer_PJ(
    input clk, reset_p,
    input [3:0] btn,
    output [3:0] com,
    output [7:0] seg_7, 
    output reg led_r, led_g, led_b
    );
    wire set_mode, start_stop;
    wire lap1;
    watch_top_hour_min_change(.clk(clk), .reset_p(reset_p1), .btn(btn1[3:0]), .value(watch_value) , .set_mode(set_mode));
    cook_timer(.clk(clk), .reset_p(reset_p2), .btn(btn2[3:0]), .value(cook_timer_value), .start_stop(start_stop1));
    stop_watch_top(.clk(clk), .reset_p(reset_p3), .btn(btn3[3:0]), .value(stop_watch_value), .lap(lap1));
    
    wire [15:0] watch_value;
    wire [15:0] cook_timer_value;
    wire [15:0] stop_watch_value;
    reg [1:0] count_mode;
    
button_cntr btn_start(.clk(clk), .reset_p(reset_p), .btn(btn[3]), .btn_ne(mode_change));

    reg reset_p1;
    reg reset_p2;
    reg reset_p3;
    
    reg [3:0] btn1;
    reg [3:0] btn2;
    reg [3:0] btn3;
    always @(negedge clk) begin
        //if (reset_p) count_mode = 0;                // 카운터 리셋
        //else begin 
            if(mode_change) count_mode = count_mode + 1;    // 마이크로초 카운트
            else if(count_mode>=3) count_mode = 0;
    end
    
    wire led_r1, led_b1, led_g1;
    
    reg [15:0] value;
    always @(posedge clk)begin
        case(count_mode)
            0: begin
            value = watch_value;
            btn1 = btn;
            reset_p1 = reset_p;
            if(!set_mode)begin
            led_r = 1;
            led_g = 0;
            led_b = 0;
            end
            else if(set_mode)begin 
            led_r= led_r1;
            led_b= 0;
            led_g= 0;
            end
            end
            1: begin
            value = cook_timer_value;
            btn2 = btn;
            reset_p2 = reset_p;
            if(!start_stop1)begin
            led_r = 0;
            led_g = 1;
            led_b = 0;
            end
            else if(start_stop1)begin 
            led_r= 0;
            led_b= 0;
            led_g= led_g1;
            end
            end
            2: begin
            value = stop_watch_value;
            btn3 = btn;
            reset_p3 = reset_p;
                if(!lap1)begin
                led_r = 0;
                led_g = 0;
                led_b = 1;
                end
                else if(lap1)begin 
                led_r= 0;
                led_b= led_b1;
                led_g= 0;
                end
            end           
        endcase
    end
    
    reg [27:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;
    
    wire [6:0] duty;
    pwm_100 pwm_r(.clk(clk), .reset_p(reset_p), .duty({2'b00, clk_div[27:23]}), .pwm_preq(10000), .pwm_100pc(led_r1));
    pwm_100 pwm_b(.clk(clk), .reset_p(reset_p), .duty({2'b00, clk_div[27:23]}), .pwm_preq(10000), .pwm_100pc(led_b1));
    pwm_100 pwm_g(.clk(clk), .reset_p(reset_p), .duty({2'b00, clk_div[27:23]}), .pwm_preq(10000), .pwm_100pc(led_g1));
    
fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule