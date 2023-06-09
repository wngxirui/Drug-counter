`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/20 09:08:52
// Design Name: 
// Module Name: control
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


module control(
    input           [3:0]       sw,
    input           [1:0]       key,
    input                       clk_in,
    input                       rst,
    input                       clk_2hz,
    input                       clk_1khz,
    input           [3:0]       num_set,
    output  reg     [5:0]       led=6'b111111,
    output  reg     [3:0]       num1,num2,num3,num4
    );
reg [17:0]  cnt;        //从按键按下开始计数
reg         cnt_full;   //计满一定时间的标志位 
reg         key_flag;   //按键按下则置位

reg [3:0]   yaoping_set=0;  //预置的药瓶数
reg [3:0]   yaopian_set=0;  //预置的药片数

reg [3:0]   yaoping=0;  //实时的药瓶数
reg [3:0]   yaopian=0;  //实时的药片数

reg[31:0] auto_cnt=0;   //控制自动计数状态下0.5s药品计数器加一的频率
reg       flag=0;       //计满的标志位
parameter  a0=4'b0000,//开关未开启
            a1=4'b0001,//设置药瓶数
            a2=4'b0011,//设置药片数
            a3=4'b0010,//自动计数
            a4=4'b0110;//手动计数

always@(posedge clk_in or negedge rst)begin
if(!rst) cnt<=18'b0;
else if (key[0]==0) cnt<=cnt+1'b1;      //按下开始计数
else cnt<=18'b0;
end

always@(posedge clk_in or negedge rst)begin
if(!rst) cnt_full<=1'b0;
else if(cnt==24999)
cnt_full<=1'b1;                     // 计满说明按键确实被按下，当检测到 cnt 第一次等于 24999时，该标志则被置为高电平，此后cnt_full恒为0
else if (key[0]==1) cnt_full<=1'b0;
else cnt_full<=cnt_full;
end

always@(posedge clk_in or negedge rst)begin
if(!rst) key_flag<=1'b0;
else if (cnt==24999&&cnt_full==1'b0)//低电平够久，按键确实被按下且保证是第一次，保证后面按一次计数加一
key_flag=1'b1;                      //表示key[0]按下
else key_flag=1'b0;                 
end

always@(posedge clk_in or negedge rst)  begin
    if(!rst)    begin
        yaoping_set=0;yaopian_set=0;
        yaoping=0;yaopian=0;
        flag<=0;
        num1<=0;num2<=0;num3<=0;num4<=0;
    end
    else        begin
        case(sw)
            a0: begin  //IDLE，按下按键无反应
                    num1<=0;
                    num2<=0;
                    num3<=0;
                    num4<=0;           
            end
            a1: begin
                yaoping_set<=num_set;   //设置药瓶数
                num1<=yaoping_set;
            end
            a2: begin
                yaopian_set<=num_set;   //设置药片数
                num2<=yaopian_set;
            end
            a3: begin   //自动计数
                if(auto_cnt==49_999_999)    begin   //到0.5s则加一
                    auto_cnt<=0;
                    if(yaopian==yaopian_set)    begin
                        yaopian<=0;
                        if(yaoping==yaoping_set)    begin
                            yaoping<=yaoping_set;
                            yaopian<=yaopian_set;
                            flag<=1;                //计数器达到指定值
                        end
                        else                        begin
                            yaoping<=yaoping+1;
                        end
                    end
                    else                        begin
                        yaopian<=yaopian+1;
                    end
                end
                else                        begin
                    auto_cnt<=auto_cnt+1;
                end
            end
            a4: begin   //手动计数
                if(key_flag==1)    begin    //按键按下则加一
                    if(yaopian==yaopian_set)    begin
                        yaopian<=0;
                        if(yaoping==yaoping_set)    begin
                            yaoping<=yaoping_set;
                            yaopian<=yaopian_set;
                            flag<=1;        //计数器达到指定值
                        end
                        else                        begin
                            yaoping<=yaoping+1;
                        end
                    end
                    else                        begin
                        yaopian<=yaopian+1;
                    end  
                end
            end
        endcase
        num3<=yaoping;
        num4<=yaopian;
    end
end

always@(posedge clk_2hz or negedge rst)  begin
    if(!rst)    begin
        led<=6'b111111;
    end
    else        begin
        if( (!yaopian)&& (!yaopian_set)&&(!yaoping)&&(!yaoping_set) )   begin   //都为0时led不闪烁
            led<=6'b111111;
        end
        else                                                            begin
            if(flag==1) begin       //计数器到达指定值时一个led闪烁
                led[0]<=~led[0];
            end
            else        begin
                led<=6'b111111;    
            end
        end
    end
end
endmodule
