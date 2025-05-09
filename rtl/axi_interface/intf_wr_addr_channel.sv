interface axi_wr_addr_channel();

    parameter ID_MAX_WIDTH  = 16;
    parameter ADDR_WIDTH    = 32;


logic      [ID_MAX_WIDTH-1           :0]                    awid      ;
logic      [ADDR_WIDTH - 1           :0]                    awaddr    ;
logic      [3                        :0]                    awlen     ;
logic      [2                        :0]                    awsize    ;
logic      [1                        :0]                    awbrust   ;
logic      [1                        :0]                    awlock    ;
logic      [3                        :0]                    awcache   ;
logic      [2                        :0]                    awprot    ;
logic      [3                        :0]                    awqos     ;
//logic                           awuser    ;
logic                           awvalid   ;
logic                           awready   ;


modport slave (
    input  awvalid   ,
    output awready   ,
    input  awid      ,
    input  awaddr    ,
    input  awlen     ,
    input  awsize    ,
    input  awbrust   ,
    input  awlock    ,
    input  awcache   ,
    input  awprot    ,
    input  awqos     
//    input  awuser   
);

modport master (
    output awvalid   ,
    input  awready   ,
    output awid      ,
    output awaddr    ,
    output awlen     ,
    output awsize    ,
    output awbrust   ,
    output awlock    ,
    output awcache   ,
    output awprot    ,
    output awqos     
//    output awuser
);
endinterface