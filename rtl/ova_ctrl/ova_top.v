module ova_top(
    input   wire            clk         ,
    input   wire            rst_n       ,

    input   wire            i_pclk      ,
    input   wire   [7:0]    i_data      ,
    input   wire            href        ,
    input   wire            vsync       ,
    //input   wire            i_fifo_empty,
    output  wire   [15:0]    o_data      ,
    output  wire            o_data_vld  ,
    output  wire            o_fifo_work_en,
    output  wire            o_fifo_choose ,

    output              ova_cfg_scl ,
    inout               ova_cfg_sda 
);

wire    [15:0] w_iic_addr   ;
wire           w_iic_wr_req ;
wire           w_iic_rd_req ;
wire    [05:0] w_iic_wr_byte_num ;
wire    [05:0] w_iic_rd_byte_num ;
wire    [07:0] w_iic_wr_data    ;
wire    [07:0] w_iic_rd_data    ;
wire           w_iic_work_done  ;
wire           w_iic_req_new_data;

i2c_dirver#(
.SYS_CLK     (50_000_000),
.SCL_CLK     (400_000	),
.ADDR_NUM    (1'b0      ),
.DEVICE_ADDR (8'h21		)      
)
inst_ova_i2c_driver
(
.clk                 (clk                ),
.rst_n               (rst_n              ),
.i_iic_addr          (w_iic_addr         ),
.o_curr_work_done    (w_iic_work_done    ),
.i_iic_wr_req        (w_iic_wr_req       ),
.i_iic_wr_data       (w_iic_wr_data      ),
.i_iic_wr_byte_num   (w_iic_wr_byte_num  ),
.o_req_new_byte      (w_iic_req_new_data ),
.i_iic_rd_req        (w_iic_rd_req       ),
.i_iic_rd_byte_num   (w_iic_rd_byte_num  ),
.o_iic_rd_byte       (w_iic_rd_data      ),
.o_iic_rd_byte_vld   (),
.o_iic_error         (),
.o_scl               (ova_cfg_scl        ),
.sda                 (ova_cfg_sda)                  
);  



ova_cfg_hardware inst_ova_cfg(
.clk             		(clk                ),
.rst_n           		(rst_n              ),
.o_iic_wr_req    		(w_iic_wr_req       ),
.o_iic_rd_req    		(w_iic_rd_req       ),
.o_iic_wr_byte_num		(w_iic_wr_byte_num  ),
.o_iic_rd_byte_num		(w_iic_rd_byte_num  ),
.o_iic_addr      		(w_iic_addr         ),
.o_iic_wr_data   		(w_iic_wr_data      ),
.i_iic_rd_data   		(w_iic_rd_data      ),
.i_iic_work_done 		(w_iic_work_done    ),
.i_iic_req_new_byte 	(w_iic_req_new_data )
);


ova_read inst_ova_read(
.i_data                  (i_data             ),
.i_pclk                  (i_pclk             ),
.rst_n                   (rst_n              ),
.href                    (href               ),
.vsync                   (vsync              ),
//.i_fifo_empty            (i_fifo_empty       ),
.o_data                  (o_data             ),
.o_data_vld              (o_data_vld         ),
.o_fifo_choose           (o_fifo_choose      ),
.o_fifo_work_en          (o_fifo_work_en     )
);

endmodule