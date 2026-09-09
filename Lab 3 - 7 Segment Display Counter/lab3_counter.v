module lab3_counter(
    input wire clk,
    output reg [6:0] seg,
    output wire [3:0] an
);

    reg [26:0] clock_count = 0;
    reg [3:0] hex_count = 4'hF;

    // Enable only the rightmost display
    assign an = 4'b1110;

    // Change number once every second
    always @(posedge clk) begin
        if (clock_count == 99_999_999) begin
            clock_count <= 0;

            if (hex_count == 0)
                hex_count <= 4'hF;
            else
                hex_count <= hex_count - 1;
        end
        else begin
            clock_count <= clock_count + 1;
        end
    end

    // Basys 3 seven-segment display is active-low
    // seg = {g,f,e,d,c,b,a}
    always @(*) begin
        case (hex_count)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end

endmodule