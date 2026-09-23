`timescale 1ns / 1ps

module tb_uart_tx;

    reg clk;
    reg reset;
    reg data_valid;
    reg [7:0] data_in;

    wire tx;
    wire busy;

    parameter integer CLKS_PER_BIT = 10417;

    parameter integer BIT_TIME = 104170;

    integer errors;

    uart_tx #(
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .clk(clk),
        .reset(reset),
        .data_valid(data_valid),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    task send_and_check;
        input [7:0] byte_to_send;
        integer i;

        begin

            while (busy)
                @(posedge clk);

            @(posedge clk);
            data_in    <= byte_to_send;
            data_valid <= 1'b1;

            @(posedge clk);
            data_valid <= 1'b0;

            @(negedge tx);

            #(BIT_TIME / 2);

            if (tx !== 1'b0) begin
                $display("ERROR: start bit incorrect");
                errors = errors + 1;
            end

            for (i = 0; i < 8; i = i + 1) begin
                #(BIT_TIME);

                if (tx !== byte_to_send[i]) begin
                    $display(
                        "ERROR: byte %h bit %0d expected %b got %b",
                        byte_to_send,
                        i,
                        byte_to_send[i],
                        tx
                    );

                    errors = errors + 1;
                end
            end

            #(BIT_TIME);

            if (tx !== 1'b1) begin
                $display("ERROR: stop bit incorrect");
                errors = errors + 1;
            end

            #(BIT_TIME / 2);

        end
    endtask


    initial begin

        errors     = 0;
        reset      = 1'b1;
        data_valid = 1'b0;
        data_in    = 8'h00;

        repeat (5)
            @(posedge clk);

        reset = 1'b0;

        repeat (2)
            @(posedge clk);

        send_and_check(8'h47);
        send_and_check(8'h68);
        send_and_check(8'h65);
        send_and_check(8'h65);
        send_and_check(8'h77);
        send_and_check(8'h61);
        send_and_check(8'h6C);
        send_and_check(8'h61);

        if (errors == 0)
            $display("SUCCESS: All letters transmitted correctly.");
        else
            $display("Simulation finished with %0d errors.", errors);

        #1000;
        $finish;

    end

endmodule