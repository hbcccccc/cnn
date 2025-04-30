module cnn_top_verilog_wrapper
#(
    parameter DATA_WIDTH    = 32,
    parameter ID_MAX_WIDTH  = 16,
    parameter ADDR_WIDTH   = 32
)
(
input                                                 clk,
input                                                 rst_n,
output  wire                                          o_interrupt     ,
output  wire    [23:0]                                o_rgb       ,
output  wire                                          o_rgb_clk   ,
output  wire                                          lcd_de      ,
output  wire                                          lcd_rst_n   ,
output  wire                                          lcd_bl      ,
output  wire                                          lcd_hs      ,
output  wire                                          lcd_vs      ,
output  wire                                          ova_cfg_scl ,
inout   wire                                          ova_cfg_sda ,
input   wire                                          i_pclk      ,
input   wire   [7:0]                                  i_data      ,
input   wire                                          href        ,
input   wire                                          vsync       ,

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

output   [ID_MAX_WIDTH-1  :0]                         rid      ,
output   [DATA_WIDTH-1    :0]                         rdata    ,
output   [1               :0]                         rresp    ,
output                                                rlast    ,
//output                                                ruser    ,
output                                                rvalid   ,
input                                                 rready   ,


input   [ID_MAX_WIDTH-1           :0]                 wid        ,
input   [DATA_WIDTH - 1           :0]                 wdata      ,
input   [DATA_WIDTH/8 -1          :0]                 wstrb      ,
input                                                 wlast      ,
input                                                 wvalid     ,
output                                                wready     ,

input   [ID_MAX_WIDTH-1           :0]                 awid      ,
input   [ADDR_WIDTH - 1           :0]                 awaddr    ,
input   [3                        :0]                 awlen     ,
input   [2                        :0]                 awsize    ,
input   [1                        :0]                 awbrust   ,
input   [1                        :0]                 awlock    ,
input   [3                        :0]                 awcache   ,
input   [2                        :0]                 awprot    ,
input   [3                        :0]                 awqos     ,
input                                                 awvalid   ,
output                                                awready   ,

output  [3:0]                                         bid        ,
output  [1:0]                                         bresp      ,
//output                                                buser      ,
output                                                bvalid     ,
input                                                 bready     


);
axi_glb_signal          glb_signal      ();
axi_rd_addr_channel 	rd_addr_channel ();
axi_wr_addr_channel 	wr_addr_channel ();
axi_rd_data_channel 	rd_data_channel ();
axi_wr_data_channel 	wr_data_channel ();
axi_wr_rsp_channel 		wr_rsp_channel  ();

cnn_top inst_cnn_top(
.glb_signal            (glb_signal          ),
.rd_addr_channel       (rd_addr_channel     ),
.rd_data_channel       (rd_data_channel     ),
.wr_addr_channel       (wr_addr_channel     ),
.wr_data_channel       (wr_data_channel     ),
.wr_rsp_channel        (wr_rsp_channel      ),    


.o_interrupt     (o_interrupt ),
.o_rgb           (o_rgb       ),
.o_rgb_clk       (o_rgb_clk   ),
.lcd_de          (lcd_de      ),
.lcd_rst_n       (lcd_rst_n   ),
.lcd_bl          (lcd_bl      ),
.lcd_hs          (lcd_hs      ),
.lcd_vs          (lcd_vs      ),
.ova_cfg_scl     (ova_cfg_scl ),
.ova_cfg_sda     (ova_cfg_sda ),
.i_pclk          (i_pclk      ),
.i_data          (i_data      ),
.href            (href        ),
.vsync           (vsync       )    
);

assign glb_signal.clk = clk;
assign glb_signal.rst_n = rst_n;

assign  arid      = rd_addr_channel.arid    ;
assign  araddr    = rd_addr_channel.araddr  ;
assign  arlen     = rd_addr_channel.arlen   ;
assign  arsize    = rd_addr_channel.arsize  ;
assign  arbrust   = rd_addr_channel.arbrust ;
assign  arlock    = rd_addr_channel.arlock  ;
assign  arcache   = rd_addr_channel.arcache ;
assign  arprot    = rd_addr_channel.arprot  ;
assign  arqos     = rd_addr_channel.arqos   ;
assign  arregion  = rd_addr_channel.arregion;
assign  arvalid   = rd_addr_channel.arvalid ;
assign  rd_addr_channel.arready   = arready ;


assign  rd_data_channel.rvalid = rvalid;
assign  rid     = rd_data_channel.rid    ;
assign  rdata   = rd_data_channel.rdata  ;
assign  rresp   = rd_data_channel.rresp  ;
assign  rlast   = rd_data_channel.rlast  ;
//assign  ruser   = rd_data_channel.ruser  ;
assign  rready  = rd_data_channel.rready ;

assign  wr_data_channel.wid    =   wid   ;
assign  wr_data_channel.wdata  =   wdata ;
assign  wr_data_channel.wstrb  =   wstrb ;
assign  wr_data_channel.wlast  =   wlast ;
assign  wr_data_channel.wvalid =wvalid;
assign  wready     = wr_data_channel.wready     ;

assign  wr_addr_channel.awid     =   awid    ;
assign  wr_addr_channel.awaddr   =   awaddr  ;
assign  wr_addr_channel.awlen    =   awlen   ;
assign  wr_addr_channel.awsize   =   awsize  ;
assign  wr_addr_channel.awbrust  =   awbrust ;
assign  wr_addr_channel.awlock   =   awlock  ;
assign  wr_addr_channel.awcache  =   awcache ;
assign  wr_addr_channel.awprot   =   awprot  ;
assign  wr_addr_channel.awqos    =   awqos   ;
assign  wr_addr_channel.awvalid  =   awvalid ;
assign  awready                  =  wr_addr_channel.awready  ;

assign  bid                      = wr_rsp_channel.bid    ;  
assign  bresp                    = wr_rsp_channel.bresp  ;  
//assign  buser                    = wr_rsp_channel.buser  ;  
assign  bvalid                   = wr_rsp_channel.bvalid ;  


assign  wr_rsp_channel.bready                   =  bready;


endmodule
