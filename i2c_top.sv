`include "define.sv"
module i2c_top(
  input wire clk,
  input wire en,
  input wire resetN,
  input wire [6:0] address,
  input wire rw,
  input wire [7:0] data_in,
  
  output reg [7:0] data_out,
  output reg i2c_scl,
  
  inout i2c_sda
  );
 reg i2c_scl_in;
 reg sda_out;
 reg [7:0] state;
 reg [3:0] count;
 reg i2c_write_en;
 reg i2c_scl_en;
 
 gen_clk DUT1(
 .clk_in(clk),
 .clk_out(i2c_scl_in)
  );
 i2c_fsm DUT2(
 .i2c_scl_in(i2c_scl_in),
 .resetN(resetN),
 .en(en),
 .rw(rw),
 .SDA_in(i2c_sda),
 .count(count),
 .i2c_write_en(i2c_write_en),
 .state(state),
 .i2c_scl_en(i2c_scl_en)
 );
 i2c_datapath DUT3(
 .i2c_scl_in(i2c_scl_in),
 .resetN(resetN),
 .address(address),
 .data_in(data_in),
 .i2c_scl_en(i2c_scl_in),
 .i2c_write_en(i2c_scl_en),
 .state(state),
 .count(count),
 .rw(rw),
 .SDA_in(i2c_sda),
 
 .data_out(data_out),
 .SDA_out(sda_out),
 .SCL(i2c_scl)
 );
 assign i2c_sda = (i2c_write_en == 1)? sda_out:'bz;
 endmodule