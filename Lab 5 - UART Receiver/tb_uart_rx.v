`timescale 1ns / 1ps

module tb_uart_rx;

    localparam integer CLKS_PER_BIT = 8;
    localparam integer BIT_TIME     = 80; // 8 clocks x 10 ns

    reg       clk;
    reg       reset;
    reg       rx;
    wire [7:0] data_out;
    wire      data_valid;
    wire      busy;
    integer   errors;

    uart_rx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk       (clk),
        .reset     (reset),
        .rx        (rx),
        .data_out  (data_out),
        .data_valid(data_valid),
        .busy      (busy)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task send_and_check;
        input [7:0] byte_to_send;
        integer i;
        begin
            // Start and data bits are driven LSB first.
            fork
                begin
                    @(posedge data_valid);
                    if (data_out !== byte_to_send) begin
                        $display("ERROR: expected %h, got %h", byte_to_send, data_out);
                        errors = errors + 1;
                    end
                end
                begin
                    rx = 1'b0;
                    #(BIT_TIME);
                    for (i = 0; i < 8; i = i + 1) begin
                        rx = byte_to_send[i];
                        #(BIT_TIME);
                    end
                    rx = 1'b1;
                    #(BIT_TIME);
                end
            join
        end
    endtask

    initial begin
        errors = 0;
        reset  = 1'b1;
        rx     = 1'b1;

        repeat (5) @(posedge clk);
        reset = 1'b0;

        send_and_check(8'h47);
        send_and_check(8'h68);
        send_and_check(8'h65);
        send_and_check(8'h65);
        send_and_check(8'h77);
        send_and_check(8'h61);
        send_and_check(8'h6C);
        send_and_check(8'h61);

        if (errors == 0)
            $display("SUCCESS: UART receiver decoded all test bytes.");
        else
            $display("FAILURE: %0d receiver errors.", errors);

        #100;
        $finish;
    end

endmodule
