module my_jk(
input j,k,s,r,clk,
output reg q,q_not
);
initial begin
q=1'b0;
q_not=!q;
end

always @(posedge clk or posedge s or posedge r)
begin
if(r) begin
q<=1'b0;
q_not<=1'b1;
end
else if (s) begin
q<=1'b1;
q_not<=1'b0;
end
else begin
if ((j==1)&&(k==1)) begin
q<=~q;
q_not<=~q_not;
end
else if((j==1)&&(k==0)) begin
q<=1'b1;
q_not<=1'b0;
end
else if((j==0)&&(k==1)) begin
q<=1'b0;
q_not<=1'b1;
end
else begin
q<=q;
q_not<=q_not;
end
end
end
endmodule

module my_74LS191(
input [3:0] i,
input clk,
input u_d,
input pre_num,
input s,
output [3:0]q,
output co,
output clk_o
);

not #2 gate1(clk_not,clk);
not #2 gate2(u_d_not,u_d);
and #2 gate3(s_left,u_d_not,~s);
and #2 gate4(s_right,u_d,~s);

and #2 gate5(co_u,u_d_not,q[3],q[2],q[1],q[0]);
and #2 gate6(co_d,u_d,~q[3],~q[2],~q[1],~q[0]);
or #2 gate7(co,co_u,co_d);
nand #2 gate8(clk_o,clk_not,~s,co);
and #2 gate9(s_1,~pre_num,i[0]);
and #2 gate10(r_1,~s_1,~pre_num);
my_jk chip_one(.j(~s),.k(~s),.s(s_1),.r(r_1),.clk(clk),.q(q[0]),.q_not(q_not_0));

and #2 gate11(s_2,i[1],~pre_num);
and #2 gate12(r_2,~s_2,~pre_num);
and #2 gate13(pre1_d,q_not_0,s_right);
and #2 gate14(pre1_u,q[0],s_left);
or #2 gate15(t1,pre1_u,pre1_d);
my_jk chip_two(.j(t1),.k(t1),.s(s_2),.r(r_2),.clk(clk),.q(q[1]),.q_not(q_not_1));

and #2 gate16(s_3,i[2],~pre_num);
and #2 gate17(r_3,~s_3,~pre_num);
and #2 gate18(pre2_d,q_not_0,q_not_1,s_right);
and #2 gate19(pre2_u,q[0],q[1],s_left);
or #2 gate20(t2,pre2_u,pre2_d);
my_jk chip_three(.j(t2),.k(t2),.s(s_3),.r(r_3),.clk(clk),.q(q[2]),.q_not(q_not_2));

and #2 gate21(s_4,i[3],~pre_num);
and #2 gate22(r_4,~s_4,~pre_num);
and #2 gate23(pre3_d,q_not_0,q_not_1,q_not_2,s_right);
and #2 gate24(pre3_u,q[0],q[1],q[2],s_left);
or #2 gate25(t3,pre3_u,pre3_d);
my_jk chip_four(.j(t3),.k(t3),.s(s_4),.r(r_4),.clk(clk),.q(q[3]),.q_not(q_not_3));
endmodule

/*
module my_test_bench;
reg clk;
initial begin
clk=1'b0;
repeat (1150) begin
#50;
clk=~clk;
end
end

reg u_d;
initial begin
u_d=1'b0;
#3000;
u_d=1'b1;
end
reg pre_num;
initial begin
pre_num=1'b1;
#3600;
pre_num=1'b0;
#400;
pre_num=1'b1;
end

reg s;
initial begin
s=1'b0;
#4500;
s=1'b1;
#1000;
s=1'b0;
end


wire clk_o;
wire [3:0] q;
reg [3:0] i;
initial begin
i=4'b0111;
end

my_74LS191 chip_one(
.i(i),
.clk(clk),
.u_d(u_d),
.pre_num(pre_num),
.s(s),
.q(q),
.co(co),
.clk_o(clk_o)
);

initial begin
$dumpfile("my_74LS191.vcd");
$dumpvars(0,my_test_bench);
#6000;
$finish;
end
endmodule
*/

module my_24_count_clock(
input clk,pre,
input select_h_min_s,
input add_one,
input start_or_use_clock,
output [3:0] h_shi,h_ge,min_shi,min_ge,s_shi,s_ge,
output q4,h,min,s_pro,
output  pro_clock_s,
output   pro_clock_min,
output  pro_clock_h
);

wire [3:0] i;
assign i=4'b0000;

wire u_d;
assign u_d=1'b0;

wire s;
assign s=1'b0;

//assign pre_num_s_ge=~(s_ge[3]&s_ge[1])&pre;
assign pre_num_s_ge=!(s_ge==4'b1010)&&pre;

my_74LS191 chip_one(
.i(i),
.clk(clk_pro_s),
.u_d(u_d),
.pre_num(pre_num_s_ge),
.s(s),
.q(s_ge),
.co(),
.clk_o()
);

wire pre_num_s_shi;
//assign pre_num_s_shi=~(s_shi[1]&s_shi[2])&pre;
assign pre_num_s_shi=!(s_shi==4'b0110)&&pre;
wire clk_s_shi;
//assign clk_s_shi=~(s_ge[3]&s_ge[0]);
assign clk_s_shi=!(s_ge==4'b1001);

my_74LS191 chip_two(
.i(i),
.clk(clk_s_shi),
.u_d(u_d),
.pre_num(pre_num_s_shi),
.s(s),
.q(s_shi),
.co(),
.clk_o()
);
 
wire pre_num_min_ge;
//assign pre_num_min_ge=~(min_ge[3]&min_ge[1])&pre;
assign pre_num_min_ge=!(min_ge==4'b1010)&&pre;
wire clk_min_ge;
//assign clk_min_ge=~(s_shi[2]&s_shi[0]);
assign clk_min_ge=!(s_shi==4'b0101);

my_74LS191 chip_three(
.i(i),
.clk(clock_pro_min),
.u_d(u_d),
.pre_num(pre_num_min_ge),
.s(s),
.q(min_ge),
.co(),
.clk_o()
);

wire pre_num_min_shi;
//assign pre_num_min_shi=~(min_shi[2]&min_shi[1])&pre;
assign pre_num_min_shi=!(min_shi==4'b0110)&&pre;
wire clk_min_shi;
//assign clk_min_shi=~(min_ge[3]&min_ge[0]);
assign clk_min_shi=!(min_ge==4'b1001);

my_74LS191 chip_four(
.i(i),
.clk(clk_min_shi),
.u_d(u_d),
.pre_num(pre_num_min_shi),
.s(s),
.q(min_shi),
.co(),
.clk_o()
);

wire pre_num_h_ge;
//assign pre_num_h_ge=(~(h_ge[1]&h_ge[3]))&(~(h_shi[0]&h_ge[1]&h_ge[0]))&pre;
assign pre_num_h_ge=(!(h_ge==4'b1010))&&(!( (h_shi==4'b0010)&&(h_ge==4'b0100) ))&&pre;
wire clk_h_ge;
//assign clk_h_ge=~(min_shi[2]&min_shi[0]);
assign clk_h_ge=!(min_shi==4'b0101);

/*reg [3:0] i_h_ge;
initial begin
i_h_ge=4'b0001;
end*/


my_74LS191 chip_five(
.i(i),
.clk(clock_pro_h),
.u_d(u_d),
.pre_num(pre_num_h_ge),
.s(s),
.q(h_ge),
.co(),
.clk_o()
);

wire pre_num_h_shi;
//assign pre_num_h_shi=~(h_ge[0]&h_ge[1]&h_shi[0])&pre;
assign pre_num_h_shi=(!( (h_shi==4'b0010)&&(h_ge==4'b0100) ))&&pre;
wire clk_h_shi;
//assign clk_h_shi=~(h_ge[3]&h_ge[0]);

wire h_ge_3_not,h_ge_3_not_not;
not gate1(h_ge_3_not,h_ge[3]);
wire h_ge_3_not_not;
not gate2(h_ge_3_not_not,h_ge_3_not);

wire h_ge_0_not,h_ge_0_not_not;
not gate3(h_ge_0_not,h_ge[0]);
wire h_ge_0_not_not;
not gate4(h_ge_0_not_not,h_ge_0_not);

//assign clk_h_shi=!(h_ge==4'b1001);
assign clk_h_shi=!(h_ge_3_not_not&&h_ge_0_not_not);

my_74LS191 chip_six(
.i(i),
.clk(clk_h_shi),
.u_d(u_d),
.pre_num(pre_num_h_shi),
.s(s),
.q(h_shi),
.co(),
.clk_o()
);

wire clk_pro_s;
wire clk_half;
wire q4;

my_add_one_module pro_chip(
.select_h_min_s(select_h_min_s),
.add_one(add_one),
.start_or_use_clock(start_or_use_clock),
.clk(clk),
.clk_pro(clk_pro_s),
.h(h),
.min(min),
.s(s_pro),
.h_or_min_or_s(s_pro),
.clk_half(clk_half),
.q4(q4)
);
assign pro_clock_s=clk_pro_s;
assign pro_clock_min=clock_pro_min;
assign pro_clock_h=clock_pro_h;

wire q4;
wire clk_half;
wire clock_pro_min;
assign clock_pro_min=(clk_half&min) || (q4&clk_min_ge);
wire clock_pro_h;
assign clock_pro_h=(clk_half&h) || (q4&clk_h_ge);
endmodule

/*
module my_test_bench;
reg clk;
initial begin
clk=1'b0;
repeat (172800) begin
#50;
clk=~clk;
end
end

wire [3:0] h_shi,h_ge,min_shi,min_ge,s_shi,s_ge;
reg pre;
initial begin
pre=1'b1;
#3600;
pre=1'b0;
#10000;
pre=1'b1;
end

my_12_count_clock chip_one(
.clk(clk),
.pre(pre),
.h_shi(h_shi),
.h_ge(h_ge),
.min_shi(min_shi),
.min_ge(min_ge),
.s_shi(s_shi),
.s_ge(s_ge)
);

initial begin
$dumpfile("my_test_12_counter.vcd");
$dumpvars(0,my_test_bench);
#86402_00;
$finish;
end
endmodule
*/
