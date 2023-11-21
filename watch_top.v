`timescale 1ns / 1ps

module watch_top(
    input reset_p,
    input clk, [3:0] btn,
    output [3:0] com,
    output [7:0] seg_7
    );
    t_flip_flop_p T_up1(.clk(clk), .t(t_start_stop), .reset_p(reset_p), .q(start_stop));
    
    wire [2:0] start, incsec, incmin;
    button_cntr btn_incsec(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(incsec));
    button_cntr btn_incmin(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(incmin));
    wire clk_sec, clk_min;
    
    assign sec_or = clk_sec ? 1 : incsec ? 1 : 0;
    assign min_or = clk_min ? 1 : incmin ? 1 : 0;
    
    
    wire [3:0] sec1_set, sec10_set;
    counter_dec_60(.clk(clk), .reset_p(reset_p), .clk_time(sec_or), .dec1(sec1_set), .dec10(sec10_set));
    
    wire [3:0] min1_set, min10_set;
    counter_dec_60(.clk(clk), .reset_p(reset_p), .clk_time(min_or), .dec1(min1_set), .dec10(min10_set));
    
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
    clock_min min_clk(.clk(clk), .clk_sec(sec_or), .reset_p(reset_p), .clk_min(clk_min));
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(set_time), .com(com), .seg_7(seg_7));
    
endmodule


module watch_top_loadadder(
    input reset_p,
    input clk, [3:0] btn,
    output [3:0] com,
    output [7:0] seg_7
    );
    
    wire incsec, incmin;
    wire set_mode, btn_set_pe;
    button_cntr btn_start(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_set_pe));
    button_cntr btn_incsec(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(incsec));
    button_cntr btn_incmin(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(incmin));
    t_flip_flop_p tff_mode(.clk(clk), .t(btn_set_pe), .reset_p(reset_p), .q(set_mode));
    
    wire clk_sec, clk_min;
    
    wire [3:0] sec1_set, sec10_set;
    loadable_counter_dec_60 counter_sec(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .dec1(sec1), .dec10(sec10), .load_enable(btn_set_pe), .set_value1(sec1_set), .set_value10(sec10_set));
    
    wire [3:0] min1_set, min10_set;
    loadable_counter_dec_60 counter_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), .dec1(min1), .dec10(min10), .load_enable(btn_set_pe), .set_value1(min1_set), .set_value10(min10_set));
    
    wire [3:0] sec1, sec10;
    loadable_counter_dec_60 set_sec(.clk(clk), .reset_p(reset_p), .clk_time(incsec), .dec1(sec1_set), .dec10(sec10_set), .load_enable(btn_set_pe), .set_value1(sec1), .set_value10(sec10));
    
    wire [3:0] min1, min10;
    loadable_counter_dec_60 set_min(.clk(clk), .reset_p(reset_p), .clk_time(incmin), .dec1(min1_set), .dec10(min10_set), .load_enable(btn_set_pe), .set_value1(min1), .set_value10(min10));
    
    wire [15:0] cur_time, set_time;
    assign cur_time = {min10, min1, sec10, sec1};
    assign set_time = {min10_set, min1_set, sec10_set, sec1_set};
    wire [15:0] value;
    assign value = set_mode ? set_time : cur_time;
    
    wire upcount_sec;
    assign upcount_sec = set_mode ? incsec : clk_sec;
    
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    wire clk_msec;
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));
    wire clk_sec;
    clock_div_1000 sec_clk(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    wire clk_min;
    clock_min min_clk(.clk(clk), .clk_sec(upcount_sec), .reset_p(reset_p), .clk_min(clk_min));
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule

module watch_top_hour_min_change(
    input reset_p,
    input clk, [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output [15:0] value,
    output set_mode
    );
    
    wire inchour, incmin;
//    wire set_mode; 
    wire btn_set_pe;
    button_cntr btn_start(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_set_pe));
    button_cntr btn_inchour(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(inchour));
    button_cntr btn_incmin(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(incmin));
    t_flip_flop_p tff_mode(.clk(clk), .t(btn_set_pe), .reset_p(reset_p), .q(set_mode));
    
    wire clk_hour, clk_min;
    
    wire [3:0] hour1_set, hour10_set;
    loadable_counter_dec_24 counter_hour(.clk(clk), .reset_p(reset_p), .clk_time(clk_hour), .dec1(hour1), .dec10(hour10), .load_enable(btn_set_pe), .set_value1(hour1_set), .set_value10(hour10_set));
    
    wire [3:0] min1_set, min10_set;
    loadable_counter_dec_60 counter_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), .dec1(min1), .dec10(min10), .load_enable(btn_set_pe), .set_value1(min1_set), .set_value10(min10_set));
    
    wire [3:0] hour1, hour10;
    loadable_counter_dec_24 set_hour(.clk(clk), .reset_p(reset_p), .clk_time(inchour), .dec1(hour1_set), .dec10(hour10_set), .load_enable(btn_set_pe), .set_value1(hour1), .set_value10(hour10));
    
    wire [3:0] min1, min10;
    loadable_counter_dec_60 set_min(.clk(clk), .reset_p(reset_p), .clk_time(incmin), .dec1(min1_set), .dec10(min10_set), .load_enable(btn_set_pe), .set_value1(min1), .set_value10(min10));
    
    wire [15:0] cur_time, set_time;
    assign cur_time = {hour10, hour1, min10, min1};
    assign set_time = {hour10_set, hour1_set, min10_set, min1_set};

    assign value = set_mode ? set_time : cur_time;
    
    wire upcount_min;
    assign upcount_min = set_mode ? incmin : clk_min;
    
    wire clk_hour;
    clock_hour hour_clk(.clk(clk), .clk_min(upcount_min), .reset_p(reset_p), .clk_hour(clk_hour));
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    wire clk_msec;
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));
    wire clk_sec;
    clock_div_1000 sec_clk(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    wire clk_min;
    clock_min min_clk(.clk(clk), .clk_sec(clk_sec), .reset_p(reset_p), .clk_min(clk_min));
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule

module watch_top_hour_min_135timer(
    input reset_p,
    input clk, [2:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output [15:0] value,
    output set_mode
    );
    
    wire inchour, incmin;
//    wire set_mode; 
    wire btn_set_pe;
    button_cntr btn_start(.clk(clk), .reset_p(reset_p), .btn(btn[0]), .btn_ne(btn_set_pe));
    button_cntr btn_inchour(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(inchour));
    button_cntr btn_incmin(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(incmin));
    t_flip_flop_p tff_mode(.clk(clk), .t(btn_set_pe), .reset_p(reset_p), .q(set_mode));
    
    wire clk_hour, clk_min;
    
    wire [3:0] hour1_set, hour10_set;
    loadable_counter_dec_24 counter_hour(.clk(clk), .reset_p(reset_p), .clk_time(clk_hour), .dec1(hour1), .dec10(hour10), .load_enable(btn_set_pe), .set_value1(hour1_set), .set_value10(hour10_set));
    
    wire [3:0] min1_set, min10_set;
    loadable_counter_dec_60 counter_min(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), .dec1(min1), .dec10(min10), .load_enable(btn_set_pe), .set_value1(min1_set), .set_value10(min10_set));
    
    wire [3:0] hour1, hour10;
    loadable_counter_dec_24 set_hour(.clk(clk), .reset_p(reset_p), .clk_time(inchour), .dec1(hour1_set), .dec10(hour10_set), .load_enable(btn_set_pe), .set_value1(hour1), .set_value10(hour10));
    
    wire [3:0] min1, min10;
    loadable_counter_dec_60 set_min(.clk(clk), .reset_p(reset_p), .clk_time(incmin), .dec1(min1_set), .dec10(min10_set), .load_enable(btn_set_pe), .set_value1(min1), .set_value10(min10));
    
    wire [15:0] cur_time, set_time;
    assign cur_time = {hour10, hour1, min10, min1};
    assign set_time = {hour10_set, hour1_set, min10_set, min1_set};

    assign value = set_mode ? set_time : cur_time;
    
    wire upcount_min;
    assign upcount_min = set_mode ? incmin : clk_min;
    
    wire clk_hour;
    clock_hour hour_clk(.clk(clk), .clk_min(upcount_min), .reset_p(reset_p), .clk_hour(clk_hour));
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    wire clk_msec;
    clock_div_1000 msec_clk(.clk(clk), .clk_source(clk_usec), .reset_p(reset_p), .clk_div_1000(clk_msec));
    wire clk_sec;
    clock_div_1000 sec_clk(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    wire clk_min;
    clock_min min_clk(.clk(clk), .clk_sec(clk_sec), .reset_p(reset_p), .clk_min(clk_min));
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule