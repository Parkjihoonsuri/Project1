`timescale 1ns / 1ps

module pwm_100(
    input clk, reset_p,
    input [6:0] duty,
    input [13:0] pwm_preq,
    output reg pwm_100pc
    );
    
    parameter sys_clk_preq = 125_000_000;
    //reg pwm_100pc;
    reg [26:0] cnt;
    reg clk_preqX100;
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt = 0;
            clk_preqX100 = 0;
        end
        else begin
        if(cnt >= sys_clk_preq/pwm_preq/100/2)begin
        cnt = 0; 
            clk_preqX100 = ~clk_preqX100;
        end
        else begin
            cnt = cnt +1;
        end
        end
        end
        wire clk_preqX100_ne;
        edge_detector_p edge_p(.clk(clk), .cp_in(clk_preqX100), .reset_p(reset_p), .n_edge(clk_preqX100_ne));
        
        reg[6:0] cnt_duty;
        always@(posedge clk or posedge reset_p)begin
            if(reset_p)begin
                cnt_duty = 0;
                pwm_100pc = 0;
            end
            else if(clk_preqX100_ne)begin
                if(cnt_duty >= 99)cnt_duty = 0;
                else cnt_duty = cnt_duty + 1;
                
                if(cnt_duty < duty)pwm_100pc = 1;
                else pwm_100pc = 0;
                end
            end
     
endmodule

module pwm_1000(
    input clk, reset_p,
    input [9:0] duty,
    input [13:0] pwm_preq,
    output reg pwm_1000pc
    );
    
    parameter sys_clk_preq = 125_000_000;

    reg [26:0] cnt;
    reg clk_preqX1000;
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            cnt = 0;
            clk_preqX1000 = 0;
        end
        else begin
        if(cnt >= sys_clk_preq/pwm_preq/1000/2)begin
        cnt = 0; 
            clk_preqX1000 = ~clk_preqX1000;
        end
        else begin
            cnt = cnt +1;
        end
        end
        end
        wire clk_preqX1000_ne;
        edge_detector_p edge_p(.clk(clk), .cp_in(clk_preqX1000), .reset_p(reset_p), .n_edge(clk_preqX1000_ne));
        
        reg[9:0] cnt_duty;
        always@(posedge clk or posedge reset_p)begin
            if(reset_p)begin
                cnt_duty = 0;
                pwm_1000pc = 0;
            end
            else if(clk_preqX1000_ne)begin
                if(cnt_duty >= 999)cnt_duty = 0;
                else cnt_duty = cnt_duty + 1;
                
                if(cnt_duty < duty)pwm_1000pc = 1;
                else pwm_1000pc = 0;
                end
            end
     
endmodule

module led_pwm_top(
    input clk, reset_p,
    output led_b,
    output led_r, led_g
);
    reg [27:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;
    
    wire [6:0] duty;
    pwm_100 pwm_r(.clk(clk), .reset_p(reset_p), .duty({2'b000, clk_div[27:24]}), .pwm_preq(10000), .pwm_100pc(led_r));
    pwm_100 pwm_b(.clk(clk), .reset_p(reset_p), .duty({2'b000, clk_div[26:23]}), .pwm_preq(10000), .pwm_100pc(led_b));
    pwm_100 pwm_g(.clk(clk), .reset_p(reset_p), .duty({2'b000, clk_div[25:22]}), .pwm_preq(10000), .pwm_100pc(led_g));
    
    
endmodule

module led_pwm_top_pj(
    input clk, reset_p,
    input [3:0] btn,
    output led_b,
    output led_r, led_g
);
    wire countbtn;
    reg [6:0] duty;
    reg [1:0] count_mode;
    
    always @(posedge clk)begin
        if(countbtn) count_mode = count_mode + 1;
        case(count_mode)
            0: begin
            duty = 0;
            end
            1: begin
            duty = 35;
            end
            2: begin
            duty = 70;
            end   
            3: begin
            duty = 100;
            end
        endcase
    end

    reg [27:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;
    
    pwm_100 pwm_r(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_preq(10000), .pwm_100pc(led_r));
    pwm_100 pwm_b(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_preq(10000), .pwm_100pc(led_b));
    pwm_100 pwm_g(.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_preq(10000), .pwm_100pc(led_g));
    button_cntr btn_incsec(.clk(clk), .reset_p(reset_p), .btn(btn[2]), .btn_ne(countbtn));
    
endmodule

module servo_pwm_top(
    input clk,           // 클럭 입력
    input reset_p,       // 리셋 입력    
    output pwm_1000pc, // 서보 제어용 PWM 신호
    output [3:0] com,
    output [7:0] seg_7
);

    reg [9:0] duty;
    
    reg [27:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;

    pwm_1000 pwm_inst (
        .clk(clk),
        .reset_p(reset_p),
        .duty(duty),
        .pwm_preq(50), 
        .pwm_1000pc(pwm_1000pc)
    );
    wire clk_div_21_ne;
    edge_detector_n ed_start0(.clk(clk), .cp_in(clk_div[21]), .reset_p(reset_p), .n_edge(clk_div_21_ne));
    reg down_up;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            duty = 20;
            down_up = 0; 
        end
        else if(clk_div_21_ne)begin
            if(down_up)begin
                if(duty < 20)down_up = 0; 
                else duty = duty - 1;
            end
            else begin
                if(duty > 200)down_up = 1;
                else duty = duty + 1;
            end
        end
    end
    wire [15:0] bcd_duty;
    bin_to_dec btd(.bin(duty), .bcd(bcd_duty));
    fnd_4digit_cntr fnd_cntr(.clk(clk), .reset_p(reset_p), .value(bcd_duty), .com(com), .seg_7(seg_7));
endmodule

module motor_pwm_top(
    input clk,           // 클럭 입력
    input reset_p,       // 리셋 입력    
    output pwm_100pc, // 서보 제어용 PWM 신호
    output [3:0] com,
    output [7:0] seg_7
);

    reg [9:0] duty;
    
    reg [28:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;

    pwm_100 pwm_inst (.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_preq(100), .pwm_100pc(pwm_100pc));
    wire clk_div_21_ne;
    edge_detector_n ed_start0(.clk(clk), .cp_in(clk_div[28]), .reset_p(reset_p), .n_edge(clk_div_21_ne));
    reg down_up;
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            duty = 0;
            down_up = 0; 
        end
        else if(clk_div_21_ne)begin
            if(down_up)begin
                if(duty < 1)down_up = 0; 
                else duty = duty - 1;
            end
            else begin
                if(duty > 100)down_up = 1;
                else duty = duty + 1;
            end
        end
    end
    wire [15:0] bcd_duty;
    bin_to_dec btd(.bin(duty), .bcd(bcd_duty));
    fnd_4digit_cntr fnd_cntr(.clk(clk), .reset_p(reset_p), .value(bcd_duty), .com(com), .seg_7(seg_7));
endmodule

module motor_pwm_top_pj(
    input clk, reset_p,
    input [3:0] btn,
    output pwm_100pc

);
    reg [6:0] duty;
    reg [1:0] count_mode;
    reg [15:0] count_time;
    always@(posedge clk or posedge reset_p)begin
    if(reset_p) count_time = 0;
    end
    always @(posedge clk)begin
        if(countbtn) count_mode = count_mode + 1;
        case(count_mode)
            0: begin
            duty = 0;
            end
            1: begin
            duty = 35;
            end
            2: begin
            duty = 70;
            end   
            3: begin
            duty = 100;
            end
        endcase
    end
    wire countbtn;
    reg [27:0] clk_div;
    always@(posedge clk)clk_div = clk_div + 1;
    
    pwm_100 pwm_inst (.clk(clk), .reset_p(reset_p), .duty(duty), .pwm_preq(100), .pwm_100pc(pwm_100pc));
    button_cntr btn_incsec(.clk(clk), .reset_p(reset_p), .btn(btn[1]), .btn_ne(countbtn));
    
endmodule