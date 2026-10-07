`timescale 1ns/1ps

module traffic_two_junction_tb;

    reg clk;
    reg reset;

    reg ped_request_a;
    reg ped_request_b;

    // Junction A outputs
    wire ns_green_a;
    wire ns_yellow_a;
    wire ew_green_a;
    wire ew_yellow_a;
    wire all_red_a;
    wire ped_walk_a;

    // Junction B outputs
    wire ns_green_b;
    wire ns_yellow_b;
    wire ew_green_b;
    wire ew_yellow_b;
    wire all_red_b;
    wire ped_walk_b;

    //====================================================
    // Two-Junction Top Module
    //====================================================

    traffic_two_junction dut (

        .clk(clk),
        .reset(reset),

        .ped_request_a(ped_request_a),
        .ped_request_b(ped_request_b),

        .ns_green_a(ns_green_a),
        .ns_yellow_a(ns_yellow_a),
        .ew_green_a(ew_green_a),
        .ew_yellow_a(ew_yellow_a),
        .all_red_a(all_red_a),
        .ped_walk_a(ped_walk_a),

        .ns_green_b(ns_green_b),
        .ns_yellow_b(ns_yellow_b),
        .ew_green_b(ew_green_b),
        .ew_yellow_b(ew_yellow_b),
        .all_red_b(all_red_b),
        .ped_walk_b(ped_walk_b)
    );

    //====================================================
    // Clock
    //====================================================

    always #5 clk = ~clk;

    //====================================================
    // Test Sequence
    //====================================================

    initial begin

        clk = 0;
        reset = 1;

        ped_request_a = 0;
        ped_request_b = 0;

        // Reset
        #10;
        reset = 0;

        // Normal operation
        #100;

        // Pedestrian request at Junction A
        ped_request_a = 1;
        #20;
        ped_request_a = 0;

        // Continue simulation
        #100;

        // Pedestrian request at Junction B
        ped_request_b = 1;
        #20;
        ped_request_b = 0;

        // Continue simulation
        #150;

        $finish;

    end

endmodule