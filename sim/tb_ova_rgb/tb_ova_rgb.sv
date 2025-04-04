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
module tb_ova_rgb;


glb_clk_rst     intf_clk_rst();
glb_clk_rst_gen obj_clk_rst;
intf_ov7725_data intf_ov7725();
ov7725_data_gen obj_ov7725;



cnn_top inst_cnn(
    //connected with rgb_lcd
.clk         (intf_clk_rst.clk	),
.rst_n       (intf_clk_rst.rst_n),
.o_rgb       (),
.o_rgb_clk   (),
.lcd_de      (),
.lcd_rst_n   (),
.lcd_bl      (),
.lcd_hs      (),
.lcd_vs      (),
.ova_cfg_scl (),
.ova_cfg_sda (),
.i_pclk      (intf_ov7725.pclk),
.i_data      (intf_ov7725.data),
.href        (intf_ov7725.href),
.vsync       (intf_ov7725.vsync)




);

initial begin
	obj_clk_rst 	= new(intf_clk_rst);
	obj_ov7725 = new(intf_ov7725);
	fork
		obj_clk_rst.run();
		obj_ov7725.run();
	join_none

end




initial begin
	#100000000ns;
	$finish;
end



initial begin
	$fsdbDumpfile("tb_ova_rgb.fsdb");
	$fsdbDumpvars();
end

endmodule
