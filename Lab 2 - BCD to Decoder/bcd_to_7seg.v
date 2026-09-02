module bcd_to_7seg #(
    parameter COMMON_ANODE = 1'b0 // common cathode or anode display (0 or 1)
  )(
    input  wire [3:0] bcd,
    output wire a, b, c, d, e, f, g // physical LED segments
  );

  reg  [6:0] segments_on; // each bit indicates on state
  wire [6:0] segment_pins; // physical pins

  always @(*)
  begin
    case (bcd)
      4'd0:
        segments_on = 7'b1111110;
      4'd1:
        segments_on = 7'b0110000;
      4'd2:
        segments_on = 7'b1101101;
      4'd3:
        segments_on = 7'b1111001;
      4'd4:
        segments_on = 7'b0110011;
      4'd5:
        segments_on = 7'b1011011;
      4'd6:
        segments_on = 7'b1011111;
      4'd7:
        segments_on = 7'b1110000;
      4'd8:
        segments_on = 7'b1111111;
      4'd9:
        segments_on = 7'b1111011;
      default:
        segments_on = 7'b0000000; // default blank state for invalid values
    endcase
  end

  assign segment_pins = COMMON_ANODE ? ~segments_on : segments_on;
  // common anode is active-low, so invert truth table when COMMON_ANODE is 1
  assign {a, b, c, d, e, f, g} = segment_pins; // required output type

endmodule
