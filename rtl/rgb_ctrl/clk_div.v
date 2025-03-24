module clk_div(
    input   wire        clk     ,
    input   wire        i_rst_n ,
    output  reg         clk_div 
);

    reg cnt;

always @(posedge clk or negedge i_rst_n) begin
    if(~i_rst_n)
        cnt <=  0;
    else
        cnt <=  ~cnt;
end

always @(posedge clk or negedge i_rst_n) begin
    if(~i_rst_n)
        clk_div <=  1'b0;
    else if(cnt == 1'b1)
        clk_div <= ~clk_div;
end

endmodule