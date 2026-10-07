`timescale 1ns / 1ps

module uart_rx #(
    parameter integer CLKS_PER_BIT = 10417 // Because Baud: 9600, Clock: 100MHz, CLKS_PER_BIT = 100000000 / 9600 = 10417
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       rx,
    output reg [7:0]  data_out,
    output reg        data_valid,
    output reg        busy
);

    // 4 States: IDLE, START, DATA, STOP
    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    localparam integer HALF_CLKS_PER_BIT = CLKS_PER_BIT / 2;

    reg [1:0]  state;
    reg [13:0] clk_count;
    reg [2:0]  bit_index;

    always @(posedge clk) begin
        if (reset) begin
            state      <= IDLE;
            clk_count  <= 14'd0;
            bit_index  <= 3'd0;
            data_out   <= 8'd0;
            data_valid <= 1'b0;
            busy       <= 1'b0;
        end
        else begin
            data_valid <= 1'b0;

            case (state)
                IDLE: begin
                    busy      <= 1'b0;
                    clk_count <= 14'd0;
                    bit_index <= 3'd0;

                    if (rx == 1'b0) begin
                        state <= START;
                        busy  <= 1'b1;
                    end
                end

                START: begin
                    busy <= 1'b1;

                    if (clk_count == HALF_CLKS_PER_BIT - 1) begin
                        clk_count <= 14'd0;

                        if (rx == 1'b0)
                            state <= DATA;
                        else
                            state <= IDLE;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    busy <= 1'b1;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count         <= 14'd0;
                        data_out[bit_index] <= rx;

                        if (bit_index == 3'd7) begin
                            bit_index <= 3'd0;
                            state     <= STOP;
                        end
                        else begin
                            bit_index <= bit_index + 1'b1;
                        end
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                STOP: begin
                    busy <= 1'b1;

                    // Check the stop bit at its midpoint.
                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 14'd0;
                        state     <= IDLE;
                        busy      <= 1'b0;

                        if (rx == 1'b1)
                            data_valid <= 1'b1;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state      <= IDLE;
                    clk_count  <= 14'd0;
                    bit_index  <= 3'd0;
                    data_valid <= 1'b0;
                    busy       <= 1'b0;
                end
            endcase
        end
    end

endmodule
