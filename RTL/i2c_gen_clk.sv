module gen_clk(
  input wire clk_in,
  input wire resetN,
  
  output reg clk_out,
  output reg scl_posedge,
  output reg scl_negedge
  );
  reg[27:0] counter;
  parameter divide_by = 28'd4;
  always_ff@(posedge clk_in, negedge resetN)
  begin
    if(~resetN)
      begin
        counter <= 28'd0;
      end
    else
      counter <= counter + 28'd1;
      if(counter >= (divide_by-1))
        begin
          counter <= 28'b0;
        end
        clk_out <= (counter < divide_by/2) ? 1'b1:1'b0;
    end
  always_ff@(posedge clk_in,negedge resetN)
  begin
    if(~resetN) scl_posedge <= 0;
     else begin
       if(counter == 0) scl_posedge  <= 1;
       else scl_posedge <= 0;
     end
  end
  always_ff@(posedge clk_in, negedge resetN)
  begin
    if(~resetN) scl_negedge <=0;
    else
      begin
        if(counter == divide_by/2) scl_negedge <= 1;
        else scl_negedge <= 0;
      end
  end
endmodule
