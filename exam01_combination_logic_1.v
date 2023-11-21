`timescale 1ns / 1ps
module half_adder(
    input a,b,
    output sum,carry
    );
    assign sum=a^b;
    assign carry=a&b;
    
endmodule

module halfadder_behaviors(    //동작적 모델링
    input a,b,
    output reg s,reg c
    );
    always@(a,b)begin
    case({a,b})
       2'b00:begin s=0; c=0; end
       2'b01:begin s=1; c=0; end
       2'b10:begin s=1; c=0; end
       2'b11:begin s=0; c=1; end
    endcase
    end
endmodule

module fulladder_structural(   //구조적 모델링
    input a,b,cin,
    output sum,carry
    );
    wire sum_0, carry_0, carry_1;
    
    half_adder ha0 (.a(a), .b(b), .sum(sum_0), .carry(carry_0));
    half_adder ha1 (.a(sum_0), .b(cin), .sum(sum), .carry(carry_1));

    or(carry,carry_0,carry_1);
endmodule


module full_adder(             //데이터 모델링
    input a,b,cin,
    output sum,carry
    );
    
    assign #2 sum=a^b^cin;
    assign #3 carry=(cin&(a^b))|(a&b);
    
endmodule

module fadder_4bit_s(        //구조적 모델링
    input [3:0] a,b,
    input cin,
    output [3:0] sum,
    output carry
    );
    wire [2:0] carry_in;
    
    full_adder fa0 (.a(a[0]), .b(b[0]), .cin(cin), .sum(sum[0]), .carry(carry_in[0]));
    full_adder fa1 (.a(a[1]), .b(b[1]), .cin(carry_in[0]), .sum(sum[1]), .carry(carry_in[1]));
    full_adder fa2 (.a(a[2]), .b(b[2]), .cin(carry_in[1]), .sum(sum[2]), .carry(carry_in[2]));
    full_adder fa3 (.a(a[3]), .b(b[3]), .cin(carry_in[2]), .sum(sum[3]), .carry(carry));
    
    
endmodule

module fadder_4bit(
    input [3:0] a,b,
    input cin,
    output [3:0] sum,
    output carry
    );
    wire [4:0] temp;
    
    assign temp=a+b+cin;
    assign sum=temp[3:0];
    assign carry=temp[4];
    
endmodule
    
module fadd_sub_4bit_s(        //구조적 모델링
    input [3:0] a,b,
    input s,          //add=0, sub=1
    output [3:0] sum,
    output carry
    );
    wire [2:0] carry_in;
    
    full_adder fa0 (.a(a[0]), .b(b[0]^s), .cin(s), .sum(sum[0]), .carry(carry_in[0]));
    full_adder fa1 (.a(a[1]), .b(b[1]^s), .cin(carry_in[0]), .sum(sum[1]), .carry(carry_in[1]));
    full_adder fa2 (.a(a[2]), .b(b[2]^s), .cin(carry_in[1]), .sum(sum[2]), .carry(carry_in[2]));
    full_adder fa3 (.a(a[3]), .b(b[3]^s), .cin(carry_in[2]), .sum(sum[3]), .carry(carry));
    
    
endmodule

module fadd_sub_4bit(        //데이터 모델링 (조합회로는 assign문 쓰는게 가장 깔끔하다.)
    input [3:0] a,b,
    input s,          //add=0, sub=1
    output [3:0] sum,
    output carry
    );
    wire [4:0] temp;
    
    assign temp = s ? a-b: a+b;
    assign sum = temp[3:0];
    assign carry = temp[4];
    
endmodule

module comparator #(parameter N=4)(                   
    input [N-1:0] a,b,
    output equal, greater, less
);
    assign equal = (a == b) ? 1'b1 : 1'b0;
    assign greater = (a > b) ? 1'b1 : 1'b0;
    assign less = (a < b) ? 1'b1 : 1'b0;
    
endmodule

module decoder_2_4_case(                                   //case문을 사용함 (디코더)
    input [1:0] a,
    output reg [3:0] y
);
    always@(a)begin
    case(a)
        2'b00 : y= 4'b0001;
        2'b01 : y= 4'b0010;
        2'b10 : y= 4'b0100;
        2'b11 : y= 4'b1000;   
    endcase
    end
endmodule

module decoder_2_4_if(                               //if문을 사용함 (디코더)
    input [1:0] a,
    output reg [3:0] y
);
    always@(a)begin
        if(a==2'b00) y=4'b0001;
        else if(a==2'b01) y=4'b0010;
        else if(a==2'b10) y=4'b0100;
        else y=4'b1000;
    end
endmodule

module decoder_2_4(                                 //data flow(디코더)
    input [1:0] a,
    output [3:0] y
);
    assign y= (a==2'b00) ? 4'b0001 : (a==2'b01) ? 4'b0010 : (a==2'b10) ? 4'b0100 : 4'b1000;
    
endmodule

module decoder_2_4_en(                                 
    input [1:0] a,
    input en,
    output [3:0] y
);
    assign y= (~en) ? 4'b0000 :(a==2'b00) ? 4'b0001 : (a==2'b01) ? 4'b0010 : (a==2'b10) ? 4'b0100 : 4'b1000;
    
endmodule

module decoder_2_4_en_case(                                   //case문을 사용함 (디코더)
    input [1:0] a,
    input en,
    output reg [3:0] y
);
    always@(a)begin
    if(en)begin
    case(a)
        2'b00 : y= 4'b0001;
        2'b01 : y= 4'b0010;
        2'b10 : y= 4'b0100;
        2'b11 : y= 4'b1000;   
    endcase
    end
    else y=0;
    end
endmodule

module decoder_3_8_1(
    input [2:0] a,
    input en,
    output reg [7:0] y
);
    
    always@(a)begin
    if(en)begin
    case(a)
        3'b000 : y= 8'b0000_0001;
        3'b001 : y= 8'b0000_0010;
        3'b010 : y= 8'b0000_0100;
        3'b011 : y= 8'b0000_1000;   
        3'b100 : y= 8'b0001_0000;   
        3'b101 : y= 8'b0010_0000;   
        3'b110 : y= 8'b0100_0000;   
        3'b111 : y= 8'b1000_0000;   
    endcase
    end
    else y=0;
    end
endmodule

//module decoder_4_16_1(
//    input en,
//    input [3:0] a,
//    output [15:0] y 
//);
//    wire [7:0] y1; 
//    wire [15:8] y2;
//    assign y = (en ==1'b1) ? ({y1, 8'b0}) : ({8'b0, y2});
//    decoder_3_8_1 copy1(.a(a), .y(y1));
//    decoder_3_8_1 copy2(.a(a), .y(y2));
//endmodule



