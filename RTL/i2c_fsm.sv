`include "define.sv"
module i2c_fsm(
  input wire scl_posedge,
  input wire scl_negedge,
  input wire resetN,
  input wire en,
  input wire rw,
  input wire SDA_in,
  input wire [3:0] N_byte,
//  input wire star_done,
//  input wire stop_done,
  
 // output reg star_en,
  //output reg stop_en,
  output reg [3:0] count,
  output reg i2c_write_en,
  output reg [7:0] state,
  output reg i2c_scl_en
  );
reg [7:0] c_state, n_state;
reg [3:0] count_data;
//reg star_en, star_done;
//reg stop_en, stop_done;
assign state = c_state;
always_comb
begin
  case(c_state)
    IDLE: begin
      if(en) n_state = START;
      else n_state = c_state;
    end
    START: begin
      //if(star_done)
        n_state = ADDRESS;
      //else n_state = c_state;
    end
    ADDRESS: begin
      if(count == 0) n_state = READ_ACK;
      else 
        begin 
          n_state = c_state;
        end
    end
    READ_ACK: begin
      if(SDA_in == 0)
      begin
        if(rw == 0) n_state = WRITE_DATA;
        else n_state = READ_DATA;
      end 
      else n_state = STOP; 
    end
    // write operation
    WRITE_DATA: begin
      if(count == 0) n_state = READ_ACK2;
      else
        begin 
          n_state = c_state;
        end
    end
    READ_ACK2: begin
     if(SDA_in == 1) n_state = STOP;
      else 
      begin
        if(count_data == N_byte) n_state = STOP;
        else
          begin
            n_state = WRITE_DATA;
          end
      end
    end
    // read operation
    READ_DATA: begin
      if(count == 0) n_state = WRITE_ACK2;
      else n_state <= c_state;
    end
    WRITE_ACK2: begin
      if(count_data == N_byte) n_state = STOP;
      else
        begin
          n_state = READ_DATA;
        end
    end
    STOP: begin
      //if(stop_done)
        n_state = IDLE;
      //else n_state = c_state;
    end  
  endcase
end

always_ff@(posedge scl_negedge, negedge resetN)
begin
  if(~resetN)
    begin
      c_state <= IDLE;
    end
  else
    c_state <=  n_state;
end

always_comb
begin
    case(c_state)
      IDLE: begin
        i2c_write_en = 1;
        i2c_scl_en = 0;
      end
      START: begin
        i2c_write_en = 1;
        i2c_scl_en = 0;
      end 
      ADDRESS: begin
        i2c_write_en = 1;
        i2c_scl_en = 1;
      end
      READ_ACK: begin
        i2c_write_en = 0;
        i2c_scl_en = 1;
      end
      WRITE_DATA: begin
        i2c_write_en = 1;
        i2c_scl_en = 1;;
      end
      READ_ACK2: begin
        i2c_write_en = 0;
        i2c_scl_en = 1;
      end
      READ_DATA: begin
        i2c_write_en = 0;
        i2c_scl_en = 1;
      end
      WRITE_ACK2: begin
        i2c_write_en = 1;
        i2c_scl_en = 1;
      end
      STOP: begin
        i2c_write_en = 1;
        i2c_scl_en =0;
      end
    endcase 
end

always_ff@(posedge scl_negedge, negedge resetN) begin
  if(~resetN) count_data <= 4'b0;
    else begin
      if(c_state == IDLE) count_data <= 4'b0;
      if(c_state == READ_ACK2 || c_state == WRITE_ACK2)
         count_data <= count_data + 1'b1;
    end
end

always_ff@(posedge scl_negedge, negedge resetN) begin
  if(~resetN) count <= 4'd0;
  else
    begin
      if(c_state == START || c_state == READ_ACK2 || c_state == WRITE_ACK2 || c_state == READ_ACK)
        begin
          count <= 7;
        end
      if(c_state == ADDRESS || c_state == WRITE_DATA ||c_state == READ_DATA) begin
        if(count !=0) count <= count - 1;
      end
    end
end
endmodule 