module ova_read(
   input   wire    [07:0]  i_data      ,
  (* mark_debug="true" *)  input   wire            i_pclk      ,
 input   wire            rst_n       ,
  (* mark_debug="true" *)  input   wire            href        ,
  (* mark_debug="true" *)  input   wire            vsync       ,


  (* mark_debug="true" *)  input   wire            i_fifo_empty,
   output  wire    [15:0]  o_data      ,
   (* mark_debug="true" *) output  wire            o_data_vld  ,
   (* mark_debug="true" *) output  wire            o_fifo_work_en 
);

    wire    [07:0]  r_data_1d;
    wire            w_data_vld_turn = (~o_data_vld) && (href);

    wire            w_fifo_load_en = vsync ;

    wire            r_fifo_empty_1d ;
 


//register declare               load_en              idata            odata            clk     rst_n
dff_default_low #(8) inst_dff_low1(1'b1           ,  i_data          ,r_data_1d      , i_pclk,    rst_n);
dff_default_low #(1) inst_dff_low2(1'b1           ,  w_data_vld_turn ,o_data_vld     , i_pclk,    rst_n);
dff_default_low #(1) inst_dff_low3(1'b1           ,  i_fifo_empty    ,r_fifo_empty_1d , i_pclk,    rst_n);
dff_default_low #(1) inst_dff_low4(w_fifo_load_en ,  r_fifo_empty_1d ,o_fifo_work_en , i_pclk,    rst_n);

assign o_data = {r_data_1d,i_data};


endmodule