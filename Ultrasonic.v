module Ultrasonic(
    input clk,
    input reset_p,
    input echo,                        // HCSR04 ��� -> MCU �Է�
    output reg trigger,                // MCU ��� -> HCSR04 �Է�
    output reg [7:0] led_bar,          // ������� ���� LED ǥ��
    output [3:0] com,                   //7_SEGMENT FND ���
    output [7:0] seg_7                  //7_SEGMENT FND ���
    );
    
    //* �Ķ���� ���� */
    parameter S_IDLE         = 1;     // ���� �ùٸ� ������ ��ٸ� ���� ����
    parameter S_T_HIGH_10US  = 2;     // HCSR04�� Ʈ���� ���
    parameter S_E_READ       = 3;     // echo ��ȣ�� ���/�ϰ� ���� �б�
    parameter S_READ_DATA    = 4;     // �Ÿ� ��� ����
    
    parameter S_WAIT_PEDGE   = 1;     // ��� ������ ��ٸ� ���� ����
    parameter S_WAIT_NEDGE   = 2;     // �ϰ� ������ ��ٸ� ���� ����
    
    wire clk_usec;
    wire hc_nedge, hc_pedge;
    
    reg count_usec_e;
    reg [15:0] count_usec;                            // ����ũ���� ī����
    reg [3:0] state, next_state, read_state;          // ���� �ӽ�
    reg [15:0] count_start, count_end;                // ������ ���۰� �� �ð�
    reg [15:0] distance;                              // �Ÿ� ������ ���

    clock_usec clk_us(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    // ����ũ���� ī����
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) count_usec = 0;                // ī���� ����
        else if (count_usec_e && clk_usec) count_usec = count_usec + 1;    // ����ũ���� ī��Ʈ
        else if (!count_usec_e) count_usec = 0;      // ����ũ���� ī��Ʈ ����
    end
    
    // ���� ��������
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) state = S_IDLE;                  // ����
        else state = next_state;                      // Ŭ���� �ϰ� �������� ���� ����
    end
    
    // ���� ��ȣ ���� ������
    edge_detector_n ed_dec (.clk(clk), .cp_in(echo), .reset_p(reset_p), .n_edge(hc_nedge), .p_edge(hc_pedge));
    
    // ��� ��Ʈ
    always @(posedge clk or posedge reset_p) begin   // Ŭ���� ��� ��������
        // ��� ���¿� ������ ����
        if (reset_p) begin
            count_usec_e <= 0;
            next_state <= S_IDLE;
            read_state <= S_WAIT_PEDGE;
            trigger <= 0;
            count_start <= 0;
            count_end <= 0;
            distance <= 0;
            led_bar <= 8'b1111_1111;
        end
        else begin
            case(state)
                S_IDLE : begin                         // ���� ������ ��ٸ�
                    led_bar[0] <= 0;
                    if (count_usec < 16'd65_535) begin // 65.535ms(������ ��Ʈ = 60ms)
                        count_usec_e <= 1;             // ī��Ʈ ����
                        trigger <= 0;                   // Ʈ���� ����
                    end
                    else begin                         // �ð��� 65.535ms�� �ʰ��� ���
                        led_bar <= 8'b1111_1111;
                        next_state <= S_T_HIGH_10US;    // ���� ��ȯ
                        count_usec_e <= 0;             // ī��Ʈ ����
                    end
                end
                S_T_HIGH_10US : begin                  // HCSR04�� Ʈ���� ��ȣ ���, 10us
                    led_bar[1] <= 0;
                    if (count_usec < 16'd16) begin     // 16us Ʈ����
                        count_usec_e <= 1;             // ī��Ʈ ����
                        trigger <= 1;                   // Ʈ���� ����
                    end
                    else begin                         // �ð��� 16us�� �ʰ��� ���
                        count_usec_e <= 0;             // ī��Ʈ ����
                        next_state <= S_E_READ;         // ���� ��ȯ
                        trigger <= 0;                   // Ʈ���� ����
                        read_state <= S_WAIT_PEDGE;     // �б� ���� ����
                    end
                end
                S_E_READ : begin                      // ���� ���� ���� �� ���� �� �� �ð� ����
                    led_bar[2] <= 0;
                    case(read_state)                   // ���� ���� ���� �б� ����
                        S_WAIT_PEDGE : begin           // ��� ���� ��ٸ�
                            led_bar[3] <= 0;
                            if (hc_pedge) begin         // ��� ���� ���� ��
                                read_state <= S_WAIT_NEDGE;  // �б� ���� ����
                                count_start <= count_usec;   // ���� �ð� = ���� ����ũ����
                            end
                            else if (count_usec > 16'd23_201) begin  // 4m�� �ʰ��ϴ� ���
                                read_state <= S_WAIT_PEDGE;       // �б� ���� ����
                                next_state <= S_IDLE;               // ���� ����
                            end
                            else count_usec_e <= 1;                // ���, ī��Ʈ ����
                        end
                        S_WAIT_NEDGE : begin           // �ϰ� ���� ��ٸ�
                            led_bar[4] <= 0;
                            if (count_usec < 16'd23_201) begin  // �ִ� 4m
                                if (hc_nedge) begin         // �ϰ� ���� ���� ��
                                    next_state <= S_READ_DATA;  // ���� ��ȯ
                                    count_end <= count_usec;   // �� �ð� = ���� ����ũ����
                                end
                                else begin                   // ��� �ϰ� ���� ����
                                    count_usec_e <= 1;        // ī��Ʈ ����
                                    read_state <= S_WAIT_NEDGE;  // �б� ���� ����
                                end
                            end
                            else begin                       // �Ÿ��� 4m�� �ʰ��ϴ� ���
                                read_state <= S_WAIT_PEDGE;       // �б� ���� ����
                                next_state <= S_IDLE;               // ���� ����
                            end
                        end
                        default : begin                       // ���¿��� ������ �߻��� ���
                            read_state = S_WAIT_PEDGE;           // �б� ���� ����
                            next_state = S_IDLE;                   // ���� ����
                        end
                    endcase
                end
                S_READ_DATA : begin                                // ���� ���� ���� ���� ��
                    led_bar[5] <= 0;
                    distance <= (count_end - count_start) / 58;    // �Ÿ� ���
                    count_start <= 0;                                // ī��Ʈ ����
                    count_end <= 0;
                    next_state <= S_IDLE;                            // ���� ����
                    read_state <= S_WAIT_PEDGE;                      // �б� ���� ����
                end
                default : next_state = S_IDLE;                        // ���¿��� ���� �߻� �� ����
            endcase
        end
    end
    wire [15:0] bcd_distance;
    bin_to_dec btd_distance(.bin(distance), .bcd(bcd_distance));																		
    fnd_4digit_cntr FND_distance(.clk(clk), .value(bcd_distance), .com(com), .seg_7(seg_7));											
    
endmodule