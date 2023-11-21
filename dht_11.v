`timescale 1ns / 1ps

module DHT11(
    input clk, reset_p, 
    inout dht11_data, 
    output reg [7:0] humidity, temperature,
    output reg [7:0] led_bar
    );
    
    parameter S_IDLE = 6'b000001;                                   //S=STATE
    parameter S_LOW_18MS= 6'b000010;
    parameter S_HIGH_20US= 6'b000100;
    parameter S_LOW_80US= 6'b001000;
    parameter S_HIGH_80US= 6'b010000;
    parameter S_READ_DATA= 6'b100000;
    
    parameter S_WAIT_PEDGE = 2'b01;
    parameter S_WAIT_NEDGE = 2'b10;
    
    reg [21:0] count_usec;                                          //3sec = 22bit 3u = 3,000,000
    
    reg count_usec_e;
    wire clk_usec;
    clock_usec usec_clk(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p) count_usec = 0;
        else begin
            if(clk_usec && count_usec_e) count_usec = count_usec + 1;
            else if(!count_usec_e) count_usec = 0;
        end
    end
    
    wire dht_pedge, dht_nedge;
    edge_detector_n edge0(.clk(clk), .cp_in(dht11_data), .reset_p(reset_p), .n_edge(dht_nedge), .p_edge(dht_pedge));
    
    reg [5:0] state, next_state;
    reg [1:0] read_state;
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)state = S_IDLE;
        else state = next_state;
    end
   
   reg dht11_buffer;
   assign dht11_data = dht11_buffer; 
   
   reg[39:0] temp_data;
   reg[5:0] data_count;
   always@(posedge clk or posedge reset_p)begin
        if(reset_p)begin
            count_usec_e = 0;
            next_state = S_IDLE;
            dht11_buffer = 1'bz;
            read_state = S_WAIT_PEDGE;
            data_count = 0;
            led_bar = 8'b1111_1111;
        end
        else begin
            case(state)
                S_IDLE : begin
                    if(count_usec < 22'd3_000_000)begin            //3,000,000
                        count_usec_e = 1;
                        dht11_buffer = 1'bz;
                        led_bar[0] = 0;
                    end
                    else begin
                        next_state = S_LOW_18MS;
                        count_usec_e = 0;
                        led_bar = 8'b1111_1111;
                    end
                end
                S_LOW_18MS : begin
                    led_bar[1] = 0;
                    if(count_usec < 22'd19_999)begin
                        count_usec_e = 1;
                        dht11_buffer = 0;
                    end
                    else begin
                        count_usec_e = 0;
                        next_state = S_HIGH_20US;
                        dht11_buffer = 1'bz;
                    end
                end
                S_HIGH_20US : begin
                    led_bar[2] = 0;
                    if(count_usec < 70)begin
                        dht11_buffer = 1'bz;
                        count_usec_e = 1;
                        if(dht_nedge)begin
                            next_state = S_LOW_80US;
                            count_usec_e = 0;
                        end
                    end
                    else begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                end
                S_LOW_80US : begin
                    led_bar[3] = 0;
                    if(count_usec < 90)begin
                        if(dht_pedge)begin
                            next_state = S_HIGH_80US;
                            count_usec_e = 0;
                        end
                        else begin
                        next_state = S_LOW_80US;
                        count_usec_e = 1;
                        end
                    end
                    else begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                    end
                    S_HIGH_80US : begin
                    led_bar[4] = 0;
                    if(count_usec < 90)begin
                        if(dht_nedge)begin
                            next_state = S_READ_DATA;
                            count_usec_e = 0;
                        end
                        else begin
                        next_state = S_HIGH_80US;
                        count_usec_e = 1;
                        end
                    end
                    else begin
                        next_state = S_IDLE;
                        count_usec_e = 0;
                    end
                    end
                    S_READ_DATA : begin
                    led_bar[5] = 0;
                        case(read_state)
                            S_WAIT_PEDGE : begin
                                led_bar[6] = 0;
                                if(dht_pedge)begin
                                    read_state = S_WAIT_NEDGE;
                                    count_usec_e = 1;
                                end
                                else begin
                                    count_usec_e = 0;
                                end
                            end
                            S_WAIT_NEDGE : begin
                                led_bar[7] = 0;
                                if(dht_nedge)begin
                                    data_count = data_count + 1;
                                    read_state = S_WAIT_PEDGE;
                                    if(count_usec < 50)begin
                                        temp_data = {temp_data[38:0], 1'b0};
                                    end
                                    else begin
                                        temp_data = {temp_data[38:0], 1'b1};
                                    end
                                end
                                else begin
                                    count_usec_e = 1;
                                    read_state = S_WAIT_NEDGE;
                                end
                            end
                            default : read_state = S_WAIT_PEDGE;
                        endcase
                        if(data_count >= 40)begin
                            data_count = 0;
                            next_state = S_IDLE;
                            if(temp_data[39:32] + temp_data[31:24] + temp_data[23:16] + temp_data[15:8] == temp_data[7:0])begin         //error cheak  
                            humidity = temp_data[39:32];
                            temperature = temp_data[23:16];
                            end
                        end
                end
                default : next_state = S_IDLE;
            endcase
        end
    end
endmodule