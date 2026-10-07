`timescale 1ns/1ps

module junction_controller_tb;

    reg clk;
    reg reset;
    reg ped_request;

    wire ns_green;
    wire ns_yellow;
    wire ew_green;
    wire ew_yellow;
    wire all_red;
    wire ped_walk;

    // Junction controller
    junction_controller #(
        .GREEN_TIME(3),
        .YELLOW_TIME(2),
        .RED_TIME(2),
        .PED_TIME(2),
        .COUNTER_WIDTH(8)
    ) dut (
        .clk(clk),
        .reset(reset),
        .ped_request(ped_request),

        .ns_green(ns_green),
        .ns_yellow(ns_yellow),
        .ew_green(ew_green),
        .ew_yellow(ew_yellow),
        .all_red(all_red),
        .ped_walk(ped_walk)
    );

    // 10 ns clock
    always #5 clk = ~clk;

    initial begin

        clk = 0;
        reset = 1;
        ped_request = 0;

        // Reset
        #10;
        reset = 0;

        // Normal traffic sequence
        #35;

        // Pedestrian request
        // Request is kept HIGH long enough to be captured
        ped_request = 1;
        #20;
        ped_request = 0;

        // Allow pedestrian phase to occur
        #100;

        // Second pedestrian request
        ped_request = 1;
        #20;
        ped_request = 0;

        #100;

        $finish;

    end

endmodule