module top(
    //global clock
    input            Sys_clk  ,       // 全局时钟信号
            
    output       Beep ,//蜂鸣器控制信号

    input   [7:0]  Key ,         //按键信号     
    input   [4:1]  Sw ,

    input           Uart_rxd ,           //UART接收端口
    output          Uart_txd ,          //UART发送端口


    output  [7:0]  Blue_Led ,          //蓝色LED
    
    output  [2:0] Tri_color_LED_1,       // 三色Led1
    output  [2:0] Tri_color_LED_2,      // 三色Led2
    output  [2:0] Tri_color_LED_3,      // 三色Led3
    output  [2:0] Tri_color_LED_4,      // 三色Led4
    
//seg_led interface
    output  reg  [3:0]  Dig_Seg_Sel  ,       // 数码管位选信号
    output  reg  [7:0]  Seg_Blue_Led          // 数码管段选信号
);

wire            sys_rst_n ;       // 复位信号（低有效）


//assign Tri_color_LED_1 = 3'b111;
//assign Tri_color_LED_2 = 3'b111;
//assign Tri_color_LED_3 = 3'b111;
//assign Tri_color_LED_4 = 3'b111;
assign Blue_Led[4:3] = 2'b00;
assign Uart_txd = 1'b1;

wire h_min;
assign h_min=Sw[1];

wire h_s;
assign h_s=Sw[2];

wire min_s;
assign min_s=Sw[4];

reg [25:0] count;

always @(negedge Sys_clk)
begin
count<=count+1;
end

reg [15:0] count_1kz_sign,count_1kz;
initial begin
count_1kz=16'd0;
count_1kz_sign=16'd0;
end

always @(negedge Sys_clk)
begin
count_1kz_sign<=count_1kz_sign+1;
if(count_1kz_sign==25_000) begin
count_1kz<=~count_1kz;
count_1kz_sign<=26'd0;
end
end

reg count_1z;
reg [9:0] count_x;

initial begin
count_1z=1'b0;
count_x=10'd0;
end

always @(negedge count_1kz)
begin
count_x<=count_x+1;
if(count_x==500) begin
count_1z<=~count_1z;
count_x<=0;
end
end

wire [3:0] h_shi,h_ge,min_shi,min_ge,s_shi,s_ge;
wire pre;
assign pre=Key[7];

wire clk;
assign clk=(count_1z&&Key[6]&&Key[5])||(count[20]&&!Key[6])||(count[14]&&!Key[5]);

my_24_count_clock  chip_one(
.clk(clk),
.select_h_min_s(Key[3]),
.add_one(Key[4]),
.start_or_use_clock(Key[2]),
.h_shi(h_shi),
.h_ge(h_ge),
.min_shi(min_shi),
.min_ge(min_ge),
.s_shi(s_shi),
.s_ge(s_ge),
.pre(pre),
.q4(q4),
.h(h),
.min(min),
.s_pro(s),
.pro_clock_s(clk_pro_s),
.pro_clock_min(clk_pro_min),
.pro_clock_h(clk_pro_h)
);

wire clk_pro_s,clk_pro_min,clk_pro_h;
assign  Blue_Led[0]=clk_pro_s;
assign  Blue_Led[1]=clk_pro_min;
assign  Blue_Led[2]=clk_pro_h;
assign  Blue_Led[6] =clk;

wire clk_pro;
assign  Blue_Led[5] =clk_pro;

 /*
my_add_one_module chip(
.select_h_min_s(Key[3]),
.add_one(Key[4]),
.start_or_use_clock(Key[2]),
.clk(clk),
.h_or_min_or_s(s),
.clk_pro(clk_pro),
.h(h),
.min(min),
.s(s),
.clk_half(clk_half),
.q4(q4)
);
*/

wire q4;
assign Tri_color_LED_3 = {2'b11,!h};
assign Tri_color_LED_2 = {2'b11,!min};
assign Tri_color_LED_1 = {2'b11,!s};
assign Tri_color_LED_4 = {2'b11,q4};

assign Blue_Led[7]=count_1z;
wire h,min,s;
wire [6:0] q_s_ge,q_s_shi,q_min_ge,q_min_shi,q_h_ge,q_h_shi;
my_bcd_coder chip_s_ge(
.i(s_ge),
.q(q_s_ge)
);

my_bcd_coder chip_s_shi(
.i(s_shi),
.q(q_s_shi)
);

my_bcd_coder chip_min_ge(
.i(min_ge),
.q(q_min_ge)
);

my_bcd_coder chip_min_shi(
.i(min_shi),
.q(q_min_shi)
);

my_bcd_coder chip_h_ge(
.i(h_ge),
.q(q_h_ge)
);

my_bcd_coder chip_h_shi(
.i(h_shi),
.q(q_h_shi)
);


always @ ( Sys_clk)
begin
if(Sw[1]) begin
if((count[12]==0)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b0111;
Seg_Blue_Led<={1'b1,q_min_ge};
end

else if((count[12]==1)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b1011;
Seg_Blue_Led<={1'b1,q_min_shi};
end

else if((count[12]==0)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1101;
Seg_Blue_Led<={1'b1,q_h_ge};
end

else if((count[12]==1)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1110;
Seg_Blue_Led<={1'b1,q_h_shi};
end
end

else if (Sw[2]) begin
if((count[12]==0)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b0111;
Seg_Blue_Led<={1'b1,q_s_ge};
end

else if((count[12]==1)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b1011;
Seg_Blue_Led<={1'b1,q_s_shi};
end

else if((count[12]==0)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1101;
Seg_Blue_Led<={1'b1,q_h_ge};
end

else if((count[12]==1)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1110;
Seg_Blue_Led<={1'b1,q_h_shi};
end
end

else if(Sw[4]) begin
if((count[12]==0)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b0111;
Seg_Blue_Led<={1'b1,q_s_ge};
end

else if((count[12]==1)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b1011;
Seg_Blue_Led<={1'b1,q_s_shi};
end

else if((count[12]==0)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1101;
Seg_Blue_Led<={1'b1,q_min_ge};
end

else if((count[12]==1)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1110;
Seg_Blue_Led<={1'b1,q_min_shi};
end
end

else begin
if((count[12]==0)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b0111;
Seg_Blue_Led<={1'b1,q_min_ge};
end

else if((count[12]==1)&&(count[13]==0)) begin
Dig_Seg_Sel<=4'b1011;
Seg_Blue_Led<={1'b1,q_min_shi};
end

else if((count[12]==0)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1101;
Seg_Blue_Led<={1'b1,q_h_ge};
end

else if((count[12]==1)&&(count[13]==1)) begin
Dig_Seg_Sel<=4'b1110;
Seg_Blue_Led<={1'b1,q_h_shi};
end
end
end

endmodule
