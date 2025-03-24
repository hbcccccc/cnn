module rgb_top(
    input   wire                clk         ,
    input   wire                i_rst_n     ,
    output  wire    [23:0]      o_rgb       ,
(* MARK_DEBUG="true" *)    output  wire                o_rgb_clk   ,
(* MARK_DEBUG="true" *)    output  wire                lcd_de      ,
(* MARK_DEBUG="true" *)    output  wire                lcd_rst_n   ,
(* MARK_DEBUG="true" *)    output  wire                lcd_bl      ,
(* MARK_DEBUG="true" *)    output  wire                lcd_hs      ,
(* MARK_DEBUG="true" *)    output  wire                lcd_vs      
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
.r             (8'hff      ),
.g             (8'hff       ),
.b             (8'hff       ),
.i_data_vld    (1'b1        ),
.o_line_sync   (     ),
.o_frame_sync   (      ),
//.o_data_vld    (lcd_de      ),
.o_data_ready  (lcd_de       ),
.o_r           (o_rgb[7:0]  ),
.o_g           (o_rgb[15:8] ),
.o_b           (o_rgb[23:16]) 
);


endmodule