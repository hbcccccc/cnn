//+++++++++++++++++++++++=++++++++++++++++++++++++++
//Author:			
//
//--------- ----------------------------------------
//+Verison+  								Describe
//--------- ----------------------------------------
//   0.0								Initial Verison
//--------- ----------------------------------------
//+++++++++++++++++++++++=++++++++++++++++++++++++++
									
`timescale 1ns/1ps
module tb_top;

reg clk;
reg rst_n;



rgb_top inst_rgb_top(
.clk       (clk)  ,
.i_rst_n   (rst_n)  ,
.o_rgb     ()  ,
.o_rgb_clk ()  ,
.lcd_de    ()  ,
.lcd_rst_n ()  ,
.lcd_bl    ()  ,
.lcd_hs    ()  ,
.lcd_vs    ()  
);

initial begin
	#100000000ns;
	$finish;
end

always #10ns clk <= ~clk;

initial begin
	clk = 1'b0;
	rst_n = 1'b0;
	#1000ns;
	rst_n = 1'b1;
end

initial begin
	$fsdbDumpfile("tb_top.fsdb");
	$fsdbDumpvars();
end

endmodule
