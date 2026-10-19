module amtgc_top #(
    parameter integer MIN_GREEN_TIME = 3,
    parameter integer MAX_GREEN_TIME = 10,
    parameter integer GREEN_EXTENSION = 1,

    parameter integer YELLOW_A = 2,
    parameter integer RED_A = 2,
    parameter integer PED_A = 2,

    parameter integer YELLOW_B = 2,
    parameter integer RED_B = 3,
    parameter integer PED_B = 3,

    parameter integer COUNTER_WIDTH = 8,
    parameter integer GREEN_WAVE_CYCLES = 5
)(
    input wire clk,
    input wire reset,

    input wire [2:0] traffic_density_a,
    input wire [2:0] traffic_density_b,

    input wire ped_req_a,
    input wire ped_req_b,

    input wire emergency_override,

    output wire ns_green_a,
    output wire ns_yellow_a,
    output wire ew_green_a,
    output wire ew_yellow_a,
    output wire all_red_a,
    output wire ped_walk_a,

    output wire ns_green_b,
    output wire ns_yellow_b,
    output wire ew_green_b,
    output wire ew_yellow_b,
    output wire all_red_b,
    output wire ped_walk_b,

    output wire green_wave_active
);

    // --------------------------------------------------
    // Pedestrian round-robin arbiter
    // --------------------------------------------------
    wire ped_grant_a;
    wire ped_grant_b;

    ped_arbiter pedestrian_arbiter (
        .clk(clk),
        .reset(reset),
        .req_a(ped_req_a),
        .req_b(ped_req_b),
        .grant_a(ped_grant_a),
        .grant_b(ped_grant_b)
    );

    // --------------------------------------------------
    // Green-wave coordination
    // Junction A starts first; Junction B is enabled
    // after GREEN_WAVE_CYCLES clock cycles.
    // --------------------------------------------------
    reg [31:0] green_wave_counter;
    reg green_wave_enable_b;

    assign green_wave_active = green_wave_enable_b;

    always @(posedge clk) begin
        if (reset || emergency_override) begin
            green_wave_counter <= 0;
            green_wave_enable_b <= 1'b0;
        end else if (!green_wave_enable_b) begin
            if (GREEN_WAVE_CYCLES <= 1) begin
                green_wave_enable_b <= 1'b1;
            end else if (green_wave_counter >= GREEN_WAVE_CYCLES - 1) begin
                green_wave_enable_b <= 1'b1;
            end else begin
                green_wave_counter <= green_wave_counter + 1'b1;
            end
        end
    end

    // --------------------------------------------------
    // Junction A
    // --------------------------------------------------
    junction_controller #(
        .MIN_GREEN_TIME(MIN_GREEN_TIME),
        .MAX_GREEN_TIME(MAX_GREEN_TIME),
        .GREEN_EXTENSION(GREEN_EXTENSION),
        .YELLOW_TIME(YELLOW_A),
        .RED_TIME(RED_A),
        .PED_TIME(PED_A),
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) junction_A (
        .clk(clk),
        .reset(reset),
        .traffic_density(traffic_density_a),
        .ped_grant(ped_grant_a),
        .emergency_override(emergency_override),
        .start_enable(1'b1),

        .ns_green(ns_green_a),
        .ns_yellow(ns_yellow_a),
        .ew_green(ew_green_a),
        .ew_yellow(ew_yellow_a),
        .all_red(all_red_a),
        .ped_walk(ped_walk_a)
    );

    // --------------------------------------------------
    // Junction B
    // --------------------------------------------------
    junction_controller #(
        .MIN_GREEN_TIME(MIN_GREEN_TIME),
        .MAX_GREEN_TIME(MAX_GREEN_TIME),
        .GREEN_EXTENSION(GREEN_EXTENSION),
        .YELLOW_TIME(YELLOW_B),
        .RED_TIME(RED_B),
        .PED_TIME(PED_B),
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) junction_B (
        .clk(clk),
        .reset(reset),
        .traffic_density(traffic_density_b),
        .ped_grant(ped_grant_b),
        .emergency_override(emergency_override),
        .start_enable(green_wave_enable_b),

        .ns_green(ns_green_b),
        .ns_yellow(ns_yellow_b),
        .ew_green(ew_green_b),
        .ew_yellow(ew_yellow_b),
        .all_red(all_red_b),
        .ped_walk(ped_walk_b)
    );

endmodule