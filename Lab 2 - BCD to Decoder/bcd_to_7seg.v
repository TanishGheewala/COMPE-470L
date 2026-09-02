module bcd_to_7seg #(
    parameter COMMON_ANODE = 1'b1 // common cathode or anode display (0 or 1)
  )(
    input  wire [3:0] bcd,
    output wire [6:0] seg,
    output wire [3:0] an,
    output wire dp
  );

  reg [6:0] segments_on; // each bit indicates on state

  always @(*)
  begin
    case (bcd)
      4'd0:
        segments_on = 7'b0111111;
      4'd1:
        segments_on = 7'b0000110;
      4'd2:
        segments_on = 7'b1011011;
      4'd3:
        segments_on = 7'b1001111;
      4'd4:
        segments_on = 7'b1100110;
      4'd5:
        segments_on = 7'b1101101;
      4'd6:
        segments_on = 7'b1111101;
      4'd7:
        segments_on = 7'b0000111;
      4'd8:
        segments_on = 7'b1111111;
      4'd9:
        segments_on = 7'b1101111;
      default:
        segments_on = 7'b0000000;  // default blank state for invalid values
    endcase
  end

  assign seg = COMMON_ANODE ? ~segments_on : segments_on;
  // common anode is active-low, so invert when COMMON_ANODE is 1
  assign an = 4'b1110; // required output type

  // Decimal point off (active-low).
  assign dp = 1'b1;

endmodule
