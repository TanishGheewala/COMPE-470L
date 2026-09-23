`timescale 1ns / 1ps

module uart_tx #(
    parameter integer CLKS_PER_BIT = 10417
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       data_valid,
    input  wire [7:0] data_in,
    output reg        tx,
    output reg        busy
);

    localparam IDLE  = 2'd0;
    localparam START = 2'd1;
    localparam DATA  = 2'd2;
    localparam STOP  = 2'd3;

    reg [1:0]  state;
    reg [13:0] clk_count;
    reg [2:0]  bit_index;
    reg [7:0]  data_latched;

    always @(posedge clk) begin

        if (reset) begin
            state        <= IDLE;
            clk_count    <= 14'd0;
            bit_index    <= 3'd0;
            data_latched <= 8'd0;
            tx           <= 1'b1;
            busy         <= 1'b0;
        end

        else begin
            case (state)

                IDLE: begin
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    clk_count <= 14'd0;
                    bit_index <= 3'd0;

                    if (data_valid) begin
                        data_latched <= data_in;
                        busy         <= 1'b1;
                        state        <= START;
                    end
                end

                START: begin
                    tx   <= 1'b0;
                    busy <= 1'b1;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 14'd0;
                        state     <= DATA;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                DATA: begin
                    tx   <= data_latched[bit_index];
                    busy <= 1'b1;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 14'd0;

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
                    tx   <= 1'b1;
                    busy <= 1'b1;

                    if (clk_count == CLKS_PER_BIT - 1) begin
                        clk_count <= 14'd0;
                        busy      <= 1'b0;
                        state     <= IDLE;
                    end
                    else begin
                        clk_count <= clk_count + 1'b1;
                    end
                end

                default: begin
                    state     <= IDLE;
                    tx        <= 1'b1;
                    busy      <= 1'b0;
                    clk_count <= 14'd0;
                    bit_index <= 3'd0;
                end

            endcase
        end
    end

endmodule