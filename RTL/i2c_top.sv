`include "define.sv"
module i2c_top(
  input wire clk,
  input wire en,
  input wire resetN,
  input wire [6:0] address,
  input wire rw,
  input wire [7:0] data_in,
  input wire [3:0] N_byte,
  
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
 reg scl_posedge;
 reg scl_negedge;
 reg star_en, star_done;
 reg stop_en, stop_done;
 gen_clk DUT1(
 .clk_in(clk),
 .resetN(resetN),

 .clk_out(i2c_scl_in),
 .scl_posedge(scl_posedge),
 .scl_negedge(scl_negedge)
  );
 i2c_fsm DUT2(
 .scl_posedge(scl_posedge),
 .scl_negedge(scl_negedge),
 .resetN(resetN),
 .en(en),
 .rw(rw),
 .SDA_in(i2c_sda),
 .N_byte(N_byte),
 //.star_done(star_done),
 //.stop_done(stop_done),

 //.stop_en(stop_en/
 //.star_en(star_en),
 .count(count),
 .i2c_write_en(i2c_write_en),
 .state(state),
 .i2c_scl_en(i2c_scl_en)
 );
 i2c_datapath DUT3(
 .scl_negedge(scl_negedge),
 .resetN(resetN),
 .address(address),
 .data_in(data_in),
 .i2c_scl_en(i2c_scl_en),
 .i2c_write_en(i2c_scl_en),
 .state(state),
 .count(count),
 .rw(rw),
 .SDA_in(i2c_sda),
 //.star_en(star_en),
 //.stop_en(stop_en),

 //.stop_done(stop_done),
 //.star_done(star_done),
 .data_out(data_out),
 .SDA_out(sda_out)
 );
 assign i2c_sda = (i2c_write_en == 1)? sda_out:'bz;
 assign i2c_scl = (i2c_scl_en == 1'b0)? 1'b1:i2c_scl_in;
 endmodule