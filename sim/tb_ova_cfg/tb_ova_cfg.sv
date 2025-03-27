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
module tb_ova_cfg;


glb_clk_rst     intf_clk_rst();
intf_i2c		intf_i2c();
glb_clk_rst_gen obj_clk_rst;
i2c_slave		obj_i2c_slave;


wire 			sda;
wire			scl;
pullup(intf_i2c.scl);
pullup(intf_i2c.sda);

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
.ova_cfg_scl (intf_i2c.scl),
.ova_cfg_sda (intf_i2c.sda)

);

initial begin
	obj_clk_rst 	= new(intf_clk_rst);
	obj_i2c_slave 	= new(intf_i2c	  );
	obj_clk_rst.run();
	obj_i2c_slave.first_ack();
end




initial begin
	#1000000ns;
	$finish;
end



initial begin
	$fsdbDumpfile("tb_ova_cfg.fsdb");
	$fsdbDumpvars();
end

endmodule
