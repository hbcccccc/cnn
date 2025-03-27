
module tb_asfifo();
    parameter depth = 8;
    parameter width = 8;
reg wr_clk;
reg rd_clk;
reg rd_en;
reg wr_en;
reg rest_n;
wire full;
wire empty;

reg [width-1:0] wr_data;
wire [width-1:0] rd_data;

initial begin
    wr_clk = 1'b0;
    rd_clk = 1'b0;
    rest_n <= 1'b0;
    wr_en <= 1'b0;
    rd_en <= 1'b0;
    #30;
    rest_n <= 1'b1;
    
    repeat(200) #20;
    $finish;
end
 
always #10 wr_clk <= ~wr_clk;
always #15 rd_clk <= ~rd_clk;



initial begin
    $fsdbDumpfile("tb_asfifo.fsdb");
    $fsdbDumpvars;
end

always @(posedge wr_clk)
if(full != 1'b1)
        begin
            wr_en <= ($random)%2;         
            wr_data <= ($random)%256;
        end

always @(posedge rd_clk)
        begin
            if(empty!=1'b1 && wr_en !=1'b1) 
                rd_en <= ($random)%2; 
        end

top_asfifo inst_fifo(
    .wr_clk(wr_clk),
    .rd_clk(rd_clk),
    .wr_en(wr_en),
    .rd_en(rd_en),
    .wr_data(wr_data),
    .rd_data(rd_data),
    .full(full),
    .empty(empty),
    .rest_n(rest_n)
);

endmodule