/*˵�����������ɨ��������������޸ģ���������ʽ���̣�������ɨ���ߣ������Ƕ����ߣ�
��FPGA��˵��������output��������input��
S0״̬����ʼ��Ϊȫ���������������״̬������ɷ�ȫ1��״̬��ȷ���м����£�
S1״̬��Ȼ�����������������������״̬��ȷ����ֵ��
S2״̬��ֻҪ����һֱ���ţ��ͱ�����״̬S2�ϣ��������ɿ����ӳ�20ms�󣬻ص�����ɨ��ĳ�ʼ״̬S0��*/

module keyboard(
	input		wire					clk_in,
	input		wire					rst,	
	input		wire[3:0]			    scan_in,	
	output	    reg	[3:0]			    num_set=0,  //����õ��İ�������
	output	    reg	[3:0]			    scan_out=4'b0000
    );
    
parameter		  CNT1_MAX	=	50_000;
parameter        CNT2_MAX  =   20;    
localparam        S0    =    3'b001;
localparam        S1    =    3'b010;
localparam        S2    =    3'b100;    
reg [2:0]   state;              //��ͬ״̬
reg [3:0]   num_keyboard=0;     //������̰��µ�λ��
reg         flag=0;             //��þ�����̰����ĸ�λ�õı�־
reg [15:0]  cnt1;               //0.5ms�ļ���
reg [4:0]   cnt2;               //0.2us�ļ���
reg [7:0]   scan_out_scan_in=0; //���밴�����ĸ�λ��
wire        flag_0_5ms;         //0.5ms��������λ
    
always @ (posedge clk_in or negedge rst)    begin
    if (!rst)
        cnt1 <= 0;
    else
        if (cnt1 < CNT1_MAX - 1)
            cnt1 <= cnt1 + 1'b1;    //ͨ����������ʱ���ã�����һ�μ�0.5ms�����һ�ΰ�����ɨ��
        else
            cnt1 <= 0;
end
assign flag_0_5ms = (cnt1 == CNT1_MAX - 1) ? 1'b1 : 1'b0;
    
always @ (posedge clk_in or negedge rst)
    begin
        if (!rst)
            begin
                cnt2 <= 0;
                scan_out <= 4'b0000;     //��ʼ������ȫ��
                scan_out_scan_in <= 8'b0000_1111;        //û�����µ�����µļ�ֵ
                flag <= 0;
                state <= S0;
            end
        else
            case (state)  
            //S0�ǰ���ɨ�����ʼ״̬��0.5msɨ��һ�ΰ��������м��������ӳ�0.2us֮��ȷ�ϰ������£������S1״̬          
                S0            : if (flag_0_5ms == 0)  
                                    state <= S0;
                                else begin
                                    if (scan_in == 4'b1111) //���߶�����Ϊȫ1����ʾû������
                                        state <= S0;
                                    else begin         //���߶�������ȫ1����ʾ�м����� �����ӳ�0.2us����ɨ������
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
                                        
                S1            :    if (flag_0_5ms == 0)       //ȷ���м����£���ʼ��ɨ�裬ȷ�ϼ�ֵ������״̬S2
                                    state <= S1;
                                else
                                    if (scan_in == 4'b1111)
                                        scan_out <= {scan_out[2:0],scan_out[3]};  //����ɨ��ÿһ��
                                    else
                                        begin
                                            scan_out_scan_in <= {scan_out,scan_in};
                                            scan_out <= 4'b0000;     //����ɨ�����֮��������״̬Ϊȫ�㣬��flag��Ϊ1��״̬����S2
                                            flag <= 1;
                                            state <= S2;
                                        end
                                        
                S2            :    if (flag_0_5ms == 0)  //ֻҪ����һֱ���ţ��ͱ�����״̬S2�ϣ��������ɿ����ӳ�0.2us�󣬻ص�����ɨ��ĳ�ʼ״̬S0
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
        if(flag)    begin   //����
            num_set<=num_keyboard;
        end
        else        begin
            num_set<=num_set;
        end
    end
end
endmodule     