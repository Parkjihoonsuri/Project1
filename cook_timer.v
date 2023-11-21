`timescale 1ns / 1ps


module cook_timer(
    input clk, reset_p,
    input [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output [7:0] led_bar
    //output [15:0] value,
    //output start_stop
    );
    wire [15:0] value;
    wire start_stop;
    wire [2:0] start, incsec, incmin;
    wire t_start_stop;
    wire alarm_off;
    assign t_start_stop = start ? 1 : (alarm_start ? 1 : 0);                                                //0000으로 초기화 시킴
    
    button_cntr btn_start(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(t_start_stop));
    
    t_flip_flop_p T_up1(.clk(clk), .t(t_start_stop), .reset_p(reset_p), .q(start_stop));
    
    button_cntr btn_incsec(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(incsec));
    button_cntr btn_incmin(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(incmin));
    
    wire [3:0] sec1_set, sec10_set;
    counter_dec_60(.clk(clk), .reset_p(reset_p), .clk_time(incsec), .dec1(sec1_set), .dec10(sec10_set));
    
    wire [3:0] min1_set, min10_set;
    counter_dec_60(.clk(clk), .reset_p(reset_p), .clk_time(incmin), .dec1(min1_set), .dec10(min10_set));
    
    reg [15:0] set_time;
    always@(posedge clk or posedge reset_p)begin
    if(reset_p) set_time = 0;
    else set_time = {8'b0, min10_set, min1_set, sec10_set, sec1_set};
    end
    
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    wire clk_msec;
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));
    wire clk_sec;
    clock_div_1000 sec_clk(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    wire clk_min;
//    clock_min min_clk(.clk(clk), .clk_sec(clk_sec), .reset_p(reset_p), .clk_min(clk_min));
    
    wire clk_start, load_enable;
    wire [3:0] sec1, sec10, dec_clk, min1, min10;
    assign clk_start = start_stop ? clk_sec : 0;
    assign load_enable = ~start_stop ? start : 0;
    
    loadable_down_counter_dec_60 dc_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_start), .load_enable(load_enable),
    .set_value1(sec1_set), .set_value10(sec10_set),
    .dec1(sec1), .dec10(sec10), .dec_clk(dec_clk));
    
    loadable_down_counter_dec_100 dc_min(.clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(load_enable),
    .set_value1(min1_set), .set_value10(min10_set),
    .dec1(min1), .dec10(min10));
    
    reg [15:0] count_time;
    always@(posedge clk or posedge reset_p)begin
    if(reset_p) count_time = 0;
    else count_time = {8'b0, min10, min1, sec10, sec1};
    end
    
    wire timeout, alarm_start;
    assign timeout = |count_time;
    edge_detector_n ed_timeout(.clk(clk), .cp_in(timeout), .reset_p(reset_p), .n_edge(alarm_start));
    
    wire alarm;
    assign alarm_off = |{~btn, reset_p};
    t_flip_flop_p up2(.clk(clk), .t(alarm_start), .reset_p(alarm_off), .q(alarm));
    assign led_bar[0] = alarm;
    

    assign value = start_stop ? count_time : set_time;
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule

module fan_timer(
    input clk, reset_p,
    input [3:0] btn,
    output [3:0] com,
    output [7:0] seg_7
    );


    button_cntr btn_start1(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(start1));

//    always @(posedge clk) begin
//        if (reset_p) count_mode = 0;                // 카운터 리셋
//        else begin 
//            if(start1) count_mode = count_mode + 1;    // 마이크로초 카운트
//            else if(count_mode>=4) count_mode = 0;
//    end
//    end
    reg timer_start;
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    wire clk_msec;
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));
    wire clk_sec;
    clock_div_1000 sec_clk(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    wire clk_min;
    clock_min min_clk(.clk(clk), .clk_sec(clk_sec), .reset_p(reset_p), .clk_min(clk_min));
    wire clock_hour;
    clock_hour hour_clk(.clk(clk), .clk_min(clk_min), .reset_p(reset_p), .clk_hour(clk_hour));
    wire load_enable;
    wire [3:0] hour1, hour10, dec_clk, min1, min10;
    reg [3:0] set_value1;
    loadable_down_counter_dec_60 dc_min1(.clk(clk), .reset_p(reset_p), .clk_time(value), .load_enable(a | b),
    .set_value1(0), .set_value10(0),
    .dec1(min1), .dec10(min10), .dec_clk(dec_clk));
    loadable_down_counter_dec_100 dc_hour1(.clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(a | b),
    .set_value1(set_value1), .set_value10(0),
    .dec1(hour1), .dec10(hour10));
    reg load_enable1;    
    wire [3:0] count_mode;
    reg [15:0] count_time;
    wire timeout, alarm_start;
    assign timeout = |{hour10, hour1, min10, min1};
    edge_detector_n ed_timeout(.clk(clk), .cp_in(timeout), .reset_p(reset_p), .n_edge(alarm_start));
    edge_detector_n ed_load(.clk(clk), .cp_in(load_enable1), .reset_p(reset_p), .n_edge(a), .p_edge(b));
    wire a,b;
    wire alarm;
    assign alarm_off = |{~btn[0], reset_p};
    t_flip_flop_p up2(.clk(clk), .t(alarm_start), .reset_p(alarm_off), .q(alarm));
    assign value = alarm ?  0000 : clk_sec;
    wire [15:0] value1;
    assign value1 = timer_start ? count_time : 0;

    always@(negedge clk or posedge reset_p)begin
    if(reset_p) count_time = 0;
    count_time = {hour10, hour1, min10, min1};
   end
    pwm_ring_counter_pj(.clk(clk), .reset_p(reset_p), .btn(start1), .q(count_mode));
    always @(posedge clk)begin
        case(count_mode)
            4'b0001: begin
            set_value1 = 0;
            timer_start = 0;
            load_enable1 = 1;
            end
            4'b0010: begin
            set_value1 = 1;
            timer_start = 1;
            load_enable1 = 0;
            end
            4'b0100: begin
            set_value1 = 3;
            timer_start = 1;
            load_enable1 = 1;
            end   
            4'b1000: begin
            set_value1 = 5; 
            timer_start = 1;  
            load_enable1 = 0;
            end    
        endcase
    end
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value1), .com(com), .seg_7(seg_7));
endmodule


module fan_timer_fanPJ(
    input clk, reset_p,
    input [3:0] btn,
//    output [3:0] com,
 //   output [7:0] seg_7,
    output [15:0] value1,
    output alarm, 
    output reg timer_start
    );


    button_cntr btn_start1(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(start1));

//    always @(posedge clk) begin
//        if (reset_p) count_mode = 0;                // 카운터 리셋
//        else begin 
//            if(start1) count_mode = count_mode + 1;    // 마이크로초 카운트
//            else if(count_mode>=4) count_mode = 0;
//    end
//    end
    //reg timer_start;
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    wire clk_msec;
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));
    wire clk_sec;
    clock_div_1000 sec_clk(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    wire clk_min;
    clock_min min_clk(.clk(clk), .clk_sec(clk_sec), .reset_p(reset_p), .clk_min(clk_min));
    wire clock_hour;
    clock_hour hour_clk(.clk(clk), .clk_min(clk_min), .reset_p(reset_p), .clk_hour(clk_hour));
    wire load_enable;
    wire [3:0] hour1, hour10, dec_clk, min1, min10;
    reg [3:0] set_value1;
    loadable_down_counter_dec_60 dc_min1(.clk(clk), .reset_p(reset_p), .clk_time(value), .load_enable(a | b),
    .set_value1(0), .set_value10(0),
    .dec1(min1), .dec10(min10), .dec_clk(dec_clk));
    loadable_down_counter_dec_100 dc_hour1(.clk(clk), .reset_p(reset_p), .clk_time(dec_clk), .load_enable(a | b),
    .set_value1(set_value1), .set_value10(0),
    .dec1(hour1), .dec10(hour10));
    
    wire [3:0] count_mode;
    reg [15:0] count_time;
    wire timeout, alarm_start;
    assign timeout = |{hour10, hour1, min10, min1};
    edge_detector_n ed_timeout(.clk(clk), .cp_in(timeout), .reset_p(reset_p), .n_edge(alarm_start));
    edge_detector_n ed_load(.clk(clk), .cp_in(load_enable1), .reset_p(reset_p), .n_edge(a), .p_edge(b));
    wire a,b;
//    wire alarm;
    assign alarm_off = |{~btn[0], reset_p};
    t_flip_flop_p up2(.clk(clk), .t(alarm_start), .reset_p(alarm_off), .q(alarm));
    assign value = alarm ?  0000 : clk_sec;
    //wire [15:0] value1;
    assign value1 = timer_start ? count_time : 0;
    reg load_enable1;
    always@(negedge clk or posedge reset_p)begin
    if(reset_p) count_time = 0;
    count_time = {hour10, hour1, min10, min1};
   end
    pwm_ring_counter_pj(.clk(clk), .reset_p(reset_p), .btn(start1), .q(count_mode));
    always @(posedge clk)begin
        case(count_mode)
            4'b0001: begin
            set_value1 = 0;
            timer_start = 0;
            load_enable1 = 1;
            end
            4'b0010: begin
            set_value1 = 1;
            timer_start = 1;
            load_enable1 = 0;
            end
            4'b0100: begin
            set_value1 = 3;
            timer_start = 1;
            load_enable1 = 1;
            end   
            4'b1000: begin
            set_value1 = 5; 
            timer_start = 1;  
            load_enable1 = 0;
            end    
        endcase
    end
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value1), .com(com), .seg_7(seg_7));
endmodule
