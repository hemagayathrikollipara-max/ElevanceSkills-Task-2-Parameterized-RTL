module junction_controller #(
    parameter integer GREEN_TIME    = 3,
    parameter integer YELLOW_TIME   = 2,
    parameter integer RED_TIME      = 2,
    parameter integer PED_TIME      = 2,
    parameter integer COUNTER_WIDTH = 8
)(
    input  wire clk,
    input  wire reset,
    input  wire ped_request,

    output reg ns_green,
    output reg ns_yellow,
    output reg ew_green,
    output reg ew_yellow,
    output reg all_red,
    output reg ped_walk
);

    //====================================================
    // FSM State Definitions
    //====================================================

    localparam [3:0] S_NS_GREEN          = 4'd0;
    localparam [3:0] S_NS_YELLOW         = 4'd1;
    localparam [3:0] S_ALL_RED_BEFORE_EW = 4'd2;
    localparam [3:0] S_EW_GREEN          = 4'd3;
    localparam [3:0] S_EW_YELLOW         = 4'd4;
    localparam [3:0] S_ALL_RED_BEFORE_NS = 4'd5;
    localparam [3:0] S_PED               = 4'd6;
    localparam [3:0] S_ALL_RED_AFTER_PED = 4'd7;

    reg [3:0] state;
    reg [3:0] next_state;

    //====================================================
    // Pedestrian Request Registers
    //====================================================

    reg ped_pending;
    reg ped_armed;

    //====================================================
    // Timer Signals
    //====================================================

    wire timer_done;

    reg timer_start;

    reg [COUNTER_WIDTH-1:0] timer_target;

    //====================================================
    // Generic Timer Instance
    //====================================================

    generic_timer #(
        .COUNTER_WIDTH(COUNTER_WIDTH)
    ) phase_timer (
        .clk(clk),
        .reset(reset),
        .start(timer_start),
        .count_target(timer_target),
        .done(timer_done),
        .count()
    );

    //====================================================
    // State Register and Pedestrian Request Handling
    //====================================================

    always @(posedge clk) begin

        if (reset) begin

            state       <= S_NS_GREEN;
            ped_pending <= 1'b0;
            ped_armed   <= 1'b1;

        end
        else begin

            state <= next_state;

            // Re-arm when pedestrian request is released
            if (!ped_request)
                ped_armed <= 1'b1;

            // Capture a new pedestrian request
            if (ped_request &&
                ped_armed &&
                !ped_pending &&
                (state != S_PED)) begin

                ped_pending <= 1'b1;
                ped_armed   <= 1'b0;

            end

            // Clear pending request after entering pedestrian phase
            if (state == S_PED)
                ped_pending <= 1'b0;

        end

    end

    //====================================================
    // Next-State Logic
    //====================================================

    always @(*) begin

        // Default values
        next_state   = state;
        timer_start  = 1'b1;
        timer_target = {COUNTER_WIDTH{1'b0}};

        case (state)

            //============================================
            // North-South Green
            //============================================

            S_NS_GREEN: begin

                timer_target = GREEN_TIME;

                if (timer_done)
                    next_state = S_NS_YELLOW;

            end

            //============================================
            // North-South Yellow
            //============================================

            S_NS_YELLOW: begin

                timer_target = YELLOW_TIME;

                if (timer_done)
                    next_state = S_ALL_RED_BEFORE_EW;

            end

            //============================================
            // All Red Before East-West
            //============================================

            S_ALL_RED_BEFORE_EW: begin

                timer_target = RED_TIME;

                if (timer_done) begin

                    if (ped_pending)
                        next_state = S_PED;
                    else
                        next_state = S_EW_GREEN;

                end

            end

            //============================================
            // East-West Green
            //============================================

            S_EW_GREEN: begin

                timer_target = GREEN_TIME;

                if (timer_done)
                    next_state = S_EW_YELLOW;

            end

            //============================================
            // East-West Yellow
            //============================================

            S_EW_YELLOW: begin

                timer_target = YELLOW_TIME;

                if (timer_done)
                    next_state = S_ALL_RED_BEFORE_NS;

            end

            //============================================
            // All Red Before North-South
            //============================================

            S_ALL_RED_BEFORE_NS: begin

                timer_target = RED_TIME;

                if (timer_done) begin

                    if (ped_pending)
                        next_state = S_PED;
                    else
                        next_state = S_NS_GREEN;

                end

            end

            //============================================
            // Pedestrian Phase
            //============================================

            S_PED: begin

                timer_target = PED_TIME;

                if (timer_done)
                    next_state = S_ALL_RED_AFTER_PED;

            end

            //============================================
            // All Red After Pedestrian Phase
            //============================================

            S_ALL_RED_AFTER_PED: begin

                timer_target = RED_TIME;

                if (timer_done)
                    next_state = S_EW_GREEN;

            end

            //============================================
            // Default Safety State
            //============================================

            default: begin

                next_state = S_NS_GREEN;

            end

        endcase

    end

    //====================================================
    // Moore Output Logic
    //====================================================

    always @(*) begin

        // Default all outputs OFF
        ns_green  = 1'b0;
        ns_yellow = 1'b0;
        ew_green  = 1'b0;
        ew_yellow = 1'b0;
        all_red   = 1'b0;
        ped_walk  = 1'b0;

        case (state)

            // North-South Green
            S_NS_GREEN: begin
                ns_green = 1'b1;
            end

            // North-South Yellow
            S_NS_YELLOW: begin
                ns_yellow = 1'b1;
            end

            // All Red Before East-West
            S_ALL_RED_BEFORE_EW: begin
                all_red = 1'b1;
            end

            // East-West Green
            S_EW_GREEN: begin
                ew_green = 1'b1;
            end

            // East-West Yellow
            S_EW_YELLOW: begin
                ew_yellow = 1'b1;
            end

            // All Red Before North-South
            S_ALL_RED_BEFORE_NS: begin
                all_red = 1'b1;
            end

            // Pedestrian Walk
            S_PED: begin
                ped_walk = 1'b1;
            end

            // All Red After Pedestrian
            S_ALL_RED_AFTER_PED: begin
                all_red = 1'b1;
            end

            // Safety default
            default: begin
                all_red = 1'b1;
            end

        endcase

    end

endmodule