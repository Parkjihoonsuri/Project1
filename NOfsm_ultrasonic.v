`timescale 1ns / 1ps

module NOfsm_ultrasonic(
  input clk,      // 클럭 입력
  input rst,      // 리셋 입력
  output reg trigger,    // 초음파 트리거 핀 출력
  input echo,     // 초음파 에코 핀 입력
  output reg[15:0] distance // 거리를 저장할 레지스터
);

reg [16:0] count_usec_trig, count_usec_echo;

wire clk_usec;
reg count_usec_echo_e;
clock_usec

always(negedge clk or posedge reset_p)begin
if(reset_p) count_usec_trig = 0;
else begin
if(clk_usec)begin
    if(count_usec_trig>22'd80_000)begin
        count_usec_trig=0;
        end 





