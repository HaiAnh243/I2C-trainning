module testbench;
 reg clk; 
 reg en;
 reg resetN;
 reg [6:0] address;
 reg rw;
 reg [7:0] data_in;
 reg [3:0] N_byte;
  
 wire [7:0] data_out;
 wire i2c_sda;
 wire i2c_scl;

i2c_top master(
 .clk(clk),
 .en(en),
 .resetN(resetN),
 .address(address),
 .rw(rw),
 .data_in(data_in),
 .N_byte(N_byte),

 .data_out(data_out),
 .i2c_sda(i2c_sda),
 .i2c_scl(i2c_scl)
);
i2c_slave_model slave(
 .sda(i2c_sda),
 .scl(i2c_scl)
);

pullup p1(i2c_sda);
pullup p2(i2c_scl);

initial begin
 clk = 0;
 forever begin
    clk = #250 ~clk;
   end
end
initial begin
	clk = 0;
	resetN = 0;
	#100;
// ghi
	resetN = 1;		
	address = 7'b0010000;
	data_in = 8'b00000000;
	rw = 0;	
	en = 1;
  N_byte = 4'd3;
//        #1300;
//        en = 0;
// chuan bi doc
  #39250;
  data_in = 8'b10101010;
  #95300;
  resetN = 0;
  #100000;
  resetN = 1;
  address = 7'b0010000;
  data_in = 8'b00000000;
  rw = 0;
  N_byte = 4'd0;
  #200000;
  resetN = 0;      
  #300000;
  resetN = 1;
  address = 7'b0010000;
  rw = 1;
  N_byte = 4'd2;
        
  #500000;
 	$finish;
		
  end 
endmodule
  
  
