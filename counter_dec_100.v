module counter_dec_100 (
    input clk,
    input reset_p,
    input clk_time,        // 1�� Ŭ�� ��ȣ
    output reg clk_sub_sec, // 1/100 �� Ŭ�� ��ȣ
    output reg [3:0] sec1, // 1/100 ���� 1�� �ڸ�
    output reg [3:0] sec10 // 1/100 ���� 10�� �ڸ�
);

    reg [14:0] count; // ī���� ��������

    always @(posedge clk or posedge reset_p) begin
        if (reset_p)
            count <= 15'b0; // ���� �� ī���� �ʱ�ȭ
        else if (clk_time) begin
            // 1�ʸ��� 1/100 �ʸ� ������Ʈ
            count <= count + 1'b1;
            if (count == 15'b100111000) begin
                // 1/100 �� ī��Ʈ�� 99�� ��� 0���� �����ϰ� 1/100 �� Ŭ�� ������Ʈ
                count <= 15'b0;
                clk_sub_sec <= ~clk_sub_sec; // 1/100 �� Ŭ�� ����
                sec1 <= sec1 + 1'b1; // 1�� �ڸ� ������Ʈ
                if (sec1 == 4'b1001) begin
                    // 1/100 ���� 1�� �ڸ��� 9�� ��� 10�� �ڸ� ������Ʈ
                    sec1 <= 4'b0;
                    sec10 <= sec10 + 1'b1;
                end
            end
        end
    end
endmodule