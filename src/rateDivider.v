module rateDivider(d, clock, clock_slower, reset);
  input [7:0]d; // use decimal
  input clock;
  input reset;
  output clock_slower;
  
  reg [7:0]q; // use decimal

  assign clock_slower = (q == 1'd0) ? 1 : 0;

  always @(posedge clock)
  begin
    if (reset == 1'b0)
      q <= 1'd0;
    else if (q == 1'd0)
      q <= d;
    else
      q <= q - 1'd1;
  end
endmodule