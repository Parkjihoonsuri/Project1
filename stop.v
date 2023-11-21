module stop_watch_top(
    input clk,
    input reset_p,
    input [1:0] btn,
    output [3:0] com,
    output [7:0] seg_7
    );

    reg [16:0] clk_div;
    wire btn_start, start_stop;
    wire [1:0] debounced_btn; // 바운싱제거 
    always @(posedge clk) clk_div = clk_div + 1;
    
    d_flip_flop_p dff0 (.d(btn[0]), .clk(clk_div[16]), .reset_p(reset_p), .q(debounced_btn[0])); 
    edge_detector_n ed_start( .clk(clk), .cp_in(debounced_btn[0]), .reset_p(reset_p), .n_edge(btn_start));
    t_flip_flop_p tff0(.clk(clk),.t(btn_start), .reset_p(reset_p), .q(start_stop));
        // 버튼입력하면 dff으로 바운싱 제거 tff으로 출력 토글
    //Btn[0] 멈춤,작동
    
    wire lap, btn_lap;
    d_flip_flop_p dff1 (.d(btn[1]), .clk(clk_div[16]), .reset_p(reset_p), .q(debounced_btn[1])); 
    edge_detector_n ed_lap( .clk(clk), .cp_in(debounced_btn[1]), .reset_p(reset_p), .n_edge(btn_lap));
    t_flip_flop_p tff1(.clk(clk),.t(btn_lap), .reset_p(reset_p), .q(lap));
    //Lap버튼btn[1] = 누르면 값저장하고 스탑워치멈춤(내부에선스탑워치계속돌아감) 다시누르면 돌아가던 스탑워치값 표시
    
    wire clk_usec, clk_msec, clk_sec;
    clock_usec(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
     wire clk_start;
    assign clk_start = start_stop ? clk_usec : 0;
    clock_div_1000(.clk(clk), .clk_source(clk_start), .reset_p(reset_p), .clk_div_1000(clk_msec));
    clock_div_1000(.clk(clk), .clk_source(clk_msec), .reset_p(reset_p), .clk_div_1000(clk_sec));
    
    wire [3:0] msec1, msec10 , sec1 , sec10 ,msec100;
    counter_dec_100(.clk(clk), .reset_p(reset_p),.clk_time(clk_msec), .dec1(msec1), .dec10(msec10), .dec100(msec100));
    counter_dec_60(.clk(clk), .reset_p(reset_p),.clk_time(clk_sec), .dec1(sec1), .dec10(sec10));
    reg [15:0] lap_value;
    always @(posedge clk or posedge reset_p) begin
        if(reset_p) lap_value =0;
        else if(btn_lap) lap_value = {sec10,sec1,msec100,msec10};
    end
    wire [15:0] value;
    assign value = lap ? lap_value : {sec10,sec1,msec100,msec10};
    
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
endmodule