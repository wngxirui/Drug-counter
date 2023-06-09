`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/01 11:37:21
// Design Name: 
// Module Name: display_drive
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module display_drive(
    input clk_1khz,
    input [3:0] num1,
    input [3:0] num2,
    input [3:0] num3,
    input [3:0] num4,
    output reg [3:0] en,
    output reg [7:0] disp1
    );
reg [3:0] num=4'b0;         //�����������Ҫ��ʾ������
reg [1:0] cnt = 2'b0;       //�����ͨ�ϵĲ�ͬ״̬
parameter 	s0=4'b0000,
            s1=4'b0001,
            s2=4'b0010,
            s3=4'b0011,
            s4=4'b0100,
            s5=4'b0101,
            s6=4'b0110,
            s7=4'b0111,
            s8=4'b1000,
            s9=4'b1001,
            s10=4'b1010,
            s11=4'b1011,
            s12=4'b1100,
            s13=4'b1101,
            s14=4'b1110,
            s15=4'b1111;
//��������룬1��ʾ����0��ʾ��
parameter	seg0=8'b01111110,     //��ʾ����0
            seg1=8'b00110000,     //��ʾ����1
            seg2=8'b01101101,     //��ʾ����2
            seg3=8'b01111001,     //��ʾ����3
            seg4=8'b00110011,     //��ʾ����4
            seg5=8'b01011011,     //��ʾ����5
            seg6=8'b01011111,     //��ʾ����6
            seg7=8'b01110000,     //��ʾ����7
            seg8=8'b01111111,     //��ʾ����8
            seg9=8'b01111011,     //��ʾ����9
			seg10=8'b11110111,
            seg11=8'b10011111,
            seg12=8'b11001110,
            seg13=8'b10111101,
            seg14=8'b11001111,
            seg15=8'b11000111;
always@(posedge clk_1khz)
begin
    case(cnt)
        2'd0:cnt <= cnt + 1'b1;
        2'd1:cnt <= cnt + 1'b1;
        2'd2:cnt <= cnt + 1'b1;
        2'd3:cnt <= cnt + 1'b1;
//        default:cnt <= 2'b0; 
    endcase    
end
always@(posedge clk_1khz)
begin
    case(cnt)
        2'd0:begin en <= 4'b0111;num <= num2;end
        2'd1:begin en <= 4'b1011;num <= num3;end
        2'd2:begin en <= 4'b1101;num <= num4;end
        2'd3:begin en <= 4'b1110;num <= num1;end
        //default:begin en <= 4'b0111;num <= num1;end
    endcase    
end
always@(posedge clk_1khz)
begin
    case(num)
        s0:disp1<=seg0;
        s1:disp1<=seg1;
        s2:disp1<=seg2;
        s3:disp1<=seg3;
        s4:disp1<=seg4;
        s5:disp1<=seg5;
        s6:disp1<=seg6;
        s7:disp1<=seg7;
        s8:disp1<=seg8;
        s9:disp1<=seg9;
        s10:disp1<=seg10;
        s11:disp1<=seg11;
        s12:disp1<=seg12;
        s13:disp1<=seg13;
        s14:disp1<=seg14;
        s15:disp1<=seg15; 
        default:disp1<=seg0;
    endcase    
end
endmodule
