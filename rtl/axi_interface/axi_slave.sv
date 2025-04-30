module  axi_slave
#(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32,
    parameter OFFSET_ADDR   = 32'h000f_0000

)
(
    axi_glb_signal              glb_signal      ,
    axi_rd_addr_channel.slave   rd_addr_channel ,
    axi_wr_addr_channel.slave   wr_addr_channel ,
    axi_rd_data_channel.slave   rd_data_channel ,
    axi_wr_data_channel.slave   wr_data_channel ,
    axi_wr_rsp_channel.slave    wr_rsp_channel  ,
    intf_to_fifo.slave          intf_fifo       ,
    output  logic               o_interrupt     ,
    input   logic               i_href          ,
    input   logic               i_vsync           


);

// offset address
localparam INT_STATUS       = 16'h00;
localparam FIFO1_READ       = 16'h04;
localparam FIFO2_READ       = 16'h08;
localparam RESPONSE_OKEY    = 2'b00;
localparam RESPONSE_EXOKAY  = 2'b00;
localparam RESPONSE_SLVERR  = 2'b00;
localparam RESPONSE_DECERR  = 2'b00;



//===========signal define ========================

    wire clk = glb_signal.clk;
    wire rst_n = glb_signal.rst_n;

    reg  [ADDR_WIDTH - 1 :0] r_wr_addr      ;
    reg  [DATA_WIDTH - 1 :0] r_rd_data      ;
    reg  [DATA_WIDTH - 1 :0] r_wr_data      ;
    reg  [ADDR_WIDTH - 1 :0] r_rd_addr      ;
    reg  [3              :0] r_rd_len       ;  
    reg  [2              :0] r_rd_size      ;
    reg  [1              :0] r_rd_burst     ;
    reg  [1              :0] r_rd_lock      ;
    reg  [3              :0] r_rd_cache     ;
    reg  [2              :0] r_rd_prot      ;
    reg  [3              :0] r_rd_qos       ;
    reg  [3              :0] r_rd_region    ;
    reg                      r_rd_valid_1d  ;
    reg  [3              :0] r_arid         ;



//interrupt generate 
    reg  [31:0]     r_int_status                                                                                                          ;
    wire [31:0]     w_int_status_mask           = {32'hffff_ffff}                                                                         ; 
    reg             r_href_d                                                                                                              ;
    reg             r_href_2d                                                                                                             ;
    wire            w_href_nedge                = r_href_2d & (~r_href_d)                                                                 ;
    wire            w_interrupt_gen             = (w_href_nedge && w_int_status_mask[0])                                                  ;
    reg   [31:0]    r_int_clr_status                                                                                                      ;
    wire            w_interrupt_clr             = (r_int_clr_status!= 32'd0)                                                              ;

    //used for read address and data channls                                      
    wire            rd_addr_channel_signal_en   = rd_addr_channel.arvalid & rd_addr_channel.arready                                       ;
    wire            w_rd_int_status             = r_rd_addr == (OFFSET_ADDR + INT_STATUS);
    wire            w_rd_fifo1                  = r_rd_addr == (OFFSET_ADDR + FIFO1_READ);
    wire            w_rd_fifo2                  = r_rd_addr == (OFFSET_ADDR + FIFO2_READ);

    //generate fifo read enable signal
    reg  [3:0]      r_read_num_cnt                                                                                                        ;
    wire            r_read_num_cnt_en           = intf_fifo.fifo_rd_en          && (r_read_num_cnt < r_rd_len)                            ;
    wire            r_read_num_cnt_clr          = (r_read_num_cnt == r_rd_len)  && (rd_data_channel.rready   ) && (rd_data_channel.rvalid);
    reg             r_read_num_cnt_clr_d                                                                                                  ;
    wire            w_fifo_rd_en                = ((w_rd_fifo1||w_rd_fifo2)     && ((~rd_data_channel.rvalid)) || ((rd_data_channel.rready)) && (r_read_num_cnt <= r_rd_len) && (r_read_num_cnt != 4'b0)) ;
    wire            rvalid_gen                  = (w_rd_fifo1||w_rd_fifo2)      ?  w_fifo_rd_en                   :
                                                  (w_rd_int_status )            ? (1'b1)                          : 1'b0                    ;   
    wire            rvalid_clr                  =   r_read_num_cnt_clr_d                                                                    ;
    wire [31:0]     rd_data_mask                = {32'hffff_ffff}; //关于掩码，这里设置为全通，但后续可能会需要根据burst size来调节
    wire [31:0]     w_rdata                     = ( w_rd_fifo1 )                ? {16'h0,intf_fifo.fifo1_rd_data} :
                                                  ( w_rd_fifo2 )                ? {16'h0,intf_fifo.fifo2_rd_data} :
                                                  (w_rd_int_status)             ? {r_int_status                 } : 32'b0                   ;
    wire            rresp                       = 2'b00                                                                                     ;
    wire            rlast_en                    = (w_rd_fifo1||w_rd_fifo2)      ? ((r_read_num_cnt == r_rd_len) && (w_fifo_rd_en))          :
                                                  (w_rd_int_status       )      ? 1'b1                                                      : 1'b0  ;

//write addr channel signals declare
    reg     [3              :0]     r_awid      ;
    reg     [ADDR_WIDTH - 1 :0]     r_awaddr    ;
    reg     [3              :0]     r_awlen     ;
    reg     [2              :0]     r_awsize    ;
    reg     [1              :0]     r_awbrust   ;
    reg     [1              :0]     r_awlock    ;
    reg     [3              :0]     r_awcache   ;
    reg     [2              :0]     r_awprot    ;
    reg     [3              :0]     r_awqos     ;

    reg     [3              :0]     r_wid       ;
                             

    wire                            w_wr_addr_channlel_signal_lod_en = wr_addr_channel.awvalid & wr_addr_channel.awready ;
    wire                            w_wr_data_channel_signal_lod_en = wr_data_channel.wvalid & wr_data_channel.wready ;
    wire                            w_wr_int_status                  = (wr_addr_channel.awaddr) == (OFFSET_ADDR + INT_STATUS)            ;
    wire                            w_wr_data_done                   = (wr_data_channel.wvalid && wr_data_channel.wready) && (wr_data_channel.wlast);
    reg                             r_wr_data_done_d                 ;
    reg                             r_wr_data_done_2d               ;   
      
    wire                            w_awready_gen                    = w_wr_data_done                                      ;
    wire                            w_awready_clr                    = (wr_addr_channel.awready && wr_addr_channel.awvalid);
    wire                            w_wr_data_channel_signal_enable  = wr_data_channel.wvalid   && wr_data_channel.wready  ;
    wire                            w_wready_gen                     = (r_awid == r_wid);
    wire                            w_wready_clr                     = 1'b0;

//write response channel signals declare
    wire                            wr_rsp_channel_vld_gen           = (r_wr_data_done_2d)                                ;
    wire                            wr_rsp_channel_vld_clr           = (wr_rsp_channel.bvalid && wr_rsp_channel.bready);
    reg    [3               :0]     r_bid      ;
    reg    [1               :0]     r_bresp    ;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        r_wr_data_done_d    <= 1'b0;
        r_wr_data_done_2d  <= 1'b0;
    end
    else  begin
        r_wr_data_done_d   <= w_wr_data_done;
        r_wr_data_done_2d   <= r_wr_data_done_d;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        r_wid   <=  4'd0;
    else if(w_wr_data_channel_signal_lod_en)
        r_wid   <= wr_data_channel.wid;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        r_bid   <=  4'd0;
    else if(r_awid == r_wid)
        r_bid   <= r_wid;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        r_bresp   <=  4'd0;
    else if(r_awid == r_wid)
        r_bresp  <= RESPONSE_OKEY;
end



always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        wr_rsp_channel.bvalid <= 1'b0;
        wr_rsp_channel.bid    <= 4'd0 ;
        wr_rsp_channel.bresp  <= RESPONSE_OKEY;
    end
    else if(wr_rsp_channel_vld_clr) begin
        wr_rsp_channel.bvalid<= 1'b0;
        wr_rsp_channel.bid    <= 4'd0 ;
        wr_rsp_channel.bresp  <= RESPONSE_OKEY;
    end
     else if(wr_rsp_channel_vld_gen)begin
        wr_rsp_channel.bvalid <= 1'b1;
        wr_rsp_channel.bid    <= r_bid ;
        wr_rsp_channel.bresp  <= RESPONSE_OKEY;

     end
end



//assign rd_addr_channel.arready = 1'b1;

//generate rd_addr_channel arready
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
       rd_addr_channel.arready <= 1'b1;
    end
    else if(rd_data_channel.rlast)
       rd_addr_channel.arready <= 1'b1;
    else if(rd_addr_channel_signal_en)
       rd_addr_channel.arready <= 1'b0;
end
//register rd_addr_channel signals
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        r_rd_addr   <= {ADDR_WIDTH{1'b0}};
        r_rd_len    <= {4{1'b0}};
        r_rd_size   <= {3{1'b0}};
        r_rd_burst  <= {2{1'b0}};
        r_rd_lock   <= {1{1'b0}};
        r_rd_cache  <= {3{1'b0}};
        r_rd_prot   <= {2{1'b0}};
        r_rd_qos    <= {3{1'b0}};
        r_rd_region <= {3{1'b0}};
        r_arid      <= {4{1'b0}};
    end
    else if(rd_addr_channel_signal_en) begin
        r_rd_addr   <= rd_addr_channel.araddr;
        r_rd_len    <= rd_addr_channel.arlen;
        r_rd_size   <= rd_addr_channel.arsize;
        r_rd_burst  <= rd_addr_channel.arbrust;
        r_rd_lock   <= rd_addr_channel.arlock;
        r_rd_cache  <= rd_addr_channel.arcache;
        r_rd_prot   <= rd_addr_channel.arprot;
        r_rd_qos    <= rd_addr_channel.arqos;
        r_rd_region <= rd_addr_channel.arregion;
        r_arid      <= rd_addr_channel.arid;
    end
    else if(rd_data_channel.rlast)begin
        r_rd_addr   <= {ADDR_WIDTH{1'b0}};
        r_rd_len    <= {4{1'b0}};
        r_rd_size   <= {3{1'b0}};
        r_rd_burst  <= {2{1'b0}};
        r_rd_lock   <= {1{1'b0}};
        r_rd_cache  <= {3{1'b0}};
        r_rd_prot   <= {2{1'b0}};
        r_rd_qos    <= {3{1'b0}};
        r_rd_region <= {3{1'b0}};
        r_arid      <= {4{1'b0}};
    end
end
//generate fifo read cnt clear signal
always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        r_read_num_cnt_clr_d <= 1'b0;
    else 
        r_read_num_cnt_clr_d <= r_read_num_cnt_clr;
end
//generate fifo read cnt
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        r_read_num_cnt <= 4'b0;
    end
    else if(r_read_num_cnt_clr) 
        r_read_num_cnt <= 4'b0;
    else if(r_read_num_cnt_en) 
        r_read_num_cnt <= r_read_num_cnt + 1'b1;   
end

assign intf_fifo.fifo_rd_en = w_fifo_rd_en;
assign intf_fifo.fifo_choose = (w_rd_fifo1) ? 1'b0 : 1'b1; //1 : fifo2, 0 : fifo1
//generate rd data channel ravlid
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_channel.rvalid <= 1'b0;
    end
    else if(rvalid_clr)
        rd_data_channel.rvalid <= 1'b0;
    else if(rvalid_gen)
        rd_data_channel.rvalid <= 1'b1;
end

assign rd_data_channel.rdata = w_rdata & rd_data_mask;
//generate rd data channel rresp
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_channel.rresp <= 2'b0;
    end
    else 
        rd_data_channel.rresp <= 2'b0;
end

//rlast
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_channel.rlast <= 1'b0;
    end
    else if(rlast_en)
        rd_data_channel.rlast <= 1'b1;
    else 
        rd_data_channel.rlast <= 1'b0;
end

//rid
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_channel.rid <= 4'b0;
    end
    else 
        rd_data_channel.rid <= r_arid;
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        r_awid      <= 4'd0                       ;
        r_awaddr    <= {ADDR_WIDTH{1'b0}}         ;
        r_awlen     <= 4'd0                       ;
        r_awsize    <= 3'd0                       ;
        r_awbrust   <= 2'd0                       ;
        r_awlock    <= 2'd0                       ;
        r_awcache   <= 4'd0                       ;
        r_awprot    <= 3'd0                       ;
        r_awqos     <= 4'd0                       ;
    end
    else if(w_wr_addr_channlel_signal_lod_en)
        r_awid      <=  wr_addr_channel.awid      ; 
        r_awaddr    <=  wr_addr_channel.awaddr    ;
        r_awlen     <=  wr_addr_channel.awlen     ;
        r_awsize    <=  wr_addr_channel.awsize    ;
        r_awbrust   <=  wr_addr_channel.awbrust   ;
        r_awlock    <=  wr_addr_channel.awlock    ;
        r_awcache   <=  wr_addr_channel.awcache   ;
        r_awprot    <=  wr_addr_channel.awprot    ;
        r_awqos     <=  wr_addr_channel.awqos     ;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        wr_addr_channel.awready <= 1'b1;
    else if(w_awready_gen)
        wr_addr_channel.awready <= 1'b1;
    else if(w_awready_clr)
        wr_addr_channel.awready <= 1'b0;
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        wr_data_channel.wready <= 1'b1;
    else if(w_wready_gen)
        wr_data_channel.wready <= 1'b1;
    else if(w_wready_clr)
        wr_data_channel.wready <= 1'b0;
end


always @(posedge clk or negedge rst_n) begin
    if(~rst_n)
        r_int_clr_status    <= 32'd0 ;
    else if(w_wr_data_channel_signal_enable && w_wr_int_status)
        r_int_clr_status    <= {wr_data_channel.wdata} & {
                                                            {8{wr_data_channel.wstrb[3]}},
                                                            {8{wr_data_channel.wstrb[2]}},
                                                            {8{wr_data_channel.wstrb[1]}},
                                                            {8{wr_data_channel.wstrb[0]}}} ;
    else 
        r_int_clr_status    <= 32'd0 ;
end

always @(posedge clk ) begin
    if(~rst_n) begin
        r_href_d <= 1'b0;
        r_href_2d <= 1'b0;
    end
    else begin
        r_href_d <= i_href;
        r_href_2d <= r_href_d;
    end
end

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) 
        o_interrupt <= 1'b0;
    else if(w_interrupt_gen)
        o_interrupt <= 1'b1;
    else if(w_interrupt_clr)
        o_interrupt <= 1'b0;
    else 
        o_interrupt <= o_interrupt;
end

always @(posedge clk ) begin
    if(~rst_n)
        r_int_status <= 32'd0;
    else if(w_interrupt_gen)
        r_int_status <= (r_int_status | {31'd0,w_href_nedge})& w_int_status_mask;
    else if(w_interrupt_clr)
        r_int_status <= (~r_int_clr_status) & (r_int_status);

    
end



endmodule 