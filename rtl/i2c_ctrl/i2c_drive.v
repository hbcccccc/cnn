//the addr map [low 8bit ,high 8bit]
module i2c_dirver #(
parameter SYS_CLK     = 50_000_000,
parameter SCL_CLK     = 400_000   ,
parameter ADDR_NUM    = 2'b01     ,
parameter DEVICE_ADDR = 7'b101_0000      
)
(
  input     wire               clk                 ,
  input     wire               rst_n               ,
  input     wire  [15:0]       i_iic_addr          ,
  output    wire               o_curr_work_done    ,

  input     wire               i_iic_wr_req        ,
  input     wire  [7:0]        i_iic_wr_data       ,
  input     wire  [5:0]        i_iic_wr_byte_num   ,
  output    wire               o_req_new_byte      ,

  input     wire               i_iic_rd_req        ,
  input     wire  [5:0]        i_iic_rd_byte_num   ,
  output    wire   [7:0]       o_iic_rd_byte       ,
  output    wire               o_iic_rd_byte_vld   ,
  output    wire               o_iic_error         ,

  output    wire               o_scl               ,
  inout                        sda                                   
);  
//truly ADDR_NUM ,WR_BYTE_NUM ,RD_BYTE_NUM equal parameters-1 

localparam      ST_IDLE       =5'd0;
localparam      ST_WR_START   =5'd1;
localparam      ST_WR_CTRL    =5'd2;
localparam      ST_WR_ADDR    =5'd3;
localparam      ST_WR_DATA    =5'd4;
localparam      ST_WR_STOP    =5'd5;
localparam      ST_RD_START   =5'd6;
localparam      ST_RD_CTRL    =5'd7;
localparam      ST_RD_DATA    =5'd8;
localparam      ST_RD_STOP    =5'd9;
localparam      ST_ERROR      =5'd10;

localparam      SCL_CNT_MAX   =SYS_CLK/SCL_CLK;

reg [4:0] curr_st;
wire [4:0] next_st;

wire [15:0]  r_scl_cnt;
wire[15:0]  w_scl_cnt;
wire        w_scl_bit;
wire        r_scl_bit;
wire[3:0]   w_scl_num_cnt;
wire[3:0]   r_scl_num_cnt;
wire[5:0]   w_byte_num   ;
wire[5:0]   r_byte_num   ;
wire        w_i_sda        ;
wire        w_o_sda        ;
wire        r_o_sda        ;
reg         w_sda_en       ;
wire        r_sda_en       ;
wire        w_iic_error    ;
wire        w_iic_work_done;
//state declare
wire    w_st_idle      = curr_st == ST_IDLE     ;
wire    w_st_wr_start  = curr_st == ST_WR_START ;
wire    w_st_wr_ctrl   = curr_st ==ST_WR_CTRL   ;
wire    w_st_wr_addr   = curr_st ==ST_WR_ADDR   ;
wire    w_st_wr_data   = curr_st ==ST_WR_DATA   ;
wire    w_st_wr_stop   = curr_st ==ST_WR_STOP   ;
wire    w_st_rd_start  = curr_st ==ST_RD_START  ;
wire    w_st_rd_ctrl   = curr_st ==ST_RD_CTRL   ;
wire    w_st_rd_data   = curr_st ==ST_RD_DATA   ;
wire    w_st_rd_stop   = curr_st ==ST_RD_STOP   ;
wire    w_st_error     = curr_st ==ST_ERROR     ;

wire  w_time_1_4ui  = r_scl_cnt == SCL_CNT_MAX/4 -1'b1;
wire  w_time_3_4ui  = r_scl_cnt == SCL_CNT_MAX/4 +SCL_CNT_MAX/2 - 1'b1;
wire  w_time_1ui    = r_scl_cnt == SCL_CNT_MAX - 1'b1;
//generate scl_clk

assign      w_scl_cnt = (curr_st   == ST_IDLE)             ?   16'd0:
                        (curr_st   != next_st)             ?   16'd0:
                        (w_time_1ui)?   16'd0:
                        r_scl_cnt + 1'b1;

assign      w_scl_bit = (w_st_wr_start  || w_st_idle)       ? 1'b1:
                        //(w_scl_cnt == (SCL_CNT_MAX)/2 - 1'b1)         ?(~r_scl_bit);
                        (r_scl_cnt ==  0)                   ? 1'b0:
                        (r_scl_cnt == SCL_CNT_MAX/2 - 1'b1) ? 1'b1:r_scl_bit;

wire        w_scl_bit_en  = (curr_st != ST_IDLE);

assign      w_scl_num_cnt = (~w_st_idle)&&(w_time_1ui)?
                            (r_scl_num_cnt == 4'd8) || (curr_st != next_st)                        ?4'd0:
                            (r_scl_num_cnt + 1'b1)                         :r_scl_num_cnt;

wire        w_byte_done   = (r_scl_num_cnt == 4'd8)&&(w_time_1ui);
wire        r_byte_done   ;

assign      w_byte_num    = (curr_st != next_st)            ? 6'd0:
                            w_byte_done                     ? r_byte_num + 1'b1 : r_byte_num;
wire        r_wr_flag;
wire        r_rd_flag;

//ctrl data gen
wire        w_wr_flag = (o_iic_error || o_curr_work_done)?  1'b0:
                        (i_iic_wr_req                   )?  1'b1:r_wr_flag;

wire        w_rd_flag = (o_iic_error || o_curr_work_done)?  1'b0:
                        (i_iic_rd_req                   )?  1'b1:r_rd_flag;

assign      w_i_sda                 = sda;

wire        w_st_idle_2_wr_start    = w_st_idle     && (r_wr_flag || r_rd_flag);
wire        w_st_wr_start_2_wr_ctrl = w_st_wr_start && (w_time_1ui);
wire        w_st_wr_ctrl_2_wr_addr  = w_st_wr_ctrl  && w_byte_done;
wire        w_st_wr_addr_2_wr_data  = w_st_wr_addr  && (w_byte_done)  && (r_byte_num == ADDR_NUM) && (r_wr_flag);
wire        w_st_wr_data_2_wr_stop  = w_st_wr_data  && (w_byte_done)  && (r_byte_num == i_iic_wr_byte_num) ;
wire        w_st_2_error            = (w_st_wr_start || w_st_wr_ctrl || w_st_wr_addr || w_st_wr_data) && (r_scl_num_cnt == 4'd8 ) && (w_time_3_4ui)  && (w_i_sda == 1'b1);

wire        w_st_wr_addr_2_rd_start = (w_st_wr_addr)&& (w_byte_done)  && (r_byte_num == ADDR_NUM) && (r_rd_flag);
wire        w_st_rd_start_2_rd_ctrl = w_st_rd_start && (w_time_1ui);
wire        w_st_rd_ctrl_2_rdata    = w_st_rd_ctrl  && w_byte_done;
wire        w_st_rd_data_2_rd_stop  = w_st_rd_data  && (r_byte_num == i_iic_rd_byte_num) && w_byte_done;
wire        w_st_2_idle             = (w_st_error || w_st_rd_stop || w_st_wr_stop) && (w_time_1ui);



always@(posedge clk or negedge rst_n)begin
  if(~rst_n)
    curr_st <= ST_IDLE;
  else
    curr_st <= next_st;
end

assign     next_st = 
                      w_st_2_error            ?  ST_ERROR       :
                      w_st_2_idle             ?  ST_IDLE        :
                      w_st_idle_2_wr_start    ?  ST_WR_START    :
                      w_st_wr_start_2_wr_ctrl ?  ST_WR_CTRL     :
                      w_st_wr_ctrl_2_wr_addr  ?  ST_WR_ADDR     :
                      w_st_wr_addr_2_wr_data  ?  ST_WR_DATA     :
                      w_st_wr_addr_2_rd_start ?  ST_RD_START    :
                      w_st_wr_data_2_wr_stop  ?  ST_WR_STOP     :
                      w_st_rd_start_2_rd_ctrl ?  ST_RD_CTRL     :
                      w_st_rd_ctrl_2_rdata    ?  ST_RD_DATA     :
                      w_st_rd_data_2_rd_stop  ?  ST_RD_STOP     : curr_st ;
//sda ctrl
wire  [7:0] r_send_byte  ;
reg  [7:0] w_send_byte  ;

wire  w_data_update_vld   = w_time_1_4ui ;
always@(*)begin
  if(w_st_wr_ctrl)
    if(r_scl_num_cnt == 4'd0)
      w_send_byte = {DEVICE_ADDR,1'b0};
    else if(w_data_update_vld)
      w_send_byte = {r_send_byte[6:0],1'b0};
    else
      w_send_byte = r_send_byte;
  else if(w_st_rd_ctrl)
    if(r_scl_num_cnt == 4'd0)
      w_send_byte = {DEVICE_ADDR,1'b1};
    else if(w_data_update_vld)
      w_send_byte = {r_send_byte[6:0],1'b0};
    else
      w_send_byte = r_send_byte;
  else if(w_st_wr_addr && r_byte_num <= ADDR_NUM)begin
    if(r_scl_num_cnt == 4'd0 && r_byte_num == 6'd0)
      w_send_byte =  i_iic_addr[15:8];
    else if(r_scl_num_cnt == 4'd0 && r_byte_num == 6'd1)
      w_send_byte =  i_iic_addr[7:0];
    else if(w_data_update_vld)
      w_send_byte =  {r_send_byte[6:0],1'b0};
    else 
      w_send_byte = r_send_byte;
  end
    
 else if(w_st_wr_data && (r_byte_num <= i_iic_wr_byte_num))
    if(r_scl_num_cnt == 4'd0)
      w_send_byte =  i_iic_wr_data;
    else if(w_data_update_vld)
      w_send_byte =  {r_send_byte[6:0],1'b0};
    else
      w_send_byte = r_send_byte;

  else
      w_send_byte = 8'd0;
    
end

assign  w_o_sda = (w_st_wr_start ) && (r_scl_cnt == SCL_CNT_MAX/2 -1'b1) ? 1'b0 :  //generate start signal
            //      (w_st_wr_addr  ) && (r_byte_num == ADDR_NUM) && (r_scl_num_cnt == 4'd8) && (r_scl_cnt ==SCL_CNT_MAX/2 + 4'd10)? 1'b1:
                  (w_st_rd_start ) && (w_time_3_4ui) ? 1'b0 :
                  (w_st_rd_start ) && (w_time_1_4ui) ? 1'b1 :
                  (w_st_wr_ctrl || w_st_wr_addr || w_st_wr_data || w_st_rd_ctrl) && w_data_update_vld  ? (w_send_byte[7]):
                  (w_st_wr_stop || w_st_rd_stop) && (w_time_1_4ui)? 1'b0 :
                  (w_st_wr_stop || w_st_rd_stop) && (w_time_3_4ui)? 1'b1 :  //generate stop signal
                  (w_st_rd_data && r_byte_num < i_iic_rd_byte_num) && (r_scl_num_cnt == 4'd8            )? 1'b0 : 
                  (w_st_rd_data && r_byte_num == i_iic_rd_byte_num)&& (r_scl_num_cnt == 4'd8)            ? 1'b1 :
                  r_o_sda;//generate master ack signal;

always@(*)begin
  if(w_st_wr_start || w_st_wr_stop )
    w_sda_en = 1'b1;
  else if(w_st_rd_start && w_time_1_4ui)
    w_sda_en = 1'b1;
  else if(w_st_wr_ctrl || w_st_wr_addr || w_st_wr_data || w_st_rd_ctrl)begin
    if(r_scl_num_cnt == 4'd0 && w_time_1_4ui)
      w_sda_en = 1'b1;
    else if(r_scl_num_cnt == 4'd8 && w_time_1_4ui)
      w_sda_en = 1'b0;
    else
      w_sda_en = r_sda_en;
  end
  else if(w_st_rd_start) begin
    if(w_time_1_4ui)
      w_sda_en = 1'b1;
    else
      w_sda_en = r_sda_en;
    end
  else if(w_st_rd_data && r_scl_num_cnt == 4'd8 && w_time_1_4ui) 
      w_sda_en = 1'b1;
  else if(w_st_rd_data && r_scl_num_cnt == 4'd0 && w_time_1_4ui)
    w_sda_en = 1'b0;
  else 
    w_sda_en = r_sda_en;
    
end

assign  w_iic_error     = (w_st_error) ;
assign  w_iic_work_done = (w_st_wr_stop || w_st_rd_stop);
wire    w_req_new_byte  = w_data_update_vld && (r_scl_num_cnt == 4'd1);

dff_default_low     #(1)  inst_dff_work_done(1'b1        ,w_iic_work_done,o_curr_work_done,clk,rst_n);
dff_default_low     #(1)  inst_dff_iic_err  (1'b1        ,w_iic_error   ,o_iic_error  ,clk,rst_n);
dff_default_low     #(6)  inst_dff_byte_num (w_scl_bit_en,w_byte_num    ,r_byte_num   ,clk,rst_n);
dff_default_low     #(4)  inst_dff_scl_num  (w_scl_bit_en,w_scl_num_cnt ,r_scl_num_cnt,clk,rst_n);
dff_default_low     #(16) inst_dff_scl_cnt  (w_scl_bit_en,w_scl_cnt     ,r_scl_cnt    ,clk,rst_n);
dff_default_high    #(1)  inst_dff_scl_bit  (w_scl_bit_en,w_scl_bit     ,r_scl_bit    ,clk,rst_n);
dff_default_low     #(1)  inst_dff_wr_flag  (1'b1        ,w_wr_flag     ,r_wr_flag    ,clk,rst_n);
dff_default_low     #(1)  inst_dff_rd_flag  (1'b1        ,w_rd_flag     ,r_rd_flag    ,clk,rst_n);
dff_default_high    #(1)  inst_dff_sda      (1'b1        ,w_o_sda       ,r_o_sda      ,clk,rst_n);
dff_default_low     #(1)  isnt_dff_sda_en   (1'b1        ,w_sda_en      ,r_sda_en     ,clk,rst_n);
dff_default_low     #(1)  inst_dff_byte_done(1'b1        ,w_byte_done   ,r_byte_done  ,clk,rst_n);
dff_default_low     #(8)  inst_dff_send_byte(1'b1        ,w_send_byte   ,r_send_byte  ,clk,rst_n);
dff_default_low     #(1)  inst_dff_low1     (1'b1        ,w_req_new_byte,o_req_new_byte,clk,rst_n);              
assign o_scl  = r_scl_bit; 
assign sda    = r_sda_en  ? (r_o_sda) : 1'bz;


wire  [7:0] w_iic_rd_byte = (w_st_rd_data && r_scl_num_cnt <= 4'd7 && r_scl_cnt == SCL_CNT_MAX - SCL_CNT_MAX/4 -1'b1)?{o_iic_rd_byte[6:0],w_i_sda }   : o_iic_rd_byte;

wire        w_iic_rd_byte_vld = (w_st_rd_data && r_scl_num_cnt == 4'd8 );

dff_default_low #(1) inst_dff_byte_vld      (1'b1        ,w_iic_rd_byte_vld,o_iic_rd_byte_vld,clk,rst_n );

dff_default_low #(8) inst_dff_byte      (1'b1        ,w_iic_rd_byte,o_iic_rd_byte,clk,rst_n );

endmodule
