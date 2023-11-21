`timescale 1ns / 1ps


module rs_latch(
    input r,s,
    output q,qbar
    );
    
    nor(q, r, qbar);
    nor(qbar, s, q);
    
endmodule

module rs_latch_en(
    input r,s,
    input en,
    output q,qbar
    );
    wire and1_out;
    wire and2_out;
    
    and(and1_out, r, en);
    and(and2_out, s, en);
    nor(q, and1_out, qbar);
    nor(qbar, and2_out, q);
    
endmodule

module d_flip_flop_n(
    input d,
    input clk,
    input reset_p,
    output reg q
);

    always@(negedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else q = d;
        
    end
endmodule

module d_flip_flop_p(
    input d,
    input clk,
    input reset_p,
    output reg q
);

    always@(posedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else q = d;
    end
endmodule

//module t_flip_flop_n(             //레지스터를 0으로 초기화 해줘야 되는 코드
//    input clk,
//    output reg q
//);

//    wire d;
//    assign d = ~q;
    
//    always@(negedge clk)begin
//        q = d;
//    end
//endmodule

module t_flip_flop_n(
    input clk,
    input reset_p,
    output reg q
);

    always@(negedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else q = ~q;
    end
endmodule

module t_flip_flop_p(
    input clk,
    input t,
    input reset_p,
    output reg q
);

    always@(posedge clk or posedge reset_p)begin
        if(reset_p) q = 0;
        else if(t) q = ~q;
        else q = q;
    end
endmodule

module up_counter_asyc(
    input clk,
    input reset_p,
    output [3:0] count
);
    t_flip_flop_n t0(.clk(clk), .reset_p(reset_p), .q(count[0]));
    t_flip_flop_n t1(.clk(count[0]), .reset_p(reset_p), .q(count[1]));
    t_flip_flop_n t2(.clk(count[1]), .reset_p(reset_p), .q(count[2]));
    t_flip_flop_n t3(.clk(count[2]), .reset_p(reset_p), .q(count[3]));
    
endmodule

module down_counter_asyc(
    input clk,
    input reset_p,
    output [3:0] count
);
    t_flip_flop_p t0(.clk(clk), .reset_p(reset_p), .q(count[0]));
    t_flip_flop_p t1(.clk(count[0]), .reset_p(reset_p), .q(count[1]));
    t_flip_flop_p t2(.clk(count[1]), .reset_p(reset_p), .q(count[2]));
    t_flip_flop_p t3(.clk(count[2]), .reset_p(reset_p), .q(count[3]));
    
endmodule

module up_counter_p(                                 //behavior 모델링 
    input clk,
    input reset_p,
    output reg [3:0] count
);
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else count = count + 1;
    end
endmodule

module down_counter_p(                                 //behavior 모델링 
    input clk,
    input reset_p,
    output reg [3:0] count
);
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else count = count - 1;
    end
endmodule

module up_down_counter(
    input clk, reset_p,
    input up_down,
    output reg [3:0] count
);
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else if(up_down) count = count + 1;
        else count = count -1;
    end

endmodule



module up_down_counter_bcd_p(                                 //behavior 모델링 
    input clk,
    input reset_p,
    input up_down,
    output reg [3:0] count
);
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if(up_down)
            if(count >= 9) count = 0;
            else count = count +1;
        
        else 
            if(count == 0) count = 9;
            else count = count -1;
        
        end
        
    end
endmodule

module ring_counter_fnd(
    input clk,
//    input reset_p,
    output [3:0] com
);
    reg [3:0] temp;
    
    always@(posedge clk )begin //or negedge reset_p)begin
//        if(reset_p) temp = 4'b1110;
        if(temp!=4'b1110&&temp!=4'b1101&&temp!=4'b1011&temp!=4'b0111)temp=4'b1110;        
        else if(temp == 4'b0111) temp = 4'b1110;
        else temp = {temp[2:0], 1'b1}; 
    end
    
    assign com = temp;

endmodule

module pwm_ring_counter_pj(
        input clk, reset_p,
        input btn,
        output reg [3:0] q
    );
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p) q = 4'b0001;
        else if(btn) begin
            if(q == 4'b0001) q = 4'b0010;
            else if(q == 4'b0010) q = 4'b0100;
            else if(q == 4'b0100) q = 4'b1000;
            else if(q == 4'b1000) q = 4'b0001;
            else q = 4'b0001;                 // 디폴트 값
        end 
    end
endmodule


module up_down_counter_12bit_p(                                 //behavior 모델링 
    input clk,
    input reset_p,
    input up_down,
    output reg [11:0] count
);
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if(up_down)
            count = count +1;
        
        else 
           
        count = count -1;
        
        end
        
    end
endmodule

module up_down_counter_Nbit_p #(parameter N=4)(                                 //behavior 모델링 
    input clk,
    input reset_p,
    input up_down,
    output reg [N-1:0] count
);
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) count = 0;
        else begin
            if(up_down)
            count = count +1;
        else 
        count = count -1;
        end
        
    end
endmodule

module edge_detector_n(
    input clk,
    input cp_in,                    //clock pulse = cp
    input reset_p,
    output p_edge,
    output n_edge
);

    reg cp_in_old, cp_in_cur;       // cp는 d 플리플롭이다.
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)begin cp_in_old = 0; cp_in_cur = 0; end
        else begin
            cp_in_old <= cp_in_cur;
            cp_in_cur <= cp_in;
            end
        end
        assign p_edge = ~cp_in_old & cp_in_cur;
        assign n_edge = cp_in_old & ~cp_in_cur;

endmodule

module edge_detector_p (
        input clk,
        input cp_in,
        input reset_p,
        output p_edge,
        output n_edge
    );

    reg cp_in_old, cp_in_cur;
    
    always @(posedge clk or posedge reset_p)begin
        if(reset_p)begin cp_in_cur = 0; cp_in_old = 0; end
        else begin
            cp_in_old <= cp_in_cur;
            cp_in_cur <= cp_in;
        end
    end
    
    assign p_edge = ~cp_in_old & cp_in_cur;
    assign n_edge = cp_in_old & ~cp_in_cur;

endmodule

module FSM_led(
        input clk, reset_p,
        output reg [7:0] led_bar
    );
    
    reg [25:0] clk_div;

    always @(posedge clk)clk_div = clk_div + 1;

    reg [2:0] state, next_state;
    
    always @(posedge clk_div[25] or posedge reset_p)begin
        if(reset_p) state = 3'b000;
        else state = next_state;
    end

    always @(state)begin
        next_state = state + 1;
    end
    
    always @(state)begin
        case(state)
            0: led_bar = 8'b1111_1110;
            1: led_bar = 8'b1111_1101;
            2: led_bar = 8'b1111_1011;
            3: led_bar = 8'b1111_0111;
            4: led_bar = 8'b1110_1111;
            5: led_bar = 8'b1101_1111;
            6: led_bar = 8'b1011_1111;
            7: led_bar = 8'b0111_1111;
        endcase
    end

endmodule

module shift_register_SISO(                              //레지스터 구조적모델링은 하지 않는다.
    input d,
    input clk,
    input reset_p,
    output q
);

    wire [2:0] w;
    d_flip_flop_p D3(.d(d), .clk(clk), .reset_p(reset_p), .q(w[2]));
    d_flip_flop_p D2(.d(w[2]), .clk(clk), .reset_p(reset_p), .q(w[1]));
    d_flip_flop_p D1(.d(w[1]), .clk(clk), .reset_p(reset_p), .q(w[0]));
    d_flip_flop_p D0(.d(w[0]), .clk(clk), .reset_p(reset_p), .q(q));
    
    

endmodule

module shift_register_SISO_s(                                   //동작적 모델링
    input d,
    input clk,
    input reset_p,
    output reg q
);
    reg [3:0] siso;
    
    always@(negedge clk or posedge reset_p)begin
        if(reset_p)siso = 0;
        else begin
        siso[3] <= d;
        siso[2] <= siso[3];
        siso[1] <= siso[2];
        siso[0] <= siso[1];
        q = siso[0];
        end
    end

endmodule

module shift_register_PISO(
    input [3:0] d,
    input clk, reset_p, shift_load, 
    output q
);

    reg [3:0] data;
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)data = 0;
        else if(shift_load) data = {1'b0, data[3:1]};
        else data = d;
    end

    assign q = data[0];

endmodule

module shift_register_SIPO(
    input clk, reset_p, d,
    input rd_en,                     //read enable 입력가능하게 할꺼냐 말꺼냐
    output [3:0] q
);
    wire [3:0] w;                    //shift register
   
    d_flip_flop_p D3(.d(d), .clk(clk), .reset_p(reset_p), .q(w[3]));
    d_flip_flop_p D2(.d(w[3]), .clk(clk), .reset_p(reset_p), .q(w[2]));
    d_flip_flop_p D1(.d(w[2]), .clk(clk), .reset_p(reset_p), .q(w[1]));
    d_flip_flop_p D0(.d(w[1]), .clk(clk), .reset_p(reset_p), .q(w[0]));
    
    bufif1 (q[0], w[0], rd_en);
    bufif1 (q[1], w[1], rd_en);
    bufif1 (q[2], w[2], rd_en);
    bufif1 (q[3], w[3], rd_en);


endmodule

module shift_register_SIPO_s(
    input clk, reset_p, d,
    input rd_en,                     //read enable 입력가능하게 할꺼냐 말꺼냐
    output [3:0] q
);
    reg [3:0] w;                    //shift register
   
    always@(posedge clk or posedge reset_p)begin
        if(reset_p) w = 0;
        else w <= {d, w[3:1]};
    end
    
    assign q = (rd_en) ? w : 4'bzzzz;                      //밑에 구조적모델링 4줄을 이렇게 동작적모델링으로
    
//    d_flip_flop_p D3(.d(d), .clk(clk), .reset_p(reset_p), .q(w[3]));
//    d_flip_flop_p D2(.d(w[3]), .clk(clk), .reset_p(reset_p), .q(w[2]));
//    d_flip_flop_p D1(.d(w[2]), .clk(clk), .reset_p(reset_p), .q(w[1]));
//    d_flip_flop_p D0(.d(w[1]), .clk(clk), .reset_p(reset_p), .q(w[0]));
    
    bufif1 (q[0], w[0], rd_en);
    bufif1 (q[1], w[1], rd_en);
    bufif1 (q[2], w[2], rd_en);
    bufif1 (q[3], w[3], rd_en);

endmodule

module shift_register(                            //이게 범용시프트레지스터 보통 이걸 씀.
    input clk, reset_p, shift,load, sin,          //sin = sirial 입력
    input [7:0] data_in,
    output reg [7:0] data_out
);

    always@(posedge clk or posedge reset_p)begin
        if(reset_p)data_out = 0;
        else if(shift) data_out = {sin, data_out[7:1]};
        else if(load) data_out = data_in;
        end

endmodule

module register_Nbit_p #(parameter N= 8)(                                   //병렬입력 병렬출력 
    input [N-1:0] d,
    input clk, reset_p, wr_en, rd_en,
    output q
);

    reg [N-1:0] register;
    
    always@(posedge clk or posedge reset_p)begin
        if(reset_p)register = 0;
        else if(wr_en) register = d;
    end 
    
    assign q = rd_en ? register : 'bz;               //임피던스는 z만 쓰면 앞에 4'bz 4비트라고안써도 다드감.

endmodule

module sram_8bit_1024(                              //1Kbite 짜리 메모리
    input clk, wr_en, rd_en,                        //wr = writer rd = read
    input [9:0] addr,
    inout [7:0] data
);

    reg [7:0] mem [0:1023];                        //mem = memory

    always@(posedge clk)
        if(wr_en) mem[addr] <= data;
        
    assign data = rd_en ? mem[addr] : 8'bz;


endmodule