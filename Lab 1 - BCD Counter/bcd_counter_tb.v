`timescale 1ns / 1ps

module bcd_counter_tb;

  reg ENABLE;
  reg LOAD;
  reg UP;
  reg CLK;
  reg CLR;
  reg [3:0] D;

  wire [3:0] Q;
  wire CO;

  bcd_counter uut (
                .ENABLE(ENABLE),
                .LOAD(LOAD),
                .UP(UP),
                .CLK(CLK),
                .CLR(CLR),
                .D(D),
                .Q(Q),
                .CO(CO)
              );


  always #5 CLK = ~CLK; // every 5 ns

  initial
  begin

    // Initialize Inputs
    CLK = 0;
    CLR = 0;
    ENABLE = 0;
    LOAD = 0;
    UP = 1;
    D = 8;

    // Wait 10 ns for reset
    #10;
    CLR = 1;
    ENABLE = 1;
    LOAD = 1;

    // Load last digit of RedID (8)
    #10;
    LOAD = 0;

    // Count up 4 times
    #40;

    // Count down once
    UP = 0;
    #10;

    // Clear the counter
    CLR = 0;
    #10;

    $finish;

  end

endmodule
