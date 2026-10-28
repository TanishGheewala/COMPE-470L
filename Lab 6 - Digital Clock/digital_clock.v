module digital_clock(
    input wire clk,
    input wire btnC,
    input wire btnU,
    input wire btnR,
    input wire [1:0] sw,
    output reg [6:0] seg,
    output reg [3:0] an,
    output wire dp,
    output wire led
);

reg [3:0] hour = 12;
reg [5:0] minute = 59;
reg [3:0] alarm_hour = 1;
reg [5:0] alarm_minute = 0;
reg [2:0] alarm_seconds = 0;
reg [26:0] second_count = 0;
reg [18:0] scan_count = 0;
reg [1:0] digit = 0;
reg [20:0] button_count = 0;
reg [1:0] hour_sync = 0;
reg [1:0] minute_sync = 0;
reg hour_old = 0;
reg minute_old = 0;
reg hour_press = 0;
reg minute_press = 0;
reg [3:0] data;

wire second_tick = (second_count == 99_999_999);
wire [3:0] next_hour = (minute == 59) ? ((hour == 12) ? 4'd1 : hour + 1'b1) : hour;
wire [5:0] next_minute = (minute == 59) ? 6'd0 : minute + 1'b1;
wire [3:0] shown_hour = (sw == 2'b01) ? alarm_hour : hour;
wire [5:0] shown_minute = (sw == 2'b01) ? alarm_minute : minute;
wire [3:0] hourten = shown_hour / 10;
wire [3:0] hourone = shown_hour % 10;
wire [3:0] minten = shown_minute / 10;
wire [3:0] minone = shown_minute % 10;

assign led = (sw == 2'b10 && alarm_seconds != 0);
assign dp = (digit == 2'd2) ? 1'b0 : 1'b1;

always @(posedge clk) begin
    hour_sync <= {hour_sync[0], btnU};
    minute_sync <= {minute_sync[0], btnR};
    hour_press <= 0;
    minute_press <= 0;
    if (button_count == 1_999_999) begin
        button_count <= 0;
        hour_press <= hour_sync[1] && !hour_old;
        minute_press <= minute_sync[1] && !minute_old;
        hour_old <= hour_sync[1];
        minute_old <= minute_sync[1];
    end else begin
        button_count <= button_count + 1'b1;
    end
end

always @(posedge clk) begin
    if (btnC) begin
        hour <= 12;
        minute <= 59;
        alarm_hour <= 1;
        alarm_minute <= 0;
        alarm_seconds <= 0;
        second_count <= 0;
    end else begin
        if (sw == 2'b01 || second_tick)
            second_count <= 0;
        else
            second_count <= second_count + 1'b1;

        if (sw == 2'b01) begin
            if (hour_press)
                alarm_hour <= (alarm_hour == 12) ? 4'd1 : alarm_hour + 1'b1;
            if (minute_press)
                alarm_minute <= (alarm_minute == 59) ? 6'd0 : alarm_minute + 1'b1;
        end else begin
            if (second_tick && !hour_press && !minute_press) begin
                hour <= next_hour;
                minute <= next_minute;
            end else begin
                if (hour_press)
                    hour <= (hour == 12) ? 4'd1 : hour + 1'b1;
                if (minute_press)
                    minute <= (minute == 59) ? 6'd0 : minute + 1'b1;
            end
        end

        if (sw != 2'b10)
            alarm_seconds <= 0;
        else if (second_tick && !hour_press && !minute_press) begin
            if (next_hour == alarm_hour && next_minute == alarm_minute)
                alarm_seconds <= 5;
            else if (alarm_seconds != 0)
                alarm_seconds <= alarm_seconds - 1'b1;
        end
    end
end

always @(posedge clk) begin
    if (scan_count == 499_999) begin
        scan_count <= 0;
        digit <= digit + 1'b1;
    end else begin
        scan_count <= scan_count + 1'b1;
    end
end

always @(*) begin
    case (digit)
        2'd0: begin an = 4'b1110; data = minone; end
        2'd1: begin an = 4'b1101; data = minten; end
        2'd2: begin an = 4'b1011; data = hourone; end
        default: begin an = 4'b0111; data = hourten; end
    endcase

    case (data)
        4'd0: seg = 7'b1000000;
        4'd1: seg = 7'b1111001;
        4'd2: seg = 7'b0100100;
        4'd3: seg = 7'b0110000;
        4'd4: seg = 7'b0011001;
        4'd5: seg = 7'b0010010;
        4'd6: seg = 7'b0000010;
        4'd7: seg = 7'b1111000;
        4'd8: seg = 7'b0000000;
        4'd9: seg = 7'b0010000;
        default: seg = 7'b1111111;
    endcase
end

endmodule
