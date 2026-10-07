module traffic_two_junction (

    input wire clk,
    input wire reset,

    input wire ped_request_a,
    input wire ped_request_b,

    // Junction A outputs
    output wire ns_green_a,
    output wire ns_yellow_a,
    output wire ew_green_a,
    output wire ew_yellow_a,
    output wire all_red_a,
    output wire ped_walk_a,

    // Junction B outputs
    output wire ns_green_b,
    output wire ns_yellow_b,
    output wire ew_green_b,
    output wire ew_yellow_b,
    output wire all_red_b,
    output wire ped_walk_b
);

    //====================================================
    // Junction A
    //====================================================

    junction_controller #(
        .GREEN_TIME(3),
        .YELLOW_TIME(2),
        .RED_TIME(2),
        .PED_TIME(2),
        .COUNTER_WIDTH(8)
    ) junction_A (

        .clk(clk),
        .reset(reset),
        .ped_request(ped_request_a),

        .ns_green(ns_green_a),
        .ns_yellow(ns_yellow_a),
        .ew_green(ew_green_a),
        .ew_yellow(ew_yellow_a),
        .all_red(all_red_a),
        .ped_walk(ped_walk_a)
    );

    //====================================================
    // Junction B
    //====================================================

    junction_controller #(
        .GREEN_TIME(4),
        .YELLOW_TIME(2),
        .RED_TIME(3),
        .PED_TIME(3),
        .COUNTER_WIDTH(8)
    ) junction_B (

        .clk(clk),
        .reset(reset),
        .ped_request(ped_request_b),

        .ns_green(ns_green_b),
        .ns_yellow(ns_yellow_b),
        .ew_green(ew_green_b),
        .ew_yellow(ew_yellow_b),
        .all_red(all_red_b),
        .ped_walk(ped_walk_b)
    );

endmodule