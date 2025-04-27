interface axi_rd_data_channel();

parameter DATA_WIDTH    = 32;
parameter ID_MAX_WIDTH  = 4;


    logic      [ID_MAX_WIDTH-1  :0]                 rid      ;
    logic      [DATA_WIDTH-1    :0]                 rdata    ;
    logic      [1               :0]                 rresp    ;
    logic                                           rlast    ;
    logic                                           ruser    ;
    logic                                           rvalid   ;
    logic                                           rready   ;

modport master (
    input  rvalid   ,
    output rready   ,
    input  rid      ,
    input  rdata    ,
    input  rresp    ,
    input  rlast    ,
    input  ruser
);

modport slave(
    output rvalid   ,
    input  rready   ,
    output rid      ,
    output rdata    ,
    output rresp    ,
    output rlast    ,
    output ruser
);

endinterface