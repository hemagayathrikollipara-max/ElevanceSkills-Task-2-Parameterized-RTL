
module junction_controller #(
    parameter integer MIN_GREEN_TIME  = 3,
    parameter integer MAX_GREEN_TIME  = 10,
    parameter integer GREEN_EXTENSION = 1,
    parameter integer YELLOW_TIME     = 2,
    parameter integer RED_TIME        = 2,
    parameter integer PED_TIME        = 2,
    parameter integer COUNTER_WIDTH   = 8
)(
    input wire clk,
    input wire reset,
    input wire [2:0] traffic_density,
    input wire ped_grant,
    input wire emergency_override,
    input wire start_enable,

    output reg ns_green,
    output reg ns_yellow,
    output reg ew_green,
    output reg ew_yellow,
    output reg all_red,
    output reg ped_walk
);

    localparam [2:0] S_WAIT      = 3'd0;
    localparam [2:0] S_NS_GREEN  = 3'd1;
    localparam [2:0] S_NS_YELLOW = 3'd2;
    localparam [2:0] S_RED_NS_EW = 3'd3;
    localparam [2:0] S_EW_GREEN  = 3'd4;
    localparam [2:0] S_EW_YELLOW = 3'd5;
    localparam [2:0] S_RED_EW_NS = 3'd6;
    localparam [2:0] S_PED       = 3'd7;

    reg [2:0] state;
    reg [2:0] next_state;

    reg [COUNTER_WIDTH-1:0] adaptive_green_target;
    reg [COUNTER_WIDTH-1:0] phase_target;
    reg [COUNTER_WIDTH-1:0] calculated_green_target;

    integer calculated_time;

    wire timer_done;
    wire [COUNTER_WIDTH-1:0] phase_count;
    wire timer_start;

    reg ped_pending;
    reg ped_return_to_ns;

    // Calculate and clamp the adaptive green duration.
    always @(*) begin
        calculated_time =
            MIN_GREEN_TIME +
            (traffic_density * GREEN_EXTENSION);

        if (calculated_time < MIN_GREEN_TIME)
            calculated_green_target = MIN_GREEN_TIME;
        else if (calculated_time > MAX_GREEN_TIME)
            calculated_green_target = MAX_GREEN_TIME;
        else
            calculated_green_target = calculated_time;
    end

    // Keep the existing generic timer unchanged.
    assign timer_start = (state != S_WAIT);

    generic_timer #(
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) phase_timer (
        .clk(clk),
        .reset(reset || emergency_override),
        .start(timer_start),
        .count_target(phase_target),
        .done(timer_done),
        .count(phase_count)
    );

    // Next-state logic.
    always @(*) begin
        next_state = state;

        if (emergency_override) begin
            next_state = S_WAIT;
        end else begin
            case (state)

                S_WAIT: begin
                    if (start_enable)
                        next_state = S_NS_GREEN;
                end

                S_NS_GREEN: begin
                    if (timer_done)
                        next_state = S_NS_YELLOW;
                end

                S_NS_YELLOW: begin
                    if (timer_done)
                        next_state = S_RED_NS_EW;
                end

                S_RED_NS_EW: begin
                    if (timer_done) begin
                        if (ped_pending)
                            next_state = S_PED;
                        else
                            next_state = S_EW_GREEN;
                    end
                end

                S_EW_GREEN: begin
                    if (timer_done)
                        next_state = S_EW_YELLOW;
                end

                S_EW_YELLOW: begin
                    if (timer_done)
                        next_state = S_RED_EW_NS;
                end

                S_RED_EW_NS: begin
                    if (timer_done) begin
                        if (ped_pending)
                            next_state = S_PED;
                        else
                            next_state = S_NS_GREEN;
                    end
                end

                S_PED: begin
                    if (timer_done) begin
                        if (ped_return_to_ns)
                            next_state = S_NS_GREEN;
                        else
                            next_state = S_EW_GREEN;
                    end
                end

                default: next_state = S_WAIT;

            endcase
        end
    end

    // Select the duration for the current phase.
    always @(*) begin
        case (state)
            S_NS_GREEN:  phase_target = adaptive_green_target;
            S_EW_GREEN:  phase_target = adaptive_green_target;
            S_NS_YELLOW: phase_target = YELLOW_TIME;
            S_EW_YELLOW: phase_target = YELLOW_TIME;
            S_RED_NS_EW: phase_target = RED_TIME;
            S_RED_EW_NS: phase_target = RED_TIME;
            S_PED:       phase_target = PED_TIME;
            default:     phase_target = RED_TIME;
        endcase
    end

    // State transitions, density sampling, and pedestrian tracking.
    always @(posedge clk) begin
        if (reset) begin
            state <= S_WAIT;
            adaptive_green_target <= MIN_GREEN_TIME;
            ped_pending <= 1'b0;
            ped_return_to_ns <= 1'b1;
        end else if (emergency_override) begin
            state <= S_WAIT;
            adaptive_green_target <= calculated_green_target;

            if (ped_grant)
                ped_pending <= 1'b1;
        end else begin
            state <= next_state;

            // Remember a granted pedestrian request.
            if (ped_grant)
                ped_pending <= 1'b1;

            // Clear the pending request after pedestrian service.
            if (state == S_PED && timer_done)
                ped_pending <= 1'b0;

            if (state == S_RED_NS_EW && timer_done)
                ped_return_to_ns <= 1'b0;
            else if (state == S_RED_EW_NS && timer_done)
                ped_return_to_ns <= 1'b1;

            // Sample density when entering a green phase.
            if ((next_state == S_NS_GREEN) ||
                (next_state == S_EW_GREEN))
                adaptive_green_target <= calculated_green_target;
        end
    end

    // Output decoding.
    always @(*) begin
        ns_green  = 1'b0;
        ns_yellow = 1'b0;
        ew_green  = 1'b0;
        ew_yellow = 1'b0;
        all_red   = 1'b0;
        ped_walk  = 1'b0;

        case (state)
            S_NS_GREEN:  ns_green = 1'b1;
            S_NS_YELLOW: ns_yellow = 1'b1;
            S_EW_GREEN:  ew_green = 1'b1;
            S_EW_YELLOW: ew_yellow = 1'b1;

            S_PED: begin
                all_red  = 1'b1;
                ped_walk = 1'b1;
            end

            S_WAIT,
            S_RED_NS_EW,
            S_RED_EW_NS: all_red = 1'b1;

            default: all_red = 1'b1;
        endcase

        // Emergency override forces all outputs to a safe state.
        if (emergency_override) begin
            ns_green  = 1'b0;
            ns_yellow = 1'b0;
            ew_green  = 1'b0;
            ew_yellow = 1'b0;
            all_red   = 1'b1;
            ped_walk  = 1'b0;
        end
    end

endmodule
