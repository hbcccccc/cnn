module  dff_default_high
#(parameter DATA_WITDT  = 32)
(
input                       iden,
input   [DATA_WITDT-1:0]    i_data,
output  [DATA_WITDT-1:0]    o_data,
input                       clk,
input                       rst_n
);

reg [DATA_WITDT-1:0] r_data_out;

always@(posedge clk or negedge rst_n)begin
  if(~rst_n)
    r_data_out  <=  {DATA_WITDT{1'b1}};
  else if(iden)
    r_data_out  <=  i_data;
end

assign  o_data  = r_data_out;



endmodule
