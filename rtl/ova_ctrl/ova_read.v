module ova_read(
    input   wire    [07:0]  i_data      ,
    input   wire            i_pclk      ,
    input   wire            rst_n       ,
    input   wire            href        ,
    input   wire            vsync       ,


    input   wire            i_fifo_empty,
    output  wire    [15:0]  o_data      ,
    output  wire            o_data_vld  ,
    output  wire            o_fifo_work_en 
);

    wire    [07:0]  r_data_1d;
    wire            w_data_vld_turn = ~o_data_vld;

    wire            w_fifo_load_en = vsync ;

    wire            r_fifo_empty_1d ;
 


//register declare               load_en              idata            odata            clk     rst_n
dff_default_low #(8) inst_dff_low1(1'b1           ,  i_data          ,r_data_1d      , i_pclk,    rst_n);
dff_default_low #(1) inst_dff_low2(href           ,  w_data_vld_turn ,o_data_vld     , i_pclk,    rst_n);
dff_default_low #(1) inst_dff_low3(1'b1           ,  i_fifo_empty    ,r_fifo_empty_1d , i_pclk,    rst_n);
dff_default_low #(1) inst_dff_low4(w_fifo_load_en ,  r_fifo_empty_1d ,o_fifo_work_en , i_pclk,    rst_n);

assign o_data = {r_data_1d,i_data};


endmodule