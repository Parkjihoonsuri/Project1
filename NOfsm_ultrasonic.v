`timescale 1ns / 1ps

module NOfsm_ultrasonic(
  input clk,      // Ŭ�� �Է�
  input rst,      // ���� �Է�
  output reg trigger,    // ������ Ʈ���� �� ���
  input echo,     // ������ ���� �� �Է�
  output reg[15:0] distance // �Ÿ��� ������ ��������
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





