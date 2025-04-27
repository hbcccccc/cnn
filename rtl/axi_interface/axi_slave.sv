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
    intf_to_fifo.slave          intf_fifo       

);

// offset address
localparam INT_STATUS = 16'h00;
localparam FIFO1_READ = 16'h04;
localparam FIFO2_READ = 16'h08;


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

assign rd_addr_channel.arready = 1'b1;
wire   rd_addr_channel_signal_en = rd_addr_channel.arvalid & rd_addr_channel.arready;

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
end

wire w_rd_register = r_rd_addr == (OFFSET_ADDR + INT_STATUS);
wire w_rd_fifo1    = r_rd_addr == (OFFSET_ADDR + FIFO1_READ);
wire w_rd_fifo2    = r_rd_addr == (OFFSET_ADDR + FIFO2_READ);

//generate fifo read enable signal
reg  [3:0]   r_read_num_cnt;
wire         r_read_num_cnt_en = intf_fifo.fifo_rd_en && (r_read_num_cnt <= r_rd_len);
wire         r_read_num_cnt_clr = (r_read_num_cnt == r_rd_len) && (rd_data_channel.rvalid == 1'b0);

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        r_read_num_cnt <= 4'b0;
    end
    else if(r_read_num_cnt_en) begin
        r_read_num_cnt <= r_read_num_cnt + 1'b1;
    end
    else if(r_read_num_cnt_clr) begin
        r_read_num_cnt <= 4'b0;
    end
end

wire  w_fifo_rd_en = (w_rd_fifo1||w_rd_fifo2) && ((~rd_data_channel.rvalid) || (rd_data_channel.rready)) && (r_read_num_cnt <= r_rd_len);
assign intf_fifo.fifo_rd_en = w_fifo_rd_en;
assign intf_fifo.fifo_choose = (w_rd_fifo1) ? 1'b0 : 1'b1; //1 : fifo2, 0 : fifo1



// this block is used to generate read channel
//rrvalid
wire rvalid_en = (w_rd_fifo1||w_rd_fifo2) ? ((r_read_num_cnt <= r_rd_len)) : 
                 (w_rd_register )         ? (1'b1)                         : 1'b0;                                      

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_channel.rvalid <= 1'b0;
    end
    else if(rvalid_en)
        rd_data_channel.rvalid <= 1'b1;
    else 
        rd_data_channel.rvalid <= 1'b0;
end


//rrdata
wire [31:0] rd_data_mask = {32'hffff_ffff}; //关于掩码，这里设置为全通，但后续可能会需要根据burst size来调节
wire [31:0] w_rdata = ( w_rd_fifo1 ) ? {16'h0,intf_fifo.fifo1_rd_data} :
                      ( w_rd_fifo2 ) ? {16'h0,intf_fifo.fifo2_rd_data} :
                      ( w_rd_register ) ? {24'b0, 8'b0} : 32'b0;

wire  rdata_en = rvalid_en;

always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_channel.rdata <= 32'b0;
    end
    else if(rdata_en)
        rd_data_channel.rdata <= w_rdata;
    else 
        rd_data_channel.rdata <= 32'b0;
end

//rresp 
wire rresp = 2'b00;
wire rresp_en = rvalid_en;
 
always @(posedge clk or negedge rst_n) begin
    if(~rst_n) begin
        rd_data_channel.rresp <= 2'b0;
    end
    else if(rresp_en)
        rd_data_channel.rresp <= rresp;
    else 
        rd_data_channel.rresp <= 2'b0;
end

//rlast
wire rlast_en = (w_rd_fifo1||w_rd_fifo2) ? (r_read_num_cnt == r_rd_len) :
                (w_rd_register         ) ? 1'b1 : 1'b0;

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
    else if(rvalid_en)
        rd_data_channel.rid <= r_arid;
    else 
        rd_data_channel.rid <= 4'b0;
end


endmodule 