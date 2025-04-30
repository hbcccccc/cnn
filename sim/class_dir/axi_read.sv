class axi_read;
virtual     axi_glb_signal          vif_glb_signal      ;
virtual     axi_rd_addr_channel 	vif_rd_addr_channel ;
virtual     axi_wr_addr_channel 	vif_wr_addr_channel ;
virtual     axi_rd_data_channel 	vif_rd_data_channel ;
virtual     axi_wr_data_channel 	vif_wr_data_channel ;
virtual     axi_wr_rsp_channel 		vif_wr_rsp_channel  ;


function new(
input   virtual  axi_glb_signal         vif_glb_signal     ,
input   virtual  axi_rd_addr_channel 	vif_rd_addr_channel,
input   virtual  axi_wr_addr_channel 	vif_wr_addr_channel,
input   virtual  axi_rd_data_channel 	vif_rd_data_channel,
input   virtual  axi_wr_data_channel 	vif_wr_data_channel,
input   virtual  axi_wr_rsp_channel 	vif_wr_rsp_channel 
);

this.vif_glb_signal         =   vif_glb_signal      ;
this.vif_rd_addr_channel    =   vif_rd_addr_channel ;
this.vif_wr_addr_channel    =   vif_wr_addr_channel ;
this.vif_rd_data_channel    =   vif_rd_data_channel ;
this.vif_wr_data_channel    =   vif_wr_data_channel ;
this.vif_wr_rsp_channel     =   vif_wr_rsp_channel  ;

endfunction

task axi_rd_channel_intf_init();
    vif_rd_addr_channel.arid      = 1'b0;
    vif_rd_addr_channel.araddr    = 1'b0;
    vif_rd_addr_channel.arlen     = 1'b0;
    vif_rd_addr_channel.arsize    = 1'b0;
    vif_rd_addr_channel.arbrust   = 1'b0;
    vif_rd_addr_channel.arlock    = 1'b0;
    vif_rd_addr_channel.arcache   = 1'b0;
    vif_rd_addr_channel.arprot    = 1'b0;
    vif_rd_addr_channel.arqos     = 1'b0;
    vif_rd_addr_channel.arregion  = 1'b0;
    vif_rd_addr_channel.arvalid   = 1'b0;
    vif_rd_data_channel.rready    = 1'b0;
    //$display("axi_intf_init time is %t", $time); 
    //$display("vif_rd_addr_channel.arvalid is %b", vif_rd_addr_channel.arvalid); 
    @(posedge vif_glb_signal.clk);
    @(posedge vif_glb_signal.clk);

endtask

task axi_read_transfer_normal(
    input  logic [31:0]     araddr,
    input  logic [3:0]      arrid,
    input  logic [3:0]      arlen,
    input  logic [2:0]      arsize,
    input  logic [1:0]      arbrust
);

@(posedge vif_glb_signal.clk);
vif_rd_addr_channel.arvalid   <= 1'b1;
vif_rd_addr_channel.araddr    <= araddr;
vif_rd_addr_channel.arid      <= arrid;
vif_rd_addr_channel.arlen     <= arlen;
vif_rd_addr_channel.arsize    <= arsize;
vif_rd_addr_channel.arbrust   <= arbrust;
wait(vif_rd_addr_channel.arready == 1'b1);
@(posedge vif_glb_signal.clk);
vif_rd_addr_channel.arvalid   <= 1'b0;
vif_rd_data_channel.rready   <= 1'b1;

endtask

task axi_pingpang_read();
    bit [3:0] arrid = 0;
    repeat(40) begin
        axi_read_transfer_normal(
            .araddr  (32'h000f_0000 + 16'h04),
            .arrid   (arrid                 ),
            .arlen   (4'hf                  ),
            .arsize  (4'hf                  ),
            .arbrust (2'b00                 )
        );
        arrid = arrid + 1;
        wait(vif_rd_data_channel.rlast == 1'b1);
        @(posedge vif_glb_signal.clk);
    end
    //repeat(40) begin
    //    axi_read_transfer_normal(
    //        .araddr  (32'h000f_0000 + 16'h08),
    //        .arrid   (0                     ),
    //        .arlen   (4'hf                  ),
    //        .arsize  (4'hf                  ),
    //        .arbrust (2'b00                 )
    //    );
    //    wait(vif_rd_data_channel.rlast == 1'b1);
    //    @(posedge vif_glb_signal.clk);
    //end
endtask



task run();
        axi_pingpang_read();
endtask

endclass