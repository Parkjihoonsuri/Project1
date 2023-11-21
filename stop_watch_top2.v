module stop_watch_top2(
    input clk,
    input reset_p,
    input [1:0] btn,
    output [3:0] com,
    output [7:0] seg_7,
    output [7:0] led_bar
    );
    
    reg[25:0] clk_div;
    wire btn_start, start_stop;
    wire [1:0] debounced_btn;
    always @(posedge clk) clk_div <= clk_div + 1;

    d_flip_flop_p dff0(.d(btn[0]), .clk(clk_div[16]), .reset_p(reset_p), .q(debounced_btn[0]));
    edge_detector_n ed_start(.clk(clk), .cp_in(debounced_btn[0]), .reset_p(reset_p), .p_edge(btn_start));
    t_flip_flop_p (.clk(clk), .t(btn_start), .reset_p(reset_p), .q(start_stop));
    
    wire lap, btn_lap;
    d_flip_flop_p dff1(.d(btn[1]), .clk(clk_div[16]), .reset_p(reset_p), .q(debounced_btn[1]));
    edge_detector_n ed_lap(.clk(clk), .cp_in(debounced_btn[1]), .reset_p(reset_p), .p_edge(btn_lap));
    t_flip_flop_p (.clk(clk), .t(btn_lap), .reset_p(reset_p), .q(lap));
    
    assign led_bar[0] = debounced_btn[1];
    assign led_bar[1] = btn_lap;
    assign led_bar[2] = lap;
    
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    wire clk_msec;

    wire clk_sec;
    
    clock_div_1000 msec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_usec), .clock_div_1000(clk_msec));
    wire clk_sec;
    
    wire clk_start;
    assign clk_start = start_stop ? clk_msec : 0;
    
    clock_div_1000 sec_clk(.clk(clk), .reset_p(reset_p), .clk_source(clk_start), .clock_div_1000(clk_sec));
    wire clk_min;
    clock_min min_clk(.clk(clk), .clk_sec(clk_sec), .reset_p(reset_p), .clk_min(clk_min));

    wire [3:0] sec1, sec10, min1, min10;

    counter_dec_100(.clk(clk), .reset_p(reset_p), .clk_time(clk_sec), .dec1(sec1), .dec10(sec10));
    counter_dec_100(.clk(clk), .reset_p(reset_p), .clk_time(clk_min), .dec1(min1), .dec10(min10));

    reg [15:0] lap_value;
    always @(posedge clk or posedge reset_p) begin
        if (reset_p) lap_value <= 0;
        else if (btn_lap) lap_value <= {sec10, sec1, min10, min1}; // 디스플레이 값을 초와 밀리초로 업데이트
    end

    wire [15:0] value;
    assign value = lap ? lap_value : {sec10, sec1, min10, min1}; // 디스플레이 값을 초와 밀리초로 표시

    fnd_4digit_cntr fnd_cntr(.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule
