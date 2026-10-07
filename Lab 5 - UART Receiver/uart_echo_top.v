`timescale 1ns / 1ps

module uart_echo_top #(
    parameter integer CLKS_PER_BIT = 10417
)(
    input  wire       clk,
    input  wire       reset_btn,
    input  wire       rx_serial,
    output wire       tx_serial,
    output wire [7:0] led
);

    wire [7:0] rx_data;
    wire       rx_valid;
    wire       rx_busy;
    wire       tx_busy;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) receiver (
        .clk       (clk),
        .reset     (reset_btn),
        .rx        (rx_serial),
        .data_out  (rx_data),
        .data_valid(rx_valid),
        .busy      (rx_busy)
    );

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) transmitter (
        .clk       (clk),
        .reset     (reset_btn),
        .data_valid(rx_valid),
        .data_in   (rx_data),
        .tx        (tx_serial),
        .busy      (tx_busy)
    );

    assign led = rx_data;

endmodule
