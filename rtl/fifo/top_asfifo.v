module top_asfifo
#(
    parameter depth = 8,
    parameter width = 8

)
(
    input               wr_clk      ,
    input               rd_clk      ,

    input               wr_en       ,
    input [width-1:0]   wr_data     ,
    input               rd_en       ,
    output [width-1:0]  rd_data     ,
    input               rest_n      ,
    output              full        ,
    output     wire         data_out_vld,
    output     wire         empty
);

wire full_pointer;
wire [$clog2(depth)-1:0] rd_addr;
wire [$clog2(depth)-1:0] wr_addr;

fifo_pointer #(
    .depth(depth)
)
inst_pointer(
    .wr_clk         (wr_clk             ),
    .rd_clk         (rd_clk             ),
    .wr_en          (wr_en              ),
    .rd_en          (rd_en              ),
    .rest_n         (rest_n             ),
    .wr_addr        (wr_addr            ),
    .rd_addr        (rd_addr            ),
    .full           (full               ),
    .empty          (empty              )
);

fifo_memory #(
.depth(depth),
.width(width))
inst_memory
(
    .wr_clk         (wr_clk             ),
    .rd_clk         (rd_clk             ),
    .data_in        (wr_data            ),
    .write_en       (wr_en && (~full)   ),
    .read_en        (rd_en              ),
    .write_addr     (wr_addr            ),
    .read_addr      (rd_addr            ),
    .data_out       (rd_data            ),
    .data_out_vld   (data_out_vld       )
);






endmodule
