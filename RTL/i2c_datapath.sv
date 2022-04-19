`include "define.sv"
module i2c_datapath(
  input wire scl_negedge,
  input wire resetN,
  input wire [6:0] address,
  input wire [7:0] data_in,
  input wire i2c_scl_en,
  input wire i2c_write_en,
  input wire [7:0] state,
  input wire [3:0] count,
  input wire rw,
  input wire SDA_in,
  //input wire star_en,
  //input wire stop_en,
  
  //output reg valid,
  //output reg star_done,
  //output reg stop_done,
  output reg [7:0] data_out,
  output reg SDA_out
  );
  reg [7:0] saved_data;
  reg [7:0] saved_addr;
  
  always @(negedge scl_negedge, negedge resetN)
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
          //if(star_en) 
            //begin
              SDA_out <= 1'b0;
            //  saved_data <= data_in;
              saved_addr <= {address,rw};
              //star_done <= 1;
            //end
        end
        ADDRESS: begin
          if(i2c_scl_en == 1)
          SDA_out <= saved_addr[count];
        end
        READ_ACK2:begin   
        end
        WRITE_DATA:begin
          SDA_out <= data_in[count];
        end
        READ_DATA: begin
          data_out[count] <= SDA_in;
        end
        WRITE_ACK2: begin
          SDA_out <= 1'b0;
        end
        STOP: begin
          //if(stop_en)
            //begin
              SDA_out <= 1'b1;
              //stop_done <= 1;
            //end
        end
      endcase
  end
endmodule
  
  
