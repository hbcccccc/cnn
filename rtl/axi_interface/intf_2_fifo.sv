interface intf_to_fifo();
    logic  fifo_rd_en ;
    logic  fifo_wr_en ;
    logic  fifo_choose;

    logic  [15:0] fifo1_rd_data;
    logic  [15:0] fifo1_wr_data;
    logic  [15:0] fifo2_rd_data;
    logic  [15:0] fifo2_wr_data;

    modport slave (
        output   fifo_rd_en   ,
        output   fifo_wr_en   ,
        output   fifo_choose  ,
        input    fifo1_rd_data,
        output   fifo1_wr_data,
        input    fifo2_rd_data,
        output   fifo2_wr_data
    );

endinterface