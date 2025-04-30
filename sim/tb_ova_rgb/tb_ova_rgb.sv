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


bit i =0;
//glb_clk_rst     intf_clk_rst();
glb_clk_rst_gen obj_clk_rst;
intf_ov7725_data intf_ov7725();
ov7725_data_gen obj_ov7725;
axi_glb_signal          glb_signal      ();
axi_rd_addr_channel 	rd_addr_channel ();
axi_wr_addr_channel 	wr_addr_channel ();
axi_rd_data_channel 	rd_data_channel ();
axi_wr_data_channel 	wr_data_channel ();
axi_wr_rsp_channel 		wr_rsp_channel  ();
axi_read				obj_axi_read_fifo;
axi_write				obj_axi_clear_int;
wire                    w_interrupt      ;

cnn_top inst_cnn(
    //connected with rgb_lcd
//.clk         (intf_clk_rst.clk	),
//.rst_n       (intf_clk_rst.rst_n),
.o_rgb       	 (),
.o_rgb_clk   	 (),
.lcd_de      	 (),
.lcd_rst_n   	 (),
.lcd_bl      	 (),
.lcd_hs      	 (),
.lcd_vs      	 (),
.ova_cfg_scl 	 (),
.ova_cfg_sda 	 (),
.o_interrupt 	 (w_interrupt	     ),
.i_pclk      	 (intf_ov7725.pclk   ),
.i_data      	 (intf_ov7725.data   ),
.href        	 (intf_ov7725.href   ),
.vsync       	 (intf_ov7725.vsync  ),
.glb_signal      (glb_signal     	 ),
.rd_addr_channel (rd_addr_channel	 ),
.wr_addr_channel (wr_addr_channel	 ),
.rd_data_channel (rd_data_channel	 ),
.wr_data_channel (wr_data_channel	 ),
.wr_rsp_channel  (wr_rsp_channel 	 )


);

initial begin
	obj_clk_rst 	= new(glb_signal);
	obj_ov7725 = new(intf_ov7725);
	obj_axi_read_fifo = new(
		.vif_glb_signal     	(glb_signal      ),
		.vif_rd_addr_channel	(rd_addr_channel ),
		.vif_wr_addr_channel	(wr_addr_channel ),
		.vif_rd_data_channel	(rd_data_channel ),
		.vif_wr_data_channel	(wr_data_channel ),
		.vif_wr_rsp_channel 	(wr_rsp_channel  )
	);
	obj_axi_clear_int = new(
		.vif_glb_signal     	(glb_signal      ),
		.vif_rd_addr_channel	(rd_addr_channel ),
		.vif_wr_addr_channel	(wr_addr_channel ),
		.vif_rd_data_channel	(rd_data_channel ),
		.vif_wr_data_channel	(wr_data_channel ),
		.vif_wr_rsp_channel 	(wr_rsp_channel  )
	);
	fork
		obj_clk_rst.run();
		obj_axi_read_fifo.axi_rd_channel_intf_init();
		obj_axi_clear_int.axi_wr_chn_init();
		obj_ov7725.run();
	join_none
	//@(posedge w_interrupt);
	//fork 
//
	//join_none



end

always@(posedge w_interrupt)begin
	fork
		obj_axi_clear_int.interrupt_clear();
		obj_axi_read_fifo.run(i);
	join
	i = i+1;
end


initial begin
	#20000000ns;
	$finish;
end



initial begin
	$fsdbDumpfile("tb_ova_rgb.fsdb");
	$fsdbDumpvars();
end

endmodule
