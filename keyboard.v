/*说明：这个键盘扫描程序作了如下修改（对于行列式键盘，行线是扫描线，列线是读入线；
对FPGA来说，行线是output，列线是input；
S0状态：初始设为全零输出，读入列线状态，若变成非全1的状态，确定有键按下；
S1状态：然后逐行设零输出，读入列线状态，确定键值；
S2状态：只要按键一直按着，就保持在状态S2上；若按键松开，延迟20ms后，回到按键扫描的初始状态S0）*/

module keyboard(
	input		wire					clk_in,
	input		wire					rst,	
	input		wire[3:0]			    scan_in,	
	output	    reg	[3:0]			    num_set=0,  //锁存得到的按键输入
	output	    reg	[3:0]			    scan_out=4'b0000
    );
    
parameter		  CNT1_MAX	=	50_000;
parameter        CNT2_MAX  =   20;    
localparam        S0    =    3'b001;
localparam        S1    =    3'b010;
localparam        S2    =    3'b100;    
reg [2:0]   state;              //不同状态
reg [3:0]   num_keyboard=0;     //矩阵键盘按下的位置
reg         flag=0;             //获得矩阵键盘按下哪个位置的标志
reg [15:0]  cnt1;               //0.5ms的计数
reg [4:0]   cnt2;               //0.2us的计数
reg [7:0]   scan_out_scan_in=0; //编码按下了哪个位置
wire        flag_0_5ms;         //0.5ms到来则置位
    
always @ (posedge clk_in or negedge rst)    begin
    if (!rst)
        cnt1 <= 0;
    else
        if (cnt1 < CNT1_MAX - 1)
            cnt1 <= cnt1 + 1'b1;    //通过计数起到延时作用，计满一次即0.5ms则进行一次按键的扫描
        else
            cnt1 <= 0;
end
assign flag_0_5ms = (cnt1 == CNT1_MAX - 1) ? 1'b1 : 1'b0;
    
always @ (posedge clk_in or negedge rst)
    begin
        if (!rst)
            begin
                cnt2 <= 0;
                scan_out <= 4'b0000;     //初始行线设全零
                scan_out_scan_in <= 8'b0000_1111;        //没键按下的情况下的键值
                flag <= 0;
                state <= S0;
            end
        else
            case (state)  
            //S0是按键扫描的起始状态，0.5ms扫描一次按键，若有键按下且延迟0.2us之后还确认按键按下，则调到S1状态          
                S0            : if (flag_0_5ms == 0)  
                                    state <= S0;
                                else begin
                                    if (scan_in == 4'b1111) //列线读入若为全1，表示没键按下
                                        state <= S0;
                                    else begin         //列线读入若非全1，表示有键按下 ，且延迟0.2us后再扫描行线
                                        if (cnt2 < CNT2_MAX - 1)
                                            cnt2 <= cnt2 + 1'b1;
                                        else
                                            begin
                                                cnt2 <= 0;
                                                scan_out <= 4'b1110;
                                                state <= S1;
                                            end
                                    end
                                end
                                        
                S1            :    if (flag_0_5ms == 0)       //确认有键按下，开始行扫描，确认键值并跳到状态S2
                                    state <= S1;
                                else
                                    if (scan_in == 4'b1111)
                                        scan_out <= {scan_out[2:0],scan_out[3]};  //依次扫描每一行
                                    else
                                        begin
                                            scan_out_scan_in <= {scan_out,scan_in};
                                            scan_out <= 4'b0000;     //行线扫描完成之后，设行线状态为全零，且flag设为1，状态调到S2
                                            flag <= 1;
                                            state <= S2;
                                        end
                                        
                S2            :    if (flag_0_5ms == 0)  //只要按键一直按着，就保持在状态S2上；若按键松开，延迟0.2us后，回到按键扫描的初始状态S0
                                    begin
                                        flag <= 0;
                                        state <= S2;
                                    end
                                else
                                    if (scan_in != 4'b1111)
                                        state <= S2;
                                    else
                                        if (cnt2 < CNT2_MAX - 1)
                                            cnt2 <= cnt2 + 1'b1;
                                        else
                                            begin
                                                cnt2 <= 0;
                                                scan_out <= 4'b0000;
                                                state <= S0;
                                            end
            endcase
    end
    
always @ (*)    begin
    if (!rst)
        num_keyboard <= 4'h0;
    else
        case (scan_out_scan_in)
        8'b0111_0111:num_keyboard<=4'd0;
        8'b0111_1011:num_keyboard<=4'd1;
        8'b0111_1101:num_keyboard<=4'd2;
        8'b0111_1110:num_keyboard<=4'd3;
        8'b1011_0111:num_keyboard<=4'd4;
        8'b1011_1011:num_keyboard<=4'd5;
        8'b1011_1101:num_keyboard<=4'd6;
        8'b1011_1110:num_keyboard<=4'd7;
        8'b1101_0111:num_keyboard<=4'd8;
        8'b1101_1011:num_keyboard<=4'd9;
        8'b1101_1101:num_keyboard<=4'd10;
        8'b1101_1110:num_keyboard<=4'd11;
        8'b1110_0111:num_keyboard<=4'd12;
        8'b1110_1011:num_keyboard<=4'd13;
        8'b1110_1101:num_keyboard<=4'd14;
        8'b1110_1110:num_keyboard<=4'd15;
        default:num_keyboard<=0;
        endcase
end
always@(posedge clk_in or negedge rst)  begin
    if(!rst)    begin
        num_set<=0;
    end
    else        begin
        if(flag)    begin   //锁存
            num_set<=num_keyboard;
        end
        else        begin
            num_set<=num_set;
        end
    end
end
endmodule     