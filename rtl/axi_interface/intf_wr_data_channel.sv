interface axi_wr_data_channel();
parameter ID_MAX_WIDTH  = 4;
parameter DATA_WIDTH    = 32;


    logic  [ID_MAX_WIDTH-1           :0]        wid     ;
    logic  [DATA_WIDTH - 1           :0]        wdata   ;
    logic  [DATA_WIDTH/8 -1          :0]        wstrb   ;
    logic                                       wlast   ;
    //logic                                       wuser   ;
    logic                                       wvalid  ;
    logic                                       wready  ;
    
    modport slave (
        input  wvalid   ,
        output wready   ,
        input  wid      ,
        input  wdata    ,
        input  wstrb    ,
        input  wlast    
    //    input  wuser
    );

    modport master (
        output wvalid   ,
        input  wready   ,
        output wid      ,
        output wdata    ,
        output wstrb    ,
        output wlast    
 //       output wuser
    );



endinterface