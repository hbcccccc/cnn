class glb_clk_rst_gen;
virtual  axi_glb_signal intf;
    function new(input virtual axi_glb_signal vif);
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

    task random_rst();
    $display("Random reset");
        #10000ns;
       // intf.clk =   1'b0;
        intf.rst_n = 1'b0;
        #100;
    $display("Random reset end");
        stop_reset();
    endtask

    task run();
        fork
            stop_reset();
            clk_gen()   ;
        join_none

    endtask

endclass