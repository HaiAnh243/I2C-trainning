module i2c_fsm(
  input wire clk,
  input wire reset,
  input wire en,
  input wire [6:0] addr,
  input wire [7:0] data_in,
  input wire rw,
  
  output reg [7:0] data_out,
  inout  reg SDA, 
  output reg SCL
  );
localparam IDLE = 0;
localparam START = 1;
localparam ADDRESS = 2;
localparam READ_ACK = 3;
localparam WRITE_DATA = 4;
localparam READ_DATA = 5;
localparam READ_ACK2 = 6;
localparam WRITE_ACK2 = 7;
localparam STOP = 8;
 
reg [7:0] state;
reg [7:0] saved_addr;
reg [7:0] count;
reg [7:0] saved_data;
reg i2c_write_en;
always_ff@(posedge clk) 
begin
  if(reset == 1)
    begin
      state <=0;
      SDA <= 1;
      saved_addr <= 8'b0;
      saved_data <= 8'haa;
    end
  else
    begin
      case(state)
        IDLE: begin
          if(en)
            begin
              state <= START;
              saved_addr = {addr,rw};
              saved_data = data_in;
            end
          else state <= IDLE;
        end
        START: begin
          SDA <= 1;
          state <= ADDRESS;
          count <= 7;
        end
        ADDRESS: begin
          SDA = saved_addr[count];
          if(count == 0) state <= READ_ACK;
          else count <= count -1;
        end  
        READ_ACK: begin
          if(SDA == 0)
            begin
              count <= 7;
              if(addr[0] == 0) state <= WRITE_DATA;
              else state <= READ_DATA;
            end  
        end
        WRITE_DATA: begin
           SDA <= saved_data[count];
           if(count == 0) state <= READ_ACK2;
           else count <= count -1;
        end
        READ_ACK2: begin
          if((SDA == 0)& (en == 1)) state <= START;
          else state <= STOP;
        end 
        READ_DATA: begin
          data_out[count] <= SDA;
          if(count == 0) state <= WRITE_ACK2;
          else count <=  count -1;
        end
        WRITE_ACK2: begin
          SDA <= 0;
          state <= STOP;
        end
        STOP: begin
          SDA <= 1;
          state <= IDLE; 
        end
      endcase  
    end
end
endmodule