module bcd_counter(
    input ENABLE,
    input LOAD,
    input UP,
    input CLK,
    input CLR,
    input[3:0] D,
    output reg[3:0] Q,
    output CO
  );

  always @(posedge CLK or negedge CLR)
  begin

    if (!CLR)
      Q <= 0; // clear counter
    else if (ENABLE)
      if (LOAD)
        Q <= D; // load input D
      else if (UP)
        Q <= (Q == 9) ? 0 : Q + 1; // count up & reset to 0 after 9
      else
        Q <= (Q == 0) ? 9 : Q - 1; // count down & reset to 9 after 0

  end

  assign CO = ENABLE && ((UP && Q == 9) || (!UP && Q == 0));
  // CO is high,
  // CO at 9 when counting up
  // CO at 0 when counting down

endmodule
