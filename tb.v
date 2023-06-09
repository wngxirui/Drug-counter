`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/21 18:45:25
// Design Name: 
// Module Name: tb
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


module tb();
reg clk_in_p,clk_in_n;
reg [3:0]   sw;
reg [1:0]   key;
reg         rst;
reg [3:0]   scan_in;
wire    [3:0]   scan_out;
wire    [3:0]   en;
wire    [7:0]   disp1;
wire    [5:0]   led;
top top_sim(
    .clk_in_p(clk_in_p),
    .clk_in_n(clk_in_n),
    .rst(rst),
    .led(led),
    .scan_in(scan_in),
    .scan_out(scan_out),
    .sw(sw),
    .key(key),
    .en(en),
    .disp1(disp1)
);
initial begin
    rst=1;
    clk_in_p=0;
    clk_in_n=1;
    scan_in=4'b1011;
    
end
always  begin
    #5
    clk_in_p=~clk_in_p;
    clk_in_n=~clk_in_n;
end
endmodule
