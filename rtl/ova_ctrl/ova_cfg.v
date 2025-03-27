module ova_cfg_hardware(
    input   wire            clk                 ,
    input   wire            rst_n               ,
    output  wire             o_iic_wr_req       ,
    output  wire             o_iic_rd_req       ,
    output  wire     [05:0]  o_iic_wr_byte_num  ,
    output  wire     [05:0]  o_iic_rd_byte_num  , 
    output  wire     [15:0]  o_iic_addr         ,
    output  wire     [07:0]  o_iic_wr_data      ,
    input   wire    [07:0]  i_iic_rd_data       ,
    input   wire            i_iic_work_done     ,
    input   wire            i_iic_req_new_byte 
);

reg    [7:0]   w_wr_data;
reg    [7:0]   w_wr_addr;

wire   [6:0]   r_cnt      ;
wire   [6:0]   w_cnt      ;
wire           w_cnt_clr  ;
wire           w_cnt_en   ;
wire           r_iic_work_done_1d;
wire           w_iic_work_done_pdge = (i_iic_work_done) && (~r_iic_work_done_1d);

assign  w_cnt = w_cnt_clr ? 7'd0 : 
                w_cnt_en  ? r_cnt + 1'b1 : r_cnt ; 

assign w_cnt_clr = 1'b0             ;
assign w_cnt_en  = w_iic_work_done_pdge  ;

wire   w_wr_req;
assign w_wr_req = i_iic_req_new_byte ? 1'b0 :
                  i_iic_work_done && (w_cnt <= 7'd68)   ? 1'b1 : o_iic_wr_req ;

//register declare               load_en  idata                 odata                     clk     rst_n
dff_default_low #(7) inst_dff_low1(1'b1,  w_cnt             ,   r_cnt                 ,   clk,    rst_n);
dff_default_low #(8) inst_dff_low2(1'b1,  w_wr_data         ,   o_iic_wr_data         ,   clk,    rst_n);
dff_default_low #(8) inst_dff_low3(1'b1,  w_wr_addr         ,   o_iic_addr[15:8]       ,   clk,    rst_n);
dff_default_low #(6) inst_dff_low4(1'b1,  6'd0              ,   o_iic_wr_byte_num     ,   clk,    rst_n);
dff_default_low #(6) inst_dff_low5(1'b1,  6'd0              ,   o_iic_rd_byte_num     ,   clk,    rst_n);
dff_default_high#(1) inst_dff_hig1(1'b1,  w_wr_req          ,   o_iic_wr_req          ,   clk,    rst_n);
dff_default_high#(1) inst_dff_hig2(1'b1,  1'b0              ,   o_iic_rd_req          ,   clk,    rst_n);
dff_default_low #(1) inst_dff_low6(1'b1,  i_iic_work_done   ,   r_iic_work_done_1d    ,   clk,    rst_n);

assign o_iic_addr[7:0] = 8'd0;

//cfg truth table
always@(*)begin
    case(r_cnt)
        7'd0  :  {w_wr_addr,w_wr_data} = {8'h3d, 8'h03};
        7'd1  :  {w_wr_addr,w_wr_data} = {8'h15, 8'h00};     
        7'd2  :  {w_wr_addr,w_wr_data} = {8'h17, 8'h23};
        7'd3  :  {w_wr_addr,w_wr_data} = {8'h18, 8'ha0};
        7'd4  :  {w_wr_addr,w_wr_data} = {8'h19, 8'h07};
        7'd5  :  {w_wr_addr,w_wr_data} = {8'h1a, 8'hf0};
        7'd6  :  {w_wr_addr,w_wr_data} = {8'h32, 8'h00};
        7'd7  :  {w_wr_addr,w_wr_data} = {8'h29, 8'ha0};
        7'd8  :  {w_wr_addr,w_wr_data} = {8'h2a, 8'h00};
        7'd9  :  {w_wr_addr,w_wr_data} = {8'h2b, 8'h00};
        7'd10 :  {w_wr_addr,w_wr_data} = {8'h2c, 8'hf0};
        7'd11 :  {w_wr_addr,w_wr_data} = {8'h0d, 8'h41};
        7'd12 :  {w_wr_addr,w_wr_data} = {8'h11, 8'h00};
        7'd13 :  {w_wr_addr,w_wr_data} = {8'h12, 8'h06};
        7'd14 :  {w_wr_addr,w_wr_data} = {8'h0c, 8'hd0};
        7'd15 :  {w_wr_addr,w_wr_data} = {8'h42, 8'h7f};
        7'd16 :  {w_wr_addr,w_wr_data} = {8'h4d, 8'h09};
        7'd17 :  {w_wr_addr,w_wr_data} = {8'h63, 8'hf0};
        7'd18 :  {w_wr_addr,w_wr_data} = {8'h64, 8'hff};
        7'd19 :  {w_wr_addr,w_wr_data} = {8'h65, 8'h00};
        7'd20 :  {w_wr_addr,w_wr_data} = {8'h66, 8'h00};
        7'd21 :  {w_wr_addr,w_wr_data} = {8'h67, 8'h00};
        7'd22 :  {w_wr_addr,w_wr_data} = {8'h13, 8'hff};
        7'd23 :  {w_wr_addr,w_wr_data} = {8'h0f, 8'hc5};
        7'd24 :  {w_wr_addr,w_wr_data} = {8'h14, 8'h11};
        7'd25 :  {w_wr_addr,w_wr_data} = {8'h22, 8'h98};
        7'd26 :  {w_wr_addr,w_wr_data} = {8'h23, 8'h03};
        7'd27 :  {w_wr_addr,w_wr_data} = {8'h24, 8'h40};
        7'd28 :  {w_wr_addr,w_wr_data} = {8'h25, 8'h30};
        7'd29 :  {w_wr_addr,w_wr_data} = {8'h26, 8'ha1};
        7'd30 :  {w_wr_addr,w_wr_data} = {8'h6b, 8'haa};
        7'd31 :  {w_wr_addr,w_wr_data} = {8'h13, 8'hff};
        7'd32 :  {w_wr_addr,w_wr_data} = {8'h90, 8'h0a};
        7'd33 :  {w_wr_addr,w_wr_data} = {8'h91, 8'h01};
        7'd34 :  {w_wr_addr,w_wr_data} = {8'h92, 8'h01};
        7'd35 :  {w_wr_addr,w_wr_data} = {8'h93, 8'h01};
        7'd36 :  {w_wr_addr,w_wr_data} = {8'h94, 8'h5f};
        7'd37 :  {w_wr_addr,w_wr_data} = {8'h95, 8'h53};
        7'd38 :  {w_wr_addr,w_wr_data} = {8'h96, 8'h11};
        7'd39 :  {w_wr_addr,w_wr_data} = {8'h97, 8'h1a};
        7'd40 :  {w_wr_addr,w_wr_data} = {8'h98, 8'h3d};
        7'd41 :  {w_wr_addr,w_wr_data} = {8'h99, 8'h5a};
        7'd42 :  {w_wr_addr,w_wr_data} = {8'h9a, 8'h1e};
        7'd43 :  {w_wr_addr,w_wr_data} = {8'h9b, 8'h3f};
        7'd44 :  {w_wr_addr,w_wr_data} = {8'h9c, 8'h25};
        7'd45 :  {w_wr_addr,w_wr_data} = {8'h9e, 8'h81};
        7'd46 :  {w_wr_addr,w_wr_data} = {8'ha6, 8'h06};
        7'd47 :  {w_wr_addr,w_wr_data} = {8'ha7, 8'h65};
        7'd48 :  {w_wr_addr,w_wr_data} = {8'ha8, 8'h65};
        7'd49 :  {w_wr_addr,w_wr_data} = {8'ha9, 8'h80};
        7'd50 :  {w_wr_addr,w_wr_data} = {8'haa, 8'h80};
        7'd51 :  {w_wr_addr,w_wr_data} = {8'h7e, 8'h0c};
        7'd52 :  {w_wr_addr,w_wr_data} = {8'h7f, 8'h16};
        7'd53 :  {w_wr_addr,w_wr_data} = {8'h80, 8'h2a};
        7'd54 :  {w_wr_addr,w_wr_data} = {8'h81, 8'h4e};
        7'd55 :  {w_wr_addr,w_wr_data} = {8'h82, 8'h61};
        7'd56 :  {w_wr_addr,w_wr_data} = {8'h83, 8'h6f};
        7'd57 :  {w_wr_addr,w_wr_data} = {8'h84, 8'h7b};
        7'd58 :  {w_wr_addr,w_wr_data} = {8'h85, 8'h86};
        7'd59 :  {w_wr_addr,w_wr_data} = {8'h86, 8'h8e};
        7'd60 :  {w_wr_addr,w_wr_data} = {8'h87, 8'h97};
        7'd61 :  {w_wr_addr,w_wr_data} = {8'h88, 8'ha4};
        7'd62 :  {w_wr_addr,w_wr_data} = {8'h89, 8'haf};
        7'd63 :  {w_wr_addr,w_wr_data} = {8'h8a, 8'hc5};
        7'd64 :  {w_wr_addr,w_wr_data} = {8'h8b, 8'hd7};
        7'd65 :  {w_wr_addr,w_wr_data} = {8'h8c, 8'he8};
        7'd66 :  {w_wr_addr,w_wr_data} = {8'h8d, 8'h20};
        7'd67 :  {w_wr_addr,w_wr_data} = {8'h0e, 8'h65};
        7'd68 :  {w_wr_addr,w_wr_data} = {8'h09, 8'h00};
        default : {w_wr_addr,w_wr_data} = {8'h3d, 8'h03};
    endcase

end


endmodule