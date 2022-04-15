`include "define.sv"
module i2c_fsm(
  input wire i2c_scl_in,
  input wire resetN,
  input wire en,
  input wire rw,
  input wire SDA_in,
  input wire [3:0] N_byte,
  
  output reg [3:0] count,
  output reg i2c_write_en,
  output reg [7:0] state,
  output reg i2c_scl_en
  );
reg [7:0] c_state, n_state;
reg [3:0] count_data = 4'b0;
reg ld;
assign state = c_state;

always_comb
begin
  case(c_state)
    IDLE: begin
      if(en) n_state = START;
      else n_state = IDLE;
    end
    START: begin
        n_state = ADDRESS;
//        count = 7;
    end
    ADDRESS: begin
      if(count == 0) n_state = READ_ACK;
      else 
        begin 
//          count = count-1;
          n_state = ADDRESS;
        end
    end
    READ_ACK: begin
//      count = 7;
      if(SDA_in == 0)
      begin
        if(rw == 0) n_state = WRITE_DATA;
        else n_state = READ_DATA;
      end 
      else n_state = STOP; 
    end
    // write operation
    WRITE_DATA: begin
      if(count == 0) 
      begin
        n_state = READ_ACK2;
      end
      else
        begin 
//          count = count-1;
          n_state = WRITE_DATA;
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
      else n_state <= READ_DATA;
    end
    WRITE_ACK2: begin
      n_state = STOP;
    end
    STOP: begin
//      if(SDA_in) n_state = IDLE;
//      else n_state = c_state;
      n_state = IDLE;
    end  
  endcase
end

always_ff@(posedge i2c_scl_in, negedge resetN)
begin
  if(~resetN)
    begin
      c_state <= IDLE;
    end
  else
    c_state <=  n_state;
end

always_ff@(negedge i2c_scl_in, negedge resetN) begin
  if(~resetN) i2c_write_en <=1;
  else
    begin   
      if((c_state == IDLE) ||(c_state == START)||(c_state == ADDRESS)||(c_state == WRITE_DATA)||(c_state == WRITE_ACK2)||(c_state == STOP))
      i2c_write_en <= 1;
      else i2c_write_en <= 0;
    end  
end
 
always_ff@(negedge i2c_scl_in) begin
  if(~resetN) i2c_scl_en <=0;
  else begin 
    if((c_state == IDLE) || (c_state == START)|| (c_state == STOP))
      i2c_scl_en <= 0;
    else i2c_scl_en <=1;
  end
end

always_ff@(posedge i2c_scl_in, negedge resetN) begin
  if(~resetN) count <= 4'd0;
    else begin
        if(c_state == START|| c_state == READ_ACK2 || c_state == WRITE_ACK2||c_state==READ_ACK)     
          begin
           count <= 7;
          end 
          if(c_state == ADDRESS ||c_state == WRITE_DATA||c_state == READ_DATA)
            count <= count - 1;
    end
end
always_ff@(posedge i2c_scl_in)
begin
  if(ld) count <= 4'b0111;
  else count <= count - 1'b1;
end

always_ff@(negedge i2c_scl_in, negedge resetN) begin
  if(~resetN) count_data <= 4'b0;
    else begin
      if(c_state == WRITE_DATA)
        begin
          if(count == 0) count_data <= count_data + 1;
        end
    end
end

endmodule 