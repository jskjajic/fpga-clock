module my_dff_rst(
input d,clk,rst,
output reg q,q_not
);
initial begin
q=1'b0;
q_not=1'b1;
end
always @(posedge clk or posedge rst)
begin
if(rst) begin
q<=1'b0;
q_not<=1'b1;
end
else begin
q<=d;
q_not<=!d;
end
end
endmodule

module my_dff_s(
input d,clk,s,
output reg q,q_not
);
initial begin
q=1'b0;
q_not=1'b1;
end
always @(posedge clk or posedge s)
begin
if(s) begin
q<=1'b1;
q_not<=1'b0;
end
else begin
q<=d;
q_not<=!d;
end
end
endmodule


module my_add_one_module(
input select_h_min_s,
input add_one,
input start_or_use_clock,
input clk,
output clk_pro,
output h,min,s,
input h_or_min_or_s,
output clk_half,
output q4
);
my_dff_rst chip_one(.d(q2),.clk(~select_h_min_s),.rst(q4),.q(q1),.q_not(q1_not));
my_dff_rst chip_two(.d(q3),.clk(~select_h_min_s),.rst(q4),.q(q2),.q_not(q2_not));
my_dff_s chip_three(.d(q1),.clk(~select_h_min_s),.s(q4),.q(q3),.q_not(q3_not));
my_dff_rst chip_four(.d(q4_not),.clk(~start_or_use_clock),.rst(1'b0),.q(q4),.q_not(q4_not));

wire q1,q2,q3,q4,q4_not;
assign  h=q1;
assign min=q2;
assign s=q3;

wire clk_left;
assign clk_left=clk_half&h_or_min_or_s;
assign clk_half=(~add_one)&q4_not;
wire clk_right;
assign clk_right=q4&clk;
assign clk_pro=clk_right|clk_left;
endmodule

