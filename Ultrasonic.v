module Ultrasonic(
    input clk,
    input reset_p,
    input echo,                        // HCSR04 출력 -> MCU 입력
    output reg trigger,                // MCU 출력 -> HCSR04 입력
    output reg [7:0] led_bar,          // 디버깅을 위한 LED 표시
    output [3:0] com,                   //7_SEGMENT FND 출력
    output [7:0] seg_7                  //7_SEGMENT FND 출력
    );
    
    //* 파라미터 정의 */
    parameter S_IDLE         = 1;     // 다음 올바른 동작을 기다릴 때의 상태
    parameter S_T_HIGH_10US  = 2;     // HCSR04로 트리거 출력
    parameter S_E_READ       = 3;     // echo 신호의 상승/하강 엣지 읽기
    parameter S_READ_DATA    = 4;     // 거리 계산 상태
    
    parameter S_WAIT_PEDGE   = 1;     // 상승 엣지를 기다릴 때의 상태
    parameter S_WAIT_NEDGE   = 2;     // 하강 엣지를 기다릴 때의 상태
    
    wire clk_usec;
    wire hc_nedge, hc_pedge;
    
    reg count_usec_e;
    reg [15:0] count_usec;                            // 마이크로초 카운터
    reg [3:0] state, next_state, read_state;          // 상태 머신
    reg [15:0] count_start, count_end;                // 에코의 시작과 끝 시간
    reg [15:0] distance;                              // 거리 측정값 출력

    clock_usec clk_us(.clk(clk), .reset_p(reset_p), .clk_usec(clk_usec));
    
    // 마이크로초 카운터
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) count_usec = 0;                // 카운터 리셋
        else if (count_usec_e && clk_usec) count_usec = count_usec + 1;    // 마이크로초 카운트
        else if (!count_usec_e) count_usec = 0;      // 마이크로초 카운트 중지
    end
    
    // 상태 레지스터
    always @(negedge clk or posedge reset_p) begin
        if (reset_p) state = S_IDLE;                  // 리셋
        else state = next_state;                      // 클럭의 하강 엣지에서 상태 갱신
    end
    
    // 에코 신호 엣지 감지기
    edge_detector_n ed_dec (.clk(clk), .cp_in(echo), .reset_p(reset_p), .n_edge(hc_nedge), .p_edge(hc_pedge));
    
    // 통신 파트
    always @(posedge clk or posedge reset_p) begin   // 클럭의 상승 엣지에서
        // 모든 상태와 변수를 리셋
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
                S_IDLE : begin                         // 다음 동작을 기다림
                    led_bar[0] <= 0;
                    if (count_usec < 16'd65_535) begin // 65.535ms(데이터 시트 = 60ms)
                        count_usec_e <= 1;             // 카운트 시작
                        trigger <= 0;                   // 트리거 리셋
                    end
                    else begin                         // 시간이 65.535ms를 초과한 경우
                        led_bar <= 8'b1111_1111;
                        next_state <= S_T_HIGH_10US;    // 상태 전환
                        count_usec_e <= 0;             // 카운트 중지
                    end
                end
                S_T_HIGH_10US : begin                  // HCSR04로 트리거 신호 출력, 10us
                    led_bar[1] <= 0;
                    if (count_usec < 16'd16) begin     // 16us 트리거
                        count_usec_e <= 1;             // 카운트 시작
                        trigger <= 1;                   // 트리거 높임
                    end
                    else begin                         // 시간이 16us를 초과한 경우
                        count_usec_e <= 0;             // 카운트 중지
                        next_state <= S_E_READ;         // 상태 전환
                        trigger <= 0;                   // 트리거 낮춤
                        read_state <= S_WAIT_PEDGE;     // 읽기 상태 리셋
                    end
                end
                S_E_READ : begin                      // 에코 엣지 감지 및 시작 및 끝 시간 저장
                    led_bar[2] <= 0;
                    case(read_state)                   // 에코 엣지 감지 읽기 상태
                        S_WAIT_PEDGE : begin           // 상승 에지 기다림
                            led_bar[3] <= 0;
                            if (hc_pedge) begin         // 상승 에지 감지 시
                                read_state <= S_WAIT_NEDGE;  // 읽기 상태 변경
                                count_start <= count_usec;   // 시작 시간 = 현재 마이크로초
                            end
                            else if (count_usec > 16'd23_201) begin  // 4m를 초과하는 경우
                                read_state <= S_WAIT_PEDGE;       // 읽기 상태 리셋
                                next_state <= S_IDLE;               // 상태 리셋
                            end
                            else count_usec_e <= 1;                // 대기, 카운트 시작
                        end
                        S_WAIT_NEDGE : begin           // 하강 에지 기다림
                            led_bar[4] <= 0;
                            if (count_usec < 16'd23_201) begin  // 최대 4m
                                if (hc_nedge) begin         // 하강 에지 감지 시
                                    next_state <= S_READ_DATA;  // 상태 전환
                                    count_end <= count_usec;   // 끝 시간 = 현재 마이크로초
                                end
                                else begin                   // 계속 하강 에지 감지
                                    count_usec_e <= 1;        // 카운트 시작
                                    read_state <= S_WAIT_NEDGE;  // 읽기 상태 유지
                                end
                            end
                            else begin                       // 거리가 4m를 초과하는 경우
                                read_state <= S_WAIT_PEDGE;       // 읽기 상태 리셋
                                next_state <= S_IDLE;               // 상태 리셋
                            end
                        end
                        default : begin                       // 상태에서 오류가 발생한 경우
                            read_state = S_WAIT_PEDGE;           // 읽기 상태 리셋
                            next_state = S_IDLE;                   // 상태 리셋
                        end
                    endcase
                end
                S_READ_DATA : begin                                // 에코 엣지 감지 성공 시
                    led_bar[5] <= 0;
                    distance <= (count_end - count_start) / 58;    // 거리 계산
                    count_start <= 0;                                // 카운트 리셋
                    count_end <= 0;
                    next_state <= S_IDLE;                            // 상태 리셋
                    read_state <= S_WAIT_PEDGE;                      // 읽기 상태 리셋
                end
                default : next_state = S_IDLE;                        // 상태에서 오류 발생 시 리셋
            endcase
        end
    end
    wire [15:0] bcd_distance;
    bin_to_dec btd_distance(.bin(distance), .bcd(bcd_distance));																		
    fnd_4digit_cntr FND_distance(.clk(clk), .value(bcd_distance), .com(com), .seg_7(seg_7));											
    
endmodule