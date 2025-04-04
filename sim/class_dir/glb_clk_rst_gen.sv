class glb_clk_rst_gen;
virtual  glb_clk_rst intf;
    function new(input virtual glb_clk_rst vif);
        this.intf = vif;
        intf.clk =   1'b0;
        intf.rst_n = 1'b0;
    endfunction

    task stop_reset();
        #10;
        intf.rst_n = 1'b1;
    endtask

    task clk_gen();
        forever begin
            #1 intf.clk = ~intf.clk;
        end
    endtask


    task run();
        fork
            stop_reset();
            clk_gen()   ;
        join_none

    endtask

endclass