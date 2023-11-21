`timescale 1ns / 1ps

module clock_usec(
    input clk, reset_p,
    output clk_usec
    );
    
    reg [6:0] cnt_8nsec;
    wire cp_usec;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)cnt_8nsec = 0;
        else if(cnt_8nsec >= 124)cnt_8nsec = 0;
        else cnt_8nsec = cnt_8nsec + 1;
    end
    
    assign cp_usec = cnt_8nsec < 63 ? 0 : 1;
    
    edge_detector_n ed0 (.clk(clk), .cp_in(cp_usec), .reset_p(reset_p),
        .n_edge(clk_usec));
    
endmodule

module clock_div_10(
    input clk, clk_source, reset_p,
    output clk_div_10
    );
    
    reg [2:0] cnt_clk_source;
    reg cp_div_10;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)cnt_clk_source = 0;
        else if(clk_source)begin
            if(cnt_clk_source >= 4)begin
                cnt_clk_source = 0;
                cp_div_10 = ~cp_div_10;
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end
    
    edge_detector_n ed0 (.clk(clk), .cp_in(cp_div_10), .reset_p(reset_p),
        .n_edge(clk_div_10));
    
endmodule


module clock_div_1000(
    input clk, clk_source, reset_p,
    output clk_div_1000
    );
    
    reg [8:0] cnt_clk_source;
    reg cp_div_1000;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)cnt_clk_source = 0;
        else if(clk_source)begin
            if(cnt_clk_source >= 499)begin
                cnt_clk_source = 0;
                cp_div_1000 = ~cp_div_1000;
            end
            else cnt_clk_source = cnt_clk_source + 1;
        end
    end
    
    edge_detector_n ed0 (.clk(clk), .cp_in(cp_div_1000), .reset_p(reset_p),
        .n_edge(clk_div_1000));
    
endmodule


module counter_dec_100(
    input clk, reset_p,
    input clk_time,
    output reg [3:0]dec1, dec10
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            dec1 = 0;
            dec10 = 0;
        end
        else if(clk_time)begin
            if(dec1 >= 9)begin
                dec1 = 0;
                if(dec10 >= 9) dec10 = 0;
                else dec10 = dec10 + 1;
            end
            else dec1 = dec1 + 1;
        end
    end

endmodule

module clock_min(
    input clk, clk_sec, reset_p,
    output clk_min
    );
    
    reg[4:0] cnt_sec;
    reg cp_min;
    
    always@(posedge clk or posedge reset_p)begin
    if(reset_p) cnt_sec = 0;
    else if (clk_sec)begin
        if(cnt_sec>=29)begin
            cnt_sec=0;
                 cp_min=~cp_min;
                       end
        else cnt_sec = cnt_sec+1;
        end
    end
    edge_detector_n ed0 (.clk(clk), .cp_in(cp_min), .reset_p(reset_p), .n_edge(clk_min));
endmodule

module clock_hour(
    input clk, clk_min, reset_p,
    output clk_hour
    );
    
    reg[4:0] cnt_min;
    reg cp_hour;
    
    always@(posedge clk or posedge reset_p)begin
    if(reset_p) cnt_min = 0;
    else if (clk_min)begin
        if(cnt_min>=29)begin
            cnt_min=0;
                 cp_hour=~cp_hour;
                       end
        else cnt_min = cnt_min+1;
        end
    end
    edge_detector_n ed0 (.clk(clk), .cp_in(cp_hour), .reset_p(reset_p), .n_edge(clk_hour));
endmodule

module counter_dec_60(
    input clk, reset_p,
    input clk_time,
    output reg [3:0]dec1, dec10
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            dec1 = 0;
            dec10 = 0;
        end
        else if(clk_time)begin
            if(dec1 >= 9)begin
                dec1 = 0;
                if(dec10 >= 5) dec10 = 0;
                else dec10 = dec10 + 1;
            end
            else dec1 = dec1 + 1;
        end
    end

endmodule

module loadable_down_counter_dec_60(
    input clk, reset_p,
    input clk_time, load_enable,
    input [3:0] set_value1, set_value10,
    output reg [3:0]dec1, dec10,
    output reg dec_clk
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            dec1 = 0;
            dec10 = 0;
            dec_clk = 0;
        end
        else if(load_enable)begin
            dec1 = set_value1;
            dec10 = set_value10;
        end
        else if(clk_time)begin
            if(dec1 == 0)begin
                dec1 = 9;
                if(dec10 == 0)begin
                dec10 = 5;
                dec_clk = 1;
            end
            else dec10=dec10 - 1;
            end
            else dec1=dec1-1;
            end
        else dec_clk = 0;
       
        end
endmodule

module loadable_counter_dec_60(
    input clk, reset_p,
    input clk_time, load_enable,
    input [3:0] set_value1, set_value10,
    output reg [3:0]dec1, dec10
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            dec1 = 0;
            dec10 = 0;
        end
        else if(load_enable)begin
            dec1 = set_value1;
            dec10 = set_value10;
        end
        else if(clk_time)begin
            if(dec1 >= 9)begin
                dec1 = 0;
                if(dec10 >= 5) dec10 = 0;
                else dec10 = dec10 + 1;
            end
            else dec1 = dec1 + 1;
        end
    end

endmodule

module loadable_down_counter_dec_100(
    input clk, reset_p,
    input clk_time, load_enable,
    input [3:0] set_value1, set_value10,
    output reg [3:0]dec1, dec10,
    output reg dec_clk
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            dec1 = 0;
            dec10 = 0;
            dec_clk = 0;
        end
        else if(load_enable)begin
            dec1 = set_value1;
            dec10 = set_value10;
        end
        else if(clk_time)begin
            if(dec1 == 0)begin
                dec1 = 9;
                if(dec10 == 0)begin
                dec10 = 9;
                dec_clk = 1;
            end
            else dec10=dec10 - 1;
        end
        else dec1=dec1-1;
        end
        else dec_clk = 0;
        
        
    end
endmodule


module loadable_counter_dec_24(
    input clk, reset_p,
    input clk_time, load_enable,
    input [3:0] set_value1, set_value10,
    output reg [3:0]dec1, dec10
    );

    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            dec1 = 0;
            dec10 = 0;
        end
        else if(load_enable)begin
            dec1 = set_value1;
            dec10 = set_value10;
        end
        else if(clk_time)begin
            if(dec1 >= 9)begin
                dec1 = 0;
                if(dec10 >= 2) dec10 = 0;
                else dec10 = dec10 + 1;
            end
            else if(dec10>=2)begin
                if(dec1>=3)begin 
                dec1=0;
                dec10 = 0;
                end
                else dec1 = dec1 + 1;
            end
            else dec1 = dec1 + 1; 
        end
    end

endmodule