`include "define.sv"
module i2c_datapath(
  input wire i2c_scl_in,
  input wire resetN,
  input wire [6:0] address,
  input wire [7:0] data_in,
  input wire i2c_scl_en,
  input wire i2c_write_en,
  input wire [7:0] state,
  input wire [3:0] count,
  input wire rw,
  input wire SDA_in,
  
  output reg done,
  output reg [7:0] data_out,
  output reg SDA_out
  );
  reg [7:0] saved_data;
  reg [7:0] saved_addr;
  
  always @(negedge i2c_scl_in, negedge resetN)
  begin
    if(~resetN)
      begin
        SDA_out <= 1'b1;
        saved_data <= 8'b0;
        saved_addr <= 8'b0;
      end
    else
      case(state)
        IDLE: begin
          SDA_out <= 1'b1;
        end
        START: begin
          SDA_out <= 1'b0;
          saved_addr <= {address,rw};
        end
        ADDRESS: begin
          SDA_out <= saved_addr[count];
        end
        READ_ACK: begin
          if(rw == 0) saved_data = data_in;
        end
        WRITE_DATA:begin
          SDA_out <= data_in[count];
        end
        READ_DATA: begin
//          saved_addr <= {address,rw};
          data_out[count] <= SDA_in;
        end
        WRITE_ACK2: begin
          if(count == 0)  SDA_out <= 1'b1;
          else SDA_out <= 1'b0;
        end
        STOP: begin
          SDA_out <= 1'b1;
        end
      endcase
  end 
always_ff@(negedge i2c_scl_in)
begin
  if(count == 0) done <=1;
  else done<=0;
end  
endmodule
  
  
