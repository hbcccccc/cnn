
module sync_gen (
    input   wire            i_clk         ,  
    input   wire            i_rst_n       ,
    input   wire  [7:0]     r             ,
    input   wire  [7:0]     g             ,
    input   wire  [7:0]     b             ,
    input   wire            i_data_vld    ,
    output  reg             o_line_sync   ,
    output  reg             o_frame_sync  ,
    //output  reg             o_data_vld    ,
    output  reg             o_data_ready  ,
    output  reg   [7:0]     o_r           ,
    output  reg   [7:0]     o_g           ,
    output  reg   [7:0]     o_b
);
//`ifndef GLOB_FOR_SIM
// 800 * 480 line * frame
//for line cnt 
localparam HSPW     =  128    ; // equals the number of clocks for hsync valid
localparam HBP      =  88   ; // equals the number of clocks before data vld
localparam HOZVAL   =  800  ; // equals the number of clocks of data vld 
localparam HFP      =  40   ; 
//for frame cnt
localparam VSPW     =  2 ;
localparam VBP      =  33  ;
localparam LINE     =  480 ;
localparam VFP      =  10  ;

//`else 
//localparam HSPW     =  3    ; // equals the number of clocks for hsync valid
//localparam HBP      =  20   ; // equals the number of clocks before data vld
//localparam HOZVAL   =  60  ; // equals the number of clocks of data vld 
//localparam HFP      =  12   ; 
//localparam VSPW     =  2   ;
//localparam VBP      =  14  ;
//localparam LINE     =  124 ;
//localparam VFP      =  16  ;

//`endif 

reg [10:0]  r_line_cnt   ;
reg [10:0]  r_frame_cnt  ;   //cnt the number in line

wire    w_line_sync_gen     =     (i_data_vld) && (r_line_cnt == 11'd0)      ? 1'b1    :   1'b0 ;
wire    w_line_sync_clr     =     (i_data_vld) && (r_line_cnt == HSPW )      ? 1'b1    :   1'b0 ;

wire    w_line_cnt_clr       =  (r_line_cnt == (HSPW + HBP + HOZVAL + HFP - 1'b1))     ?   1'b1    :   1'b0    ;
wire    w_frame_cnt_clr       =   (r_frame_cnt == (VSPW + VBP + LINE + VFP))? 1'b1    :   1'b0 ;


wire    w_rec_ready         =     ((r_line_cnt <= (HSPW + HBP + HOZVAL - 1'b1))    && 
                                   (r_line_cnt >= (HSPW + HBP)          )   &&
                                   (r_frame_cnt  >= (VSPW + VBP)          )   &&
                                   (r_frame_cnt  <= (VSPW + VBP + LINE + VFP))&&
                                    i_data_vld                        )     ? 1'b1    :   1'b0 ;


wire    w_frame_sync_gen      =  ((r_frame_cnt == 11'd1) && w_line_sync_gen)    ?   1'b1    :   1'b0    ; 
wire    w_frame_sync_clr      =  (w_line_sync_clr && (r_frame_cnt == VSPW))     ?   1'b1    :   1'b0    ; 




always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        r_line_cnt   <=  11'd0;
    else if(w_line_cnt_clr)
        r_line_cnt   <=  11'd0;
    else if(i_data_vld)
        r_line_cnt   <=  r_line_cnt + 1'b1;
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        r_frame_cnt  <=  11'd0;
    else if(w_frame_cnt_clr)
        r_frame_cnt   <=  11'd0;
    else if(w_line_cnt_clr)
        r_frame_cnt   <=  r_frame_cnt + 1'b1; 
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        o_data_ready    <=  1'b0;
    else if(w_rec_ready)
        o_data_ready    <=  1'b1;
    else
        o_data_ready    <=  1'b0;
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        o_line_sync <=  1'b0;
    else if(w_line_sync_clr)
        o_line_sync <=  1'b0;
    else if(w_line_sync_gen)
        o_line_sync <=  1'b1;
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)
        o_frame_sync  <=  1'b0;
    else if(w_frame_sync_clr)
        o_frame_sync  <=  1'b0;
    else if(w_frame_sync_gen)
        o_frame_sync  <=  1'b1;
end

always @(posedge i_clk or negedge i_rst_n) begin
    if(~i_rst_n)begin
        o_r <=  8'd0;
        o_g <=  8'd0;
        o_b <=  8'd0;
    end
    else begin
        o_r <=  r;
        o_g <=  g;
        o_b <=  b;
    end
end



endmodule