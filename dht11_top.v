`timescale 1ns / 1ps

module dht11_top(
    
    input clk, reset_p, 
    inout dht11_data, 
    output [3:0] com,
    output [7:0] seg_7,
    output [7:0] led_bar
    );
    
    
    wire [7:0] humidity, temperature;
    DHT11 dht(.clk(clk), .reset_p(reset_p), .dht11_data(dht11_data), .humidity(humidity), .temperature(temperature), .led_bar(led_bar));
    
    wire [15:0] bcd_humi, bcd_tmpr;
    bin_to_dec binto1(.bin({4'b0000, humidity}), .bcd(bcd_humi));
    bin_to_dec binto2(.bin({4'b0000, temperature}), .bcd(bcd_tmpr));
    
    wire [15:0] value;
    assign value = {bcd_humi[7:0], bcd_tmpr[7:0]};
    fnd_4digit_cntr fnd_cntr (.clk(clk), .reset_p(reset_p), .value(value), .com(com), .seg_7(seg_7));
    
endmodule