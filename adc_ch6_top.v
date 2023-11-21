`timescale 1ns / 1ps

module adc_ch6_top(
    input clk, reset_p,
    input vauxp6, vauxn6,
    output [3:0] com,
    output [7:0] seg_7
    );
    
    wire [4:0] channel_out;
    wire [15:0] do_out;
    wire eoc_out;
    xadc_wiz_1 adc_ch6(
          .daddr_in({2'b00, channel_out}),            // Address bus for the dynamic reconfiguration port
          .dclk_in(clk),             // Clock input for the dynamic reconfiguration port
          .den_in(eoc_out),              // Enable Signal for the dynamic reconfiguration port
          //di_in,               // Input data bus for the dynamic reconfiguration port
          //dwe_in,              // Write Enable for the dynamic reconfiguration port
          .reset_in(1'b0),            // Reset signal for the System Monitor control logic
          .vauxp6(vauxp6),              // Auxiliary channel 6
          .vauxn6(vauxn6),
//          busy_out,            // ADC Busy signal
          .channel_out(channel_out),         // Channel Selection Outputs
          .do_out(do_out),              // Output data bus for dynamic reconfiguration port
//          drdy_out,            // Data ready signal for the dynamic reconfiguration port
          .eoc_out(eoc_out)             // End of Conversion Signal
//          eos_out,             // End of Sequence Signal
//          alarm_out,           // OR'ed output of all the Alarms    
//          vp_in,               // Dedicated Analog Input Pair
//          vn_in
            );
    wire eoc_out_pe;  
    reg [11:0] adc_value;      
    edge_detector_n ed_eoc(.clk(clk), .cp_in(eoc_out), .reset_p(reset_p), .p_edge(eoc_out_pe));
    always@(posedge clk)begin
        if(eoc_out_pe) adc_value = {2'b00,do_out[15:6]};
    end
            
    wire [15:0] bcd_adc;
    bin_to_dec btd(.bin(adc_value), .bcd(bcd_adc));
    fnd_4digit_cntr fnd_cntr(.clk(clk), .reset_p(reset_p), .value(bcd_adc), .com(com), .seg_7(seg_7));
endmodule
