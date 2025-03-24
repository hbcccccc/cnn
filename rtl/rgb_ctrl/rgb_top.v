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
    output  wire                lcd_vs      
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

sync_gen inst_sync_gen(
.i_clk         (clk_div     ),  
.i_rst_n       (i_rst_n     ),
.r             (8'hff       ),
.g             (8'hff       ),
.b             (8'hff       ),
.i_data_vld    (1'b1        ),
.o_line_sync   (            ),
.o_frame_sync  (            ),
//.o_data_vld    (lcd_de      ),
.o_data_ready  (lcd_de       ),
.o_r           (o_rgb[7:0]  ),
.o_g           (o_rgb[15:8] ),
.o_b           (o_rgb[23:16]) 
);


endmodule