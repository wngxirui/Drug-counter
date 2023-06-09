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
    input       [3:0]    sw,                     //四个拨码开关，控制录入不同的数据
    input       [1:0]    key,                    //独立按键控制手动计数数值的累加
    input                rst,                    //全局复位
    input	    [3:0]	 scan_in,                //矩阵键盘的列
    output      [3:0]    scan_out,               //矩阵键盘的行
    output      [3:0]    en,                     //数码管使能信号
    output      [7:0]    disp1,                  //控制数码管显示
    output      [5:0]    led
    );
wire    clk_in;                     //差分时钟信号变单端输出 100MHz
reg     clk_1khz=0;                 //1khz时钟，用于数码管扫描
reg     clk_100hz=0;                 //100hz时钟
reg     clk_2hz=0;                  //2hz时钟
reg     [31:0]  count=0;            //分频得到1khz时钟时的计数
reg     [31:0]  count1=0;           //分频得到100hz时钟时的计数
reg     [31:0]  count2=0;           //分频得到2hz时钟时的计数

wire    [3:0]   num_set;                //获取矩阵键盘按下译码后的数字
//num1，num2，num3，num4分别对应四个数码管上需要显示的数字
wire  [3:0]   num1;                  
wire  [3:0]   num2;
wire  [3:0]   num3;
wire  [3:0]   num4;
IBUFDS clkin1_buf(
     .O   (clk_in),
     .I   (clk_in_p),
     .IB  (clk_in_n)
);
always@(posedge clk_in)     //时钟分频
begin
    if(count < 49_999)    count <= count + 1;
    else 
        begin
          count <= 0;
          clk_1khz <= ~clk_1khz;    //数码管扫描
        end
end
always@(posedge clk_1khz)   //时钟分频
begin
    if(count1 < 4)    count1 <= count1 + 1;
    else 
        begin
          count1 <= 0;
          clk_100hz <= ~clk_100hz;
        end
end
always@(posedge clk_100hz)   //时钟分频
begin
    if(count2 < 4)    count2 <= count2 + 1;
    else 
        begin
          count2 <= 0;
          clk_2hz <= ~clk_2hz;      //led闪烁频率
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
