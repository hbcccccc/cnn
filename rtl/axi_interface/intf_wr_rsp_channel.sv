interface axi_wr_rsp_channel() ;
    parameter DATA_WIDTH = 32;
    parameter ADDR_WIDTH = 32;
    parameter ID_MAX_WIDTH  = 12;

logic      [ID_MAX_WIDTH-1:0]         bid     ;
logic      [1:0]         bresp   ;
logic                    buser   ;
logic                    bvalid  ;
logic                    bready  ;  


modport master (
    input  bvalid   ,
    output bready   ,
    input  bid      ,
    input  bresp    ,
    input  buser
);

modport slave (
    output bvalid   ,
    input  bready   ,
    output bid      ,
    output bresp    ,
    output buser
);
    
endinterface //wr_rsp_channel #()