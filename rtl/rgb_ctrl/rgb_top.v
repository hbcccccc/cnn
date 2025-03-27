module rgb_top(
    input   wire                clk         ,
    input   wire                i_rst_n     ,
    output  wire    [23:0]      o_rgb       ,


    input   wire    [23:0]      i_rgb       ,
    input   wire                i_data_vld  ,
    output  wire                o_data_ready,

    output  wire                o_rgb_clk   ,
    output  wire                lcd_de      ,
    output  wire                lcd_rst_n   ,
    output  wire                lcd_bl      ,
    output  wire                lcd_hs      ,
    output  wire                lcd_vs      ,


    input   wire                i_fifo_empty        ,
    input   wire                i_fifo_rec_work_en  ,
    //output  wire                o_fifo_work_en      ,
    output  wire                o_fifo_read_en      ,
    input   wire    [15:0]      i_fifo_rd_data      ,
    input   wire                i_fifo_rd_data_vld  
);

wire    clk_div             ;
assign  o_rgb_clk = clk_div     ;
assign  lcd_bl = 1'b1       ;
assign  lcd_rst_n = i_rst_n ;
assign  lcd_hs = 1'b1;
assign  lcd_vs = 1'b1;


clk_div inst_clk_div(
.clk         (clk       ),
.i_rst_n     (i_rst_n   ),
.clk_div     (clk_div   )
);


//fifo ctrl 
wire    r_fifo_rec_work_en_1d;
wire    r_fifo_rec_work_en_2d;
wire    w_fifo_read_en      =     ~r_fifo_rec_work_en_2d ? 
                                  ~i_fifo_empty          ? 1'b1 : 1'b0 : 1'b0;


wire    [7:0]   w_red_data      = {i_fifo_rd_data[15:11],3'd0};
wire    [7:0]   w_green_data    = {i_fifo_rd_data[10:5],2'd0};
wire    [7:0]   w_blue_data      = {i_fifo_rd_data[4:0],3'd0};



dff_default_low #(1) inst_dff_low1(1'b1 , i_fifo_rec_work_en    , r_fifo_rec_work_en_1d , clk, i_rst_n);
dff_default_low #(1) inst_dff_low2(1'b1 , r_fifo_rec_work_en_1d , r_fifo_rec_work_en_2d , clk, i_rst_n);
dff_default_low #(1) inst_dff_low3(1'b1 , w_fifo_read_en , o_fifo_read_en , clk, i_rst_n);




sync_gen inst_sync_gen(
.i_clk         (clk_div                       ),  
.i_rst_n       (i_rst_n                       ),
.r             (w_red_data                    ),
.g             (w_green_data                  ),
.b             (w_red_data                    ),
.i_data_vld    (i_fifo_rd_data_vld            ),
.o_line_sync   (            ),
.o_frame_sync  (            ),
//.o_data_vld    (lcd_de      ),
.o_data_ready  (lcd_de       ),
.o_r           (o_rgb[7:0]  ),
.o_g           (o_rgb[15:8] ),
.o_b           (o_rgb[23:16]) 
);


endmodule