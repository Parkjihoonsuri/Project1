`timescale 1ns / 1ps

module Multi_fan_top(
    input clk, reset_p, echo,
    input [3:0] btn, 
    inout dht11_data, 
    output led_b, led_r, led_g,
    output [3:0] com,
    output [7:0] seg_7,
    output pwm_100pc,
    output trigger
    );
    reg ultrastop;
    wire [15:0] distance;
    always@(posedge clk)begin
    if(distance>=50)ultrastop=1;
    else ultrastop = 0;
    end
    wire [15:0] value1;
    wire [7:0] humidity, temperature;
    DHT11 dht(.clk(clk), .reset_p(reset_p), .dht11_data(dht11_data), .humidity(humidity), .temperature(temperature));
    
    wire [15:0] bcd_humi, bcd_tmpr;
    bin_to_dec binto1(.bin({4'b0000, humidity}), .bcd(bcd_humi));
    bin_to_dec binto2(.bin({4'b0000, temperature}), .bcd(bcd_tmpr));
    wire [15:0] fnd_value;
    assign fnd_value = timer_start ? value1 : value;
    wire [15:0] value;
    assign value = {bcd_humi[7:0], bcd_tmpr[7:0]};
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(fnd_value), .com(com), .seg_7(seg_7));
    wire timer_start;
    ultrasonic distance_check(.clk(clk), .reset_p(reset_p), .echo(echo), .trigger(trigger), .distance_cm(distance));
    led_pwm_top_pj(.clk(clk), .reset_p(reset_p), .btn(btn[3:0]), .led_b(led_b), .led_r(led_r), .led_g(led_g));
    motor_pwm_top_pj(.clk(clk), .reset_p(reset_p|alarm|ultrastop), .btn(btn[3:0]), .pwm_100pc(pwm_100pc));
    fan_timer(.clk(clk), .reset_p(reset_p), .btn(btn[3:0]), .value1(value1), .alarm(alarm), .timer_start(timer_start));
endmodule