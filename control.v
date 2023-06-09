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
reg [17:0]  cnt;        //�Ӱ������¿�ʼ����
reg         cnt_full;   //����һ��ʱ��ı�־λ 
reg         key_flag;   //������������λ

reg [3:0]   yaoping_set=0;  //Ԥ�õ�ҩƿ��
reg [3:0]   yaopian_set=0;  //Ԥ�õ�ҩƬ��

reg [3:0]   yaoping=0;  //ʵʱ��ҩƿ��
reg [3:0]   yaopian=0;  //ʵʱ��ҩƬ��

reg[31:0] auto_cnt=0;   //�����Զ�����״̬��0.5sҩƷ��������һ��Ƶ��
reg       flag=0;       //�����ı�־λ
parameter  a0=4'b0000,//����δ����
            a1=4'b0001,//����ҩƿ��
            a2=4'b0011,//����ҩƬ��
            a3=4'b0010,//�Զ�����
            a4=4'b0110;//�ֶ�����

always@(posedge clk_in or negedge rst)begin
if(!rst) cnt<=18'b0;
else if (key[0]==0) cnt<=cnt+1'b1;      //���¿�ʼ����
else cnt<=18'b0;
end

always@(posedge clk_in or negedge rst)begin
if(!rst) cnt_full<=1'b0;
else if(cnt==24999)
cnt_full<=1'b1;                     // ����˵������ȷʵ�����£�����⵽ cnt ��һ�ε��� 24999ʱ���ñ�־����Ϊ�ߵ�ƽ���˺�cnt_full��Ϊ0
else if (key[0]==1) cnt_full<=1'b0;
else cnt_full<=cnt_full;
end

always@(posedge clk_in or negedge rst)begin
if(!rst) key_flag<=1'b0;
else if (cnt==24999&&cnt_full==1'b0)//�͵�ƽ���ã�����ȷʵ�������ұ�֤�ǵ�һ�Σ���֤���水һ�μ�����һ
key_flag=1'b1;                      //��ʾkey[0]����
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
            a0: begin  //IDLE�����°����޷�Ӧ
                    num1<=0;
                    num2<=0;
                    num3<=0;
                    num4<=0;           
            end
            a1: begin
                yaoping_set<=num_set;   //����ҩƿ��
                num1<=yaoping_set;
            end
            a2: begin
                yaopian_set<=num_set;   //����ҩƬ��
                num2<=yaopian_set;
            end
            a3: begin   //�Զ�����
                if(auto_cnt==49_999_999)    begin   //��0.5s���һ
                    auto_cnt<=0;
                    if(yaopian==yaopian_set)    begin
                        yaopian<=0;
                        if(yaoping==yaoping_set)    begin
                            yaoping<=yaoping_set;
                            yaopian<=yaopian_set;
                            flag<=1;                //�������ﵽָ��ֵ
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
            a4: begin   //�ֶ�����
                if(key_flag==1)    begin    //�����������һ
                    if(yaopian==yaopian_set)    begin
                        yaopian<=0;
                        if(yaoping==yaoping_set)    begin
                            yaoping<=yaoping_set;
                            yaopian<=yaopian_set;
                            flag<=1;        //�������ﵽָ��ֵ
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
        if( (!yaopian)&& (!yaopian_set)&&(!yaoping)&&(!yaoping_set) )   begin   //��Ϊ0ʱled����˸
            led<=6'b111111;
        end
        else                                                            begin
            if(flag==1) begin       //����������ָ��ֵʱһ��led��˸
                led[0]<=~led[0];
            end
            else        begin
                led<=6'b111111;    
            end
        end
    end
end
endmodule
