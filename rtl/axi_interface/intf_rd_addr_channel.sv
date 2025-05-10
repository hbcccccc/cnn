interface axi_rd_addr_channel();
    parameter DATA_WIDTH    = 32;
    parameter ADDR_WIDTH    = 32;
    parameter ID_MAX_WIDTH  = 12;
    
    logic     [ID_MAX_WIDTH-1           :0]                 arid      ;
    logic     [ADDR_WIDTH - 1           :0]                 araddr    ;
    logic     [3                        :0]                 arlen     ;
    logic     [2                        :0]                 arsize    ;
    logic     [1                        :0]                 arbrust   ;
    logic     [1                        :0]                 arlock    ;
    logic     [3                        :0]                 arcache   ;
    logic     [2                        :0]                 arprot    ;
    logic     [3                        :0]                 arqos     ;
    logic     [3                        :0]                 arregion  ;
//    logic                                                   aruser    ;
    logic                                                   arvalid   ;
    logic                                                   arready   ;


modport master (
    output arvalid   ,
    input  arready   ,
    output arid      ,
    output araddr    ,
    output arlen     ,
    output arsize    ,
    output arbrust   ,
    output arlock    ,
    output arcache   ,
    output arprot    ,
    output arqos     ,
    output arregion  
//    output aruser
);

modport slave (
    input  arvalid   ,
    output arready   ,
    input  arid      ,
    input  araddr    ,
    input  arlen     ,
    input  arsize    ,
    input  arbrust   ,
    input  arlock    ,
    input  arcache   ,
    input  arprot    ,
    input  arqos     ,
    input  arregion  
//    input  aruser
);


endinterface