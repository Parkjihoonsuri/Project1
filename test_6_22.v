`timescale 1ns / 1ps


module decoder_7seg(
    input [3:0] hex_value,
    output reg [7:0] seg_7
);
    always@(hex_value) begin
    case(hex_value)
    4'b0000:seg_7=8'b1111_1100;  //0
    4'b0001:seg_7=8'b0110_0000;  //1
    4'b0010:seg_7=8'b1101_1010;  //2
    4'b0011:seg_7=8'b1111_0010;  //3
    4'b0100:seg_7=8'b0110_0110;  //4
    4'b0101:seg_7=8'b1011_0110;  //5
    4'b0110:seg_7=8'b0011_1110;  //6
    4'b0111:seg_7=8'b1110_0000;  //7
    4'b1000:seg_7=8'b1111_1110;  //8
    4'b1001:seg_7=8'b1110_0110;  //9
    4'b1010:seg_7=8'b1110_1110;  //a
    4'b1011:seg_7=8'b0011_1110;  //b = b0011_1110; ->b0000_0010; b -> -
    4'b1100:seg_7=8'b1001_1100;  //c
    4'b1101:seg_7=8'b0111_1010;  //d
    4'b1110:seg_7=8'b1001_1110;  //e
    4'b1111:seg_7=8'b1000_1110;  //f = b1000_1110; ->b0000_0000; f -> off
    
    endcase
    end
endmodule

module decoder_7seg_4bitcalculator(
    input [3:0] hex_value,
    output reg [7:0] seg_7
);
    always@(hex_value) begin
    case(hex_value)
    4'b0000:seg_7=8'b1111_1100;  //0
    4'b0001:seg_7=8'b0110_0000;  //1
    4'b0010:seg_7=8'b1101_1010;  //2
    4'b0011:seg_7=8'b1111_0010;  //3
    4'b0100:seg_7=8'b0110_0110;  //4
    4'b0101:seg_7=8'b1011_0110;  //5
    4'b0110:seg_7=8'b0011_1110;  //6
    4'b0111:seg_7=8'b1110_0000;  //7
    4'b1000:seg_7=8'b1111_1110;  //8
    4'b1001:seg_7=8'b1110_0110;  //9
    4'b1010:seg_7=8'b1110_1110;  //a
    4'b1011:seg_7=8'b0000_0010;  //b = b0011_1110; ->b0000_0010; b -> -
    4'b1100:seg_7=8'b1001_1100;  //c
    4'b1101:seg_7=8'b0111_1010;  //d
    4'b1110:seg_7=8'b1001_1110;  //e
    4'b1111:seg_7=8'b0000_0000;  //f = b1000_1110; ->b0000_0000; f -> off
    
    endcase
    end
endmodule

module fnd_test_top(
    input clk,
    output [7:0] seg_7,
    output [3:0] com
);
    assign com=4'b0011;
    reg [25:0] clk_div;
    
    always@(posedge clk) clk_div = clk_div+1;
    reg [3:0] count;
    always@(negedge clk_div[25])begin
    count = count + 1;
    end
    //wire [7:0] seg_7_font;
    decoder_7seg seg7(.hex_value(count), .seg_7(seg_7)); //_font));
    //assign seg_7 = ~seg_7_font;
    
endmodule

module encoder_4_2(
    input [3:0] d,
    output [1:0] b
);
    assign b = (d == 4'b0001) ? 2'b00 : (d == 4'b0010) ? 2'b01 : (d == 4'b0100) ? 2'b10 : 2'b11;

endmodule

module mux_2_1_s(
    input [1:0] d,
    input s,
    output f
    );
    
    wire sbar, in0, in1;
    not(sbar, s);
    and(in0, d[0], sbar);
    and(in1, d[1], s);
    or(f, in0, in1);

endmodule

module mux_2_1_d(
    input [1:0] d,
    input s,
    output f
    );
    
    assign f = s ? d[1] : d[0];
    
endmodule

module mux_4_1_d(
    input [3:0] d,
    input [1:0] s,
    output f
    );
    
    assign f = d[s];
    
endmodule

module mux_8_1_d(
    input [7:0] d,
    input [2:0] s,
    output f
    );
    
    assign f = d[s];
    
endmodule

module demux_1_4(
    input d,
    input [1:0] s,
    output reg [3:0] f
    );
    
    always@* begin
    f = 0;
    f[s] = d;
    
    end
endmodule

module demux_1_4_d(
    input d,
    input [1:0] s,
    output [3:0] f
    );
    assign f = (s==2'b00) ? {3'b000, d} : (s == 2'b01) ? {2'b00, d, 1'b0} : (s==2'b10) ? {1'b0, d, 2'b00} : {d, 3'b000};  
    
endmodule

module mux_test_top(
    input [7:0] d,
    input [2:0] s_mux,
    input [1:0] s_demux,
    output [3:0] f
);

    wire w;
    mux_8_1_d mux(.d(d), .s(s_mux), .f(w));
    demux_1_4 demux(.d(w), .s(s_demux), .f(f));

endmodule

module bin_to_dec(
    input [11:0] bin,
    output reg [15:0] bcd
    );
    
    reg [3:0] i;
    
    always@(bin) begin
    bcd = 0;
    for(i=0; i<12; i = i+1)begin
        bcd = {bcd[14:0], bin[11-i]};
        if(i<11 && bcd[3:0] > 4) bcd[3:0] = bcd[3:0] +3;
        if(i<11 && bcd[7:4] > 4) bcd[7:4] = bcd[7:4] +3;
        if(i<11 && bcd[11:8] > 4) bcd[11:8] = bcd[11:8] +3;
        if(i<11 && bcd[15:12] > 4) bcd[15:12] = bcd[15:12] +3;
        end
    end
    
endmodule