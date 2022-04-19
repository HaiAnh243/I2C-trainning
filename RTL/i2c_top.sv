`include "define.sv"
module i2c_top(
  input wire clk,
  input wire en,
  input wire resetN,
  input wire [6:0] address,
  input wire rw,
  input wire [7:0] data_in,
  input wire [3:0] N_byte,
  
  output reg ready,
  output reg read_done,
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

 //.valid(valid),
 .data_out(data_out),
 .SDA_out(sda_out)
 );
 assign i2c_sda = (i2c_write_en == 1)? sda_out:'bz;
//assign i2c_sda = (sda_out == 0)? sda_out:'bz;
 assign i2c_scl = (i2c_scl_en == 1'b0)? 1'b1:i2c_scl_in;
 assign read_done = (count == 0 && (state == WRITE_ACK2) && scl_negedge ) ? 1'b1:1'b0;
 assign write_done = (count == 0 && (state == READ_ACK||state == READ_ACK2) && scl_negedge ) ? 1'b1:1'b0;
 assign ready = ((resetN == 1'b1) && (state == IDLE))? 1'b1: 1'b0;
 /*
 always_ff@(posedge clk)
 begin
   if(valid == 1) valid <= 0;
 end
 */
 endmodule