`timescale 1ns/1ps

module generic_timer_tb;

    reg clk;
    reg reset;

    reg start_1;
    reg [3:0] count_target_1;
    wire done_1;
    wire [3:0] count_1;

    reg start_2;
    reg [3:0] count_target_2;
    wire done_2;
    wire [3:0] count_2;

    reg start_3;
    reg [3:0] count_target_3;
    wire done_3;
    wire [3:0] count_3;

    // Timer 1
    generic_timer #(
        .COUNTER_WIDTH(4)
    ) timer_1 (
        .clk(clk),
        .reset(reset),
        .start(start_1),
        .count_target(count_target_1),
        .done(done_1),
        .count(count_1)
    );

    // Timer 2
    generic_timer #(
        .COUNTER_WIDTH(4)
    ) timer_2 (
        .clk(clk),
        .reset(reset),
        .start(start_2),
        .count_target(count_target_2),
        .done(done_2),
        .count(count_2)
    );

    // Timer 3
    generic_timer #(
        .COUNTER_WIDTH(4)
    ) timer_3 (
        .clk(clk),
        .reset(reset),
        .start(start_3),
        .count_target(count_target_3),
        .done(done_3),
        .count(count_3)
    );

    // Clock
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;

        start_1 = 0;
        start_2 = 0;
        start_3 = 0;

        count_target_1 = 4'd3;
        count_target_2 = 4'd5;
        count_target_3 = 4'd0;

        #10;
        reset = 0;

        // Start all timers
        start_1 = 1;
        start_2 = 1;
        start_3 = 1;

        #60;

        // Reset while counting
        reset = 1;
        #10;
        reset = 0;

        start_1 = 1;
        start_2 = 1;
        start_3 = 0;

        #60;

        $finish;

    end

endmodule