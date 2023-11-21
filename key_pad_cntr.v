`timescale 1ns / 1ps

module key_pad_cntr(
     input clk, reset_p,
     input [3:0] row,
     output reg [3:0] col,
     output reg [3:0] key_value,
     output reg key_valid
    );
        
        reg [19:0] clk_div;
        always@(posedge clk) clk_div = clk_div + 1;
        
        wire clk_8msec;
        edge_detector_n edge0(.clk(clk), .cp_in(clk_div[19]), .reset_p(reset_p), .n_edge(clk_8msec));
        
        parameter SCAN_0 = 5'b00001;
        parameter SCAN_1 = 5'b00010;
        parameter SCAN_2 = 5'b00100;
        parameter SCAN_3 = 5'b01000;
        parameter KEY_PROCESS = 5'b10000;
        
        reg [4:0] state, next_state;
        
        always@(posedge clk or posedge reset_p)begin
            if(reset_p) state = SCAN_0;
            else if(clk_8msec) state = next_state;
        end
        
        always@* begin  //*쓰면 조합회로 이다, case문 쓰면 mux 조합회로이다
            case(state)
                SCAN_0 : begin
                    if(row != 4'b1111) next_state = KEY_PROCESS;
                    else next_state = SCAN_1;
                end
                SCAN_1 : begin
                    if(row != 4'b1111) next_state = KEY_PROCESS;
                    else next_state = SCAN_2;
                end
                SCAN_2 : begin
                    if(row != 4'b1111) next_state = KEY_PROCESS;
                    else next_state = SCAN_3;
                end
                SCAN_3 : begin
                    if(row != 4'b1111) next_state = KEY_PROCESS;
                    else next_state = SCAN_0;
                end
                KEY_PROCESS : begin
                    if(row != 4'b1111) next_state = KEY_PROCESS;
                    else next_state = SCAN_0;
                end
           endcase
           end
        
        always@(posedge clk or posedge reset_p)begin
            if(reset_p)begin
                key_value = 0;
                key_valid = 0;
                col = 4'b0001;
            end
            else begin
                case(state)
                    SCAN_0:begin col = 4'b1110; key_valid = 0; end
                    SCAN_1:begin col = 4'b1101; key_valid = 0; end
                    SCAN_2:begin col = 4'b1011; key_valid = 0; end
                    SCAN_3:begin col = 4'b0111; key_valid = 0; end
                    KEY_PROCESS:begin
                        key_valid = 1;
                        case({col, row})
                            8'b1110_1110: key_value = 4'ha;
                            8'b1110_1101: key_value = 4'hb;
                            8'b1110_1011: key_value = 4'he;
                            8'b1110_0111: key_value = 4'hd;
                            
                            8'b1101_1110: key_value = 4'h9;
                            8'b1101_1101: key_value = 4'h6;
                            8'b1101_1011: key_value = 4'h3;
                            8'b1101_0111: key_value = 4'hf;
                            
                            8'b1011_1110: key_value = 4'h8;
                            8'b1011_1101: key_value = 4'h5;
                            8'b1011_1011: key_value = 4'h2;
                            8'b1011_0111: key_value = 4'h0;
                            
                            8'b0111_1110: key_value = 4'h7;
                            8'b0111_1101: key_value = 4'h4;
                            8'b0111_1011: key_value = 4'h1;
                            8'b0111_0111: key_value = 4'hc;
                        endcase
                end
                endcase
        end
        end
endmodule
