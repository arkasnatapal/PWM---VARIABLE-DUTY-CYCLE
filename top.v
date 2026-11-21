`timescale 1ns / 1ps

module dff(input clk,en,d,output reg Q);
always@(posedge clk)
begin
    if(en==1)
    Q<=d;
end
endmodule

/* here temp2 is the previous value of temp1 and we are doing a 2 stage shift register 
 temp1 is the current button state ... this is for the pwm button up 
 
 similar kind of thing is for pwn button down*/ 
module top(input clk,increase_duty,decrease_duty, output pwm_out);
wire slow_clk_enable;
wire tmp1,tmp2,tmp3,tmp4,duty_inc,duty_dec;
reg[3:0] duty_cycle=5;
reg[3:0]counter_pwm=0;

reg[27:0] counter_debounce=0;

always @(posedge clk)
begin
    counter_debounce<=counter_debounce+1;
    if(counter_debounce>=1)
        counter_debounce<=0;
end
 assign slow_clk_enable = counter_debounce == 1 ?1:0;

 dff dff1(clk,slow_clk_enable,increase_duty,tmp1);
 dff dff2(clk,slow_clk_enable,tmp1,tmp2); 
 assign duty_inc =  tmp1 & (~ tmp2) & slow_clk_enable;

 dff dff3(clk,slow_clk_enable,decrease_duty, tmp3);
 dff dff4(clk,slow_clk_enable,tmp3, tmp4); 
 assign duty_dec =  tmp3 & (~ tmp4) & slow_clk_enable;

 always @(posedge clk)
 begin
   if(duty_inc==1 && duty_cycle <= 9) 
    duty_cycle <= duty_cycle + 1;// increase duty cycle by 10%
   else if(duty_dec==1 && duty_cycle>=1) 
    duty_cycle <= duty_cycle - 1;//decrease duty cycle by 10%
 end
 
 
always @(posedge clk)
begin
    counter_pwm <=counter_pwm+1;
    if(counter_pwm >=9)
        counter_pwm<=0;
end
assign pwm_out =(counter_pwm < duty_cycle)? 1:0;


endmodule