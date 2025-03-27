module fifo_pointer
#(parameter depth = 8)
(
    input wr_clk,
    input rd_clk,
    input wr_en,
    input rd_en,
    input rest_n,

    output [$clog2(depth)-1:0] wr_addr,
    output [$clog2(depth)-1:0] rd_addr,

    output full,
    output empty
);

reg [$clog2(depth):0] wr_addr_bin;
reg [$clog2(depth):0] rd_addr_bin;

reg [$clog2(depth):0] wr_addr_gray;
reg [$clog2(depth):0] rd_addr_gray;

reg [$clog2(depth):0] wr_addr_gray_reg1;
reg [$clog2(depth):0] rd_addr_gray_reg1;

reg [$clog2(depth):0] wr_addr_gray_reg2;
reg [$clog2(depth):0] rd_addr_gray_reg2;

reg [$clog2(depth):0] wr_to_rd;
reg [$clog2(depth):0] rd_to_wr;



integer  i;
integer  j;
//在写时钟域下，递增普通二进制写地址//secend : 通过额外加一位,第一位用于判断空满
always @(posedge wr_clk or negedge rest_n) begin
    if(!rest_n)
        wr_addr_bin <= 'b0;
    else if(wr_en == 1'b1 && full == 1'b0)
        wr_addr_bin <= wr_addr_bin + 1'b1;
    else 
       wr_addr_bin <= wr_addr_bin;
end

//转为格雷码并消除竞争冒险的影响：通过再加一级寄存器
always @(posedge wr_clk or negedge rest_n) begin
    if(!rest_n)
        wr_addr_gray <= 'b0;
    else 
        wr_addr_gray <= {wr_addr_bin[$clog2(depth)],wr_addr_bin[$clog2(depth):1] ^ wr_addr_bin[$clog2(depth)-1:0]}; 
end


//对读指针的处理同理，先递增二进制地址，在转为格雷码格式
always @(posedge rd_clk or negedge rest_n) begin
    if(!rest_n)
        rd_addr_bin <= 'b0;
    else if(rd_en == 1'b1 && empty == 1'b0)
        rd_addr_bin <= rd_addr_bin + 1'b1;
    else 
        rd_addr_bin <= rd_addr_bin;
end

always @(posedge rd_clk or negedge rest_n) begin
    if(!rest_n)
        rd_addr_gray <= 'b0;
    else 
        rd_addr_gray <= {rd_addr_bin[$clog2(depth)],rd_addr_bin[$clog2(depth):1]^rd_addr_bin[$clog2(depth)-1:0]}; 
end



//将产生的格雷分别经过两级寄存器传输到另外一个时钟域
//写地址同步到读时钟域
always @(posedge rd_clk or negedge rest_n) begin
    if(!rest_n) begin
        wr_addr_gray_reg1 <= 'b0;
        wr_addr_gray_reg2 <= 'b0;
    end
    else 
        begin
            wr_addr_gray_reg1 <= wr_addr_gray;
            wr_addr_gray_reg2 <= wr_addr_gray_reg1;
        end
    
end

//将读地址同步到写时钟域
always @(posedge wr_clk or negedge rest_n) begin
    if(!rest_n)
        begin
            rd_addr_gray_reg1 <= 'b0;
            rd_addr_gray_reg2 <= 'b0;
        end
    else 
        begin
            rd_addr_gray_reg1 <= rd_addr_gray;
            rd_addr_gray_reg2 <= rd_addr_gray_reg1;
        end
end

/*一些思考：为什么不直拿同步到写时钟域的读指针格雷码与写地址转码后的格雷码做比较？
可能是由于，写地址转格雷码也有延迟，例如传来的读地址是5，转码后的写地址也是5，这时可能实际的写地址已经变成7了，就会在满的情况下依旧写
但把传来的读地址格雷码再转为二进制编码，可能仅仅只会增加一些延迟，从而降低一点fifo的效率，不会出现错误*/

//格雷码解码:将二级寄存的写指针从格雷码转为二进制编码
always @(*) begin
    wr_to_rd[$clog2(depth)] <= wr_addr_gray_reg2[$clog2(depth)];
    for (j = $clog2(depth)-1;j >=0;j=j-1)
        wr_to_rd[j] = wr_to_rd[j+1] ^ wr_addr_gray_reg2[j] ;
end
//读地址
always @(*) begin
    rd_to_wr[$clog2(depth)] <= rd_addr_gray_reg2[$clog2(depth)];
    for(i = $clog2(depth)-1;i>=0;i=i-1)
        rd_to_wr[i] = rd_to_wr[i+1] ^ rd_addr_gray_reg2[i];
end



//空满的控制可以采用组合逻辑
//满的判断：转换后的读地址 ＝ 写地址 并且两者的标志信号相反
assign full = ((rd_to_wr[$clog2(depth)] !=  wr_addr_bin[$clog2(depth)]) && rd_to_wr[$clog2(depth)-1:0] == wr_addr_bin[$clog2(depth)-1:0]);

//空的判断：转换后的写地址与读地址相等，并且两者具有相同的标志信号

assign empty = (wr_to_rd == rd_addr_bin);

assign wr_addr = wr_addr_bin[$clog2(depth)-1:0];
assign rd_addr = rd_addr_bin[$clog2(depth)-1:0];

endmodule
