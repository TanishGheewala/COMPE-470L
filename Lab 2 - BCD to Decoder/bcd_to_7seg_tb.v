`timescale 1ns / 1ps

module bcd_to_7seg_tb;

  localparam COMMON_ANODE = 1'b0; // 0 = common cathode, 1 = common anode

  reg [3:0] bcd;
  wire a, b, c, d, e, f, g;
  wire [6:0] actual_segments;
  reg [6:0] expected_on;
  reg [6:0] expected_segments;
  integer value;
  integer errors;

  assign actual_segments = {a, b, c, d, e, f, g};

  bcd_to_7seg #(.COMMON_ANODE(COMMON_ANODE)) dut (
                .bcd(bcd),
                .a(a), .b(b), .c(c), .d(d),
                .e(e), .f(f), .g(g)
              );

  // expected active-high pattern
  function [6:0] expected_pattern;
    input [3:0] digit;
    begin
      case (digit)
        4'd0:
          expected_pattern = 7'b1111110;
        4'd1:
          expected_pattern = 7'b0110000;
        4'd2:
          expected_pattern = 7'b1101101;
        4'd3:
          expected_pattern = 7'b1111001;
        4'd4:
          expected_pattern = 7'b0110011;
        4'd5:
          expected_pattern = 7'b1011011;
        4'd6:
          expected_pattern = 7'b1011111;
        4'd7:
          expected_pattern = 7'b1110000;
        4'd8:
          expected_pattern = 7'b1111111;
        4'd9:
          expected_pattern = 7'b1111011;
        default:
          expected_pattern = 7'b0000000;
      endcase
    end
  endfunction

  initial
  begin
    bcd = 0;
    errors = 0;

    // apply all possible values, then check the outputs
    for (value = 0; value < 16; value = value + 1)
    begin
      bcd = value;
      expected_on = expected_pattern(bcd);
      expected_segments = COMMON_ANODE ? ~expected_on : expected_on;
      #10;

      if (actual_segments !== expected_segments)
      begin
        errors = errors + 1;
        $display("FAIL: BCD=%0d expected=%b got=%b",
                 bcd, expected_segments, actual_segments);
      end
      else
        $display("PASS: BCD=%0d abcdefg=%b", bcd, actual_segments);
    end

    if (errors == 0)
      $display("ALL TESTS PASSED");
    else
      $display("TEST FAILED: %0d error(s)", errors);

    $finish;
  end

endmodule