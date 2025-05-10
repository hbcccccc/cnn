module cnn_top_wrapper
#(
    parameter DATA_WIDTH    = 32,
    parameter ADDR_WIDTH    = 32,
    parameter ID_MAX_WIDTH  = 12
)
(

    output  wire                o_interrupt ,
    output  wire    [23:0]      o_rgb       ,
    output  wire                o_rgb_clk   ,
    output  wire                lcd_de      ,
    output  wire                lcd_rst_n   ,
    output  wire                lcd_bl      ,
    output  wire                lcd_hs      ,
    output  wire                lcd_vs      ,
    //connected with ova
    output  wire                ova_cfg_scl ,
    inout   wire                ova_cfg_sda ,
    input   wire                i_pclk      ,
    input   wire   [7:0]        i_data      ,
    input   wire                href        ,
    input   wire                vsync       ,
    
    //axi glb signal
    input  wire                clk     ,
    input wire                rst_n   ,

    //rd_addr_channel
    input   [ID_MAX_WIDTH-1           :0]                 arid      ,
    input   [ADDR_WIDTH - 1           :0]                 araddr    ,
    input   [3                        :0]                 arlen     ,
    input   [2                        :0]                 arsize    ,
    input   [1                        :0]                 arbrust   ,
    input   [1                        :0]                 arlock    ,
    input   [3                        :0]                 arcache   ,
    input   [2                        :0]                 arprot    ,
    input   [3                        :0]                 arqos     ,
    input   [3                        :0]                 arregion  ,
    input                                                 arvalid   ,
    output                                                arready   ,


    //rd_data_channel
    output  [ID_MAX_WIDTH-1  :0]                            rid      ,
    output  [DATA_WIDTH-1    :0]                            rdata    ,
    output  [1               :0]                            rresp    ,
    output                                                  rlast    ,
    output                                                  ruser    ,
    output                                                  rvalid   ,
    input                                                   rready   ,


    //wr_addr_channel

    input  [ID_MAX_WIDTH-1           :0]                    awid     ,
    input  [ADDR_WIDTH - 1           :0]                    awaddr   ,
    input  [3                        :0]                    awlen    ,
    input  [2                        :0]                    awsize   ,
    input  [1                        :0]                    awbrust  ,
    input  [1                        :0]                    awlock   ,
    input  [3                        :0]                    awcache  ,
    input  [2                        :0]                    awprot   ,
    input  [3                        :0]                    awqos    , 
    input                                                   awvalid  , 
    output                                                  awready  , 


    //wr_data_channel
    input  [ID_MAX_WIDTH-1           :0]                    wid     ,
    input  [DATA_WIDTH - 1           :0]                    wdata   ,
    input  [DATA_WIDTH/8 -1          :0]                    wstrb   ,
    input                                                   wlast   ,
    input                                                   wvalid  ,
    output                                                  wready  ,

    //wr_resp_channel
    output [ID_MAX_WIDTH-1:0]                                            bid     ,
    output [1:0]                                            bresp   ,
    output                                                  buser   ,
    output                                                  bvalid  ,
    input                                                   bready  
    
);
axi_glb_signal inst_glb_signal() ;
assign inst_glb_signal.rst_n     = rst_n     ;
assign inst_glb_signal.clk   = clk   ;

axi_rd_addr_channel inst_rd_addr_channel();
assign inst_rd_addr_channel.arid      = arid                           ;
assign inst_rd_addr_channel.araddr    = araddr                         ;
assign inst_rd_addr_channel.arlen     = arlen                          ;
assign inst_rd_addr_channel.arsize    = arsize                         ;
assign inst_rd_addr_channel.arbrust   = arbrust                        ;
assign inst_rd_addr_channel.arlock    = arlock                         ;
assign inst_rd_addr_channel.arcache   = arcache                        ;
assign inst_rd_addr_channel.arprot    = arprot                         ;
assign inst_rd_addr_channel.arqos     = arqos                          ;
assign inst_rd_addr_channel.arregion  = arregion                       ;
assign inst_rd_addr_channel.arvalid   = arvalid                        ;
assign arready                        = inst_rd_addr_channel.arready   ;

axi_rd_data_channel inst_rd_data_channel();
assign  rid                           = inst_rd_data_channel.rid      ; 
assign  rdata                         = inst_rd_data_channel.rdata    ; 
assign  rresp                         = inst_rd_data_channel.rresp    ; 
assign  rlast                         = inst_rd_data_channel.rlast    ; 
assign  ruser                         = inst_rd_data_channel.ruser    ; 
assign  rvalid                        = inst_rd_data_channel.rvalid   ; 
assign  inst_rd_data_channel.rready   = rready                        ;

axi_wr_addr_channel inst_wr_addr_channel();
assign  inst_wr_addr_channel.awid     = awid                          ;       
assign  inst_wr_addr_channel.awaddr   = awaddr                        ;       
assign  inst_wr_addr_channel.awlen    = awlen                         ;       
assign  inst_wr_addr_channel.awsize   = awsize                        ;       
assign  inst_wr_addr_channel.awbrust  = awbrust                       ;       
assign  inst_wr_addr_channel.awlock   = awlock                        ;       
assign  inst_wr_addr_channel.awcache  = awcache                       ;       
assign  inst_wr_addr_channel.awprot   = awprot                        ;       
assign  inst_wr_addr_channel.awqos    = awqos                         ;       
assign  inst_wr_addr_channel.awvalid  = awvalid                       ;       
assign  awready                       = inst_wr_addr_channel.awready  ;


axi_wr_data_channel inst_wr_data_channel();
assign  inst_wr_data_channel.wid     = wid                     ;  
assign  inst_wr_data_channel.wdata   = wdata                   ;  
assign  inst_wr_data_channel.wstrb   = wstrb                   ;  
assign  inst_wr_data_channel.wlast   = wlast                   ;  
assign  inst_wr_data_channel.wvalid  = wvalid                  ;  
assign  wready                       = inst_wr_data_channel.wready  ;



axi_wr_rsp_channel inst_wr_rsp_channel();

assign  bid                          = inst_wr_rsp_channel.bid     ;
assign  bresp                        = inst_wr_rsp_channel.bresp   ;
assign  buser                        = inst_wr_rsp_channel.buser   ;
assign  bvalid                       = inst_wr_rsp_channel.bvalid  ;
assign  inst_wr_rsp_channel.bready  = bready                     ;


cnn_top inst_cnn_top(
.glb_signal      (inst_glb_signal),
.rd_addr_channel (inst_rd_addr_channel),
.wr_addr_channel (inst_wr_addr_channel),
.rd_data_channel (inst_rd_data_channel),
.wr_data_channel (inst_wr_data_channel),
.wr_rsp_channel  (inst_wr_rsp_channel ),
.o_interrupt     (o_interrupt         ),
.o_rgb           (o_rgb               ),
.o_rgb_clk       (o_rgb_clk           ),
.lcd_de          (lcd_de              ),
.lcd_rst_n       (lcd_rst_n           ),
.lcd_bl          (lcd_bl              ),
.lcd_hs          (lcd_hs              ),
.lcd_vs          (lcd_vs              ),
.ova_cfg_scl     (ova_cfg_scl         ),
.ova_cfg_sda     (ova_cfg_sda         ),
.i_pclk          (i_pclk              ),
.i_data          (i_data              ),
.href            (href                ),
.vsync           (vsync               ) 
);

endmodule