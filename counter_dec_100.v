module counter_dec_100 (
    input clk,
    input reset_p,
    input clk_time,        // 1초 클럭 신호
    output reg clk_sub_sec, // 1/100 초 클럭 신호
    output reg [3:0] sec1, // 1/100 초의 1의 자리
    output reg [3:0] sec10 // 1/100 초의 10의 자리
);

    reg [14:0] count; // 카운터 레지스터

    always @(posedge clk or posedge reset_p) begin
        if (reset_p)
            count <= 15'b0; // 리셋 시 카운터 초기화
        else if (clk_time) begin
            // 1초마다 1/100 초를 업데이트
            count <= count + 1'b1;
            if (count == 15'b100111000) begin
                // 1/100 초 카운트가 99인 경우 0으로 리셋하고 1/100 초 클럭 업데이트
                count <= 15'b0;
                clk_sub_sec <= ~clk_sub_sec; // 1/100 초 클럭 반전
                sec1 <= sec1 + 1'b1; // 1의 자리 업데이트
                if (sec1 == 4'b1001) begin
                    // 1/100 초의 1의 자리가 9인 경우 10의 자리 업데이트
                    sec1 <= 4'b0;
                    sec10 <= sec10 + 1'b1;
                end
            end
        end
    end
endmodule