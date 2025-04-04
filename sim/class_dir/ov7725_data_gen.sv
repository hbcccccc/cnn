class ov7725_data_gen;
virtual intf_ov7725_data vif;

function  new(input virtual intf_ov7725_data vif);
    this.vif = vif;
    vif.data = 16'd0;
    vif.vsync <= 1'b0;
    vif.href = 1'b0;
endfunction

task data_gen();

    #100ns;
    repeat(5) begin
        @(posedge vif.pclk);
        vif.vsync <= 1'b1;
        #100ns;
        vif.vsync <= 1'b0;
        #200ns;
        repeat(480) begin
            repeat(640*2) begin
                @(posedge vif.pclk);
                vif.href <= 1'b1;
                vif.data <= vif.data + 1'b1;
            end
            //@(posedge vif.pclk);
            vif.href <= 1'b0;
            #500ns;
        end
    end
endtask

task clk_gen();
    vif.pclk = 1'b0;
    forever begin
        #15ns; vif.pclk <= ~vif.pclk;
    end
endtask

task run();
    fork
        data_gen();
        clk_gen();
    join_none
endtask

endclass