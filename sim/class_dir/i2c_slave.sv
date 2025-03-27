class   i2c_slave;

 virtual intf_i2c vif_intf;

 function new(input virtual intf_i2c vif_intf);
    this.vif_intf = vif_intf;
 endfunction 

 task first_ack();
    repeat(8) begin  @(posedge vif_intf.scl); end
    @(negedge vif_intf.scl);
    #10ns;
    vif_intf.sda = 1'b0;
    //@(posedge vif_intf.scl);
    //vif_intf.sda = 1'bz;
 endtask

endclass