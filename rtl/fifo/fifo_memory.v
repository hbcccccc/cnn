module fifo_memory
#(parameter depth = 8,
  parameter width = 8)
(
    input wire wr_clk,
    input wire rd_clk,

    input wire [width-1:0] data_in,
    input wire write_en,
    input wire read_en,
    
    input wire [$clog2(depth)-1:0] write_addr,
    input wire [$clog2(depth)-1:0] read_addr,
    output reg [width-1:0] data_out ,
    output reg data_out_vld
);

reg [width-1:0] data_reg [depth-1:0];//前者表示位宽，后者表示组数


always @(posedge wr_clk ) begin
    if(write_en)
        data_reg[write_addr] <= data_in;
end

always @(posedge rd_clk ) begin
    if(read_en) 
        data_out <= data_reg[read_addr];
end

always @(posedge rd_clk ) begin
    if(read_en) 
        data_out_vld <= 1'b1;
    else 
        data_out_vld <= 1'b0;
end

endmodule
