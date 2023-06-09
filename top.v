`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/20 09:04:17
// Design Name: 
// Module Name: top
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


module top(
    input                clk_in_p , clk_in_n,
    input       [3:0]    sw,                     //�ĸ����뿪�أ�����¼�벻ͬ������
    input       [1:0]    key,                    //�������������ֶ�������ֵ���ۼ�
    input                rst,                    //ȫ�ָ�λ
    input	    [3:0]	 scan_in,                //������̵���
    output      [3:0]    scan_out,               //������̵���
    output      [3:0]    en,                     //�����ʹ���ź�
    output      [7:0]    disp1,                  //�����������ʾ
    output      [5:0]    led
    );
wire    clk_in;                     //���ʱ���źű䵥����� 100MHz
reg     clk_1khz=0;                 //1khzʱ�ӣ����������ɨ��
reg     clk_100hz=0;                 //100hzʱ��
reg     clk_2hz=0;                  //2hzʱ��
reg     [31:0]  count=0;            //��Ƶ�õ�1khzʱ��ʱ�ļ���
reg     [31:0]  count1=0;           //��Ƶ�õ�100hzʱ��ʱ�ļ���
reg     [31:0]  count2=0;           //��Ƶ�õ�2hzʱ��ʱ�ļ���

wire    [3:0]   num_set;                //��ȡ������̰�������������
//num1��num2��num3��num4�ֱ��Ӧ�ĸ����������Ҫ��ʾ������
wire  [3:0]   num1;                  
wire  [3:0]   num2;
wire  [3:0]   num3;
wire  [3:0]   num4;
IBUFDS clkin1_buf(
     .O   (clk_in),
     .I   (clk_in_p),
     .IB  (clk_in_n)
);
always@(posedge clk_in)     //ʱ�ӷ�Ƶ
begin
    if(count < 49_999)    count <= count + 1;
    else 
        begin
          count <= 0;
          clk_1khz <= ~clk_1khz;    //�����ɨ��
        end
end
always@(posedge clk_1khz)   //ʱ�ӷ�Ƶ
begin
    if(count1 < 4)    count1 <= count1 + 1;
    else 
        begin
          count1 <= 0;
          clk_100hz <= ~clk_100hz;
        end
end
always@(posedge clk_100hz)   //ʱ�ӷ�Ƶ
begin
    if(count2 < 4)    count2 <= count2 + 1;
    else 
        begin
          count2 <= 0;
          clk_2hz <= ~clk_2hz;      //led��˸Ƶ��
        end
end
keyboard keyboard_u(
//    .clk_100hz(clk_100hz),
    .scan_in(scan_in),
    .rst(rst),
    .clk_in(clk_in),
    .scan_out(scan_out),
    .num_set(num_set)
);
display_drive display_u(
    .clk_1khz(clk_1khz),
    .num1(num1),
    .num2(num2),
    .num3(num3),
    .num4(num4),
    .en(en),
    .disp1(disp1)
);
control control_u(
    .sw(sw),
    .key(key),
    .clk_in(clk_in),
    .rst(rst),
    .clk_2hz(clk_2hz),
    .clk_1khz(clk_1khz),
    .num_set(num_set),
    .led(led),
    .num1(num1),
    .num2(num2),
    .num3(num3),
    .num4(num4)    
);
endmodule
