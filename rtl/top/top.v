module cnn_top(
    //connected with rgb_lcd
    input   wire                clk         ,
    input   wire                rst_n       ,
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
    input   wire                vsync       

);

wire                w_fifo_empty                        ;
wire                w_ova_fifo_ctrl_en                  ;
wire    [15:00]     w_ova_rece_data                     ;
wire                w_ova_rec_data_vld                  ;
wire                w_rgb_fifo_rd_en                    ;
wire                w_fifo_wr_en  = w_ova_rec_data_vld && (w_ova_fifo_ctrl_en);
wire    [15:0]      w_rgb_rd_data                       ;
wire                w_rgb_rd_data_vld                   ;
ova_top inst_ova(
.clk            (clk           ),
.rst_n          (rst_n         ),
.ova_cfg_scl    (ova_cfg_scl   ),
.ova_cfg_sda    (ova_cfg_sda   ),

.i_pclk         (i_pclk),
.i_data         (i_data),
.href           (href),
.vsync          (vsync),
.i_fifo_empty   (w_fifo_empty),
.o_data         (w_ova_rece_data),
.o_data_vld     (w_ova_rec_data_vld),
.o_fifo_work_en (w_ova_fifo_ctrl_en)

);



rgb_top inst_rgb_top(
.clk                (clk            ),
.i_rst_n            (rst_n          ),
.o_rgb              (o_rgb          ),
.i_rgb              (24'd0          ),
.i_data_vld         (1'b0           ),
.o_data_ready       (),
.o_rgb_clk          (o_rgb_clk      ),
.lcd_de             (lcd_de         ),
.lcd_rst_n          (lcd_rst_n      ),
.lcd_bl             (lcd_bl         ),
.lcd_hs             (lcd_hs         ),
.lcd_vs             (lcd_vs         ),
.i_fifo_empty       (w_fifo_empty   ),
.i_fifo_rec_work_en (w_ova_fifo_ctrl_en),
.o_fifo_read_en     (w_rgb_fifo_rd_en )  ,
.i_fifo_rd_data     (w_rgb_rd_data)  ,
.i_fifo_rd_data_vld (w_rgb_rd_data_vld)

);



top_asfifo#(
    .depth(307400),
    .width(16   )
)
inst_asfifo(
.wr_clk      (i_pclk),
.rd_clk      (o_rgb_clk),
.wr_en       (w_fifo_wr_en),
.wr_data     (w_ova_rece_data),
.rd_en       (w_rgb_fifo_rd_en),
.rd_data     (w_rgb_rd_data),
.rest_n      (rst_n),
.full        (),
.data_out_vld(w_rgb_rd_data_vld),
.empty       (w_fifo_empty)

);

endmodule