module gen_clk(
  input wire clk_in,
  
  output reg clk_out
  );
  reg[27:0] counter = 28'd0;
  parameter divide_by = 28'd4;
  always_ff@(posedge clk_in)
  begin
    counter <= counter + 28'd1;
    if(counter >= (divide_by-1))
      begin
        counter <= 28'b0;
      end
      clk_out <= (counter < divide_by/2) ? 1'b1:1'b0;
  end
endmodule
  
