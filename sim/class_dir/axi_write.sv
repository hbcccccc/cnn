class axi_write;
virtual     axi_glb_signal          vif_glb_signal      ;
virtual     axi_rd_addr_channel 	vif_rd_addr_channel ;
virtual     axi_wr_addr_channel 	vif_wr_addr_channel ;
virtual     axi_rd_data_channel 	vif_rd_data_channel ;
virtual     axi_wr_data_channel 	vif_wr_data_channel ;
virtual     axi_wr_rsp_channel 		vif_wr_rsp_channel  ;
bit [31:0]     wdata[$];


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

task axi_wr_addr_chn_init();
//wait(vif_glb_signal.rst_n == 1'b0);

vif_wr_addr_channel.awid     <= 'd0 ;
vif_wr_addr_channel.awaddr   <= 'd0 ;
vif_wr_addr_channel.awlen    <= 'd0 ;
vif_wr_addr_channel.awsize   <= 'd0 ;
vif_wr_addr_channel.awbrust  <= 'd0 ;
vif_wr_addr_channel.awlock   <= 'd0 ;
vif_wr_addr_channel.awcache  <= 'd0 ;
vif_wr_addr_channel.awprot   <= 'd0 ;
vif_wr_addr_channel.awqos    <= 'd0 ;
vif_wr_addr_channel.awvalid  <= 'd0 ;
endtask

task axi_wr_data_chn_init();
//wait(vif_glb_signal.rst_n == 1'b0);
vif_wr_data_channel.wid     <= 'd0;
vif_wr_data_channel.wdata   <= 'd0;
vif_wr_data_channel.wstrb   <= 'd0;
vif_wr_data_channel.wlast   <= 'd0;
vif_wr_data_channel.wvalid  <= 'd0;
endtask

task axi_wr_rsp_chn_init();
//wait(vif_glb_signal.rst_n == 1'b0);
vif_wr_rsp_channel.bready  <=  1'b1;
endtask


task axi_wr_chn_init();
    fork
        axi_wr_data_chn_init();
        axi_wr_addr_chn_init();
        axi_wr_rsp_chn_init();
    join
endtask




task axi_wr_transfer(
    input [3    :0]     awid    ,
    input [31   :0]     awaddr  , 
    input [3    :0]     awlen   ,
    input [2    :0]     awsize  ,
    input [1    :0]     awbrust ,
    input [1    :0]     awlock  ,
    input [3    :0]     awcache ,
    input [2    :0]     awprot  ,
    input [3    :0]     awqos   ,

    input [3    :0]     wstrb   ,
    ref  bit [31    :0] wdata[$]
    );
    bit [3:0]   transfer_cnt;
    fork 
    //write addr channel transfer
        begin
            @(posedge vif_glb_signal.clk);
            vif_wr_addr_channel.awid     <= awid    ;     
            vif_wr_addr_channel.awaddr   <= awaddr  ; 
            vif_wr_addr_channel.awlen    <= awlen   ;     
            vif_wr_addr_channel.awsize   <= awsize  ; 
            vif_wr_addr_channel.awbrust  <= awbrust ; 
            vif_wr_addr_channel.awlock   <= awlock  ; 
            vif_wr_addr_channel.awcache  <= awcache ; 
            vif_wr_addr_channel.awprot   <= awprot  ; 
            vif_wr_addr_channel.awqos    <= awqos   ; 
            vif_wr_addr_channel.awvalid  <= 1'b1 ;

            //#0 $display("awvalid is %b", vif_wr_addr_channel.awvalid);
            wait(vif_wr_addr_channel.awready == 1'b1);
            @(posedge vif_glb_signal.clk);
            vif_wr_addr_channel.awvalid  <= 1'b0 ;
        end
    //write data channel transfer
        begin
            transfer_cnt = 0;
            repeat(awlen + 1)begin
                @(posedge vif_glb_signal.clk);
                //transfer_cnt = transfer_cnt + 1'b1;
                vif_wr_data_channel.wid     <= awid;
                vif_wr_data_channel.wdata   <= wdata.pop_front();
                vif_wr_data_channel.wstrb   <= wstrb;
                vif_wr_data_channel.wvalid  <= 1'b1;
                vif_wr_data_channel.wlast   <= 1'b1;
                if(vif_wr_data_channel.wready == 1'b0)
                    wait(vif_wr_data_channel.wready);
                    else if(transfer_cnt < awlen + 1)
                        transfer_cnt = transfer_cnt + 1'b1;
                //$display("transfer_cnt is %d", transfer_cnt);
                if(transfer_cnt == awlen + 1)begin
                    @(posedge vif_glb_signal.clk);
                    vif_wr_data_channel.wvalid  <= 1'b0;
                    vif_wr_data_channel.wlast  <= 1'b0;
                end
            end
        end
    join
    //write response channel transfer
    @(posedge vif_wr_rsp_channel.bvalid);
    vif_wr_rsp_channel.bready  <= 1'b1;
    if(vif_wr_rsp_channel.bid == awid)begin
        if(vif_wr_rsp_channel.bresp == 2'b00)begin
 //           $display("write response channel transfer success");
        end
        else begin
   //         $display("write response channel transfer failed,resp error");
        end
    end
    else begin
    //    $display("write response channel transfer failed,id error");
    end
    


endtask

task interrupt_clear();
    wdata.push_back(32'hffff_ffff);
    axi_wr_transfer(
        .awid   (3'b101),
        .awaddr ( 32'h000f_0000 + 16'h00),
        .awlen  (4'b0),
        .awsize (3'b010),
        .awbrust(0),
        .awlock (0),
        .awcache(0),
        .awprot (0),
        .awqos  (0),
        .wstrb  (4'hf),
        .wdata  (wdata)  
    );
endtask

endclass