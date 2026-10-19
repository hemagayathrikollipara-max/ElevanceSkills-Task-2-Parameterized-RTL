
`timescale 1ns / 1ps

module amtgc_top_task5_tb;

    parameter integer MIN_GREEN_TIME = 3;
    parameter integer MAX_GREEN_TIME = 10;
    parameter integer GREEN_EXTENSION = 1;
    parameter integer GREEN_WAVE_CYCLES = 5;

    reg clk;
    reg reset;
    reg [2:0] traffic_density_a;
    reg [2:0] traffic_density_b;
    reg ped_req_a;
    reg ped_req_b;
    reg emergency_override;

    wire ns_green_a, ns_yellow_a, ew_green_a, ew_yellow_a;
    wire all_red_a, ped_walk_a;
    wire ns_green_b, ns_yellow_b, ew_green_b, ew_yellow_b;
    wire all_red_b, ped_walk_b;
    wire green_wave_active;

    integer errors;
    integer checks;
    integer grants_a;
    integer grants_b;
    integer i;
    integer phase_timeout;
    integer phase_seen_count;
    integer random_seed;
    integer target_expected;
    integer target_actual;

    reg [31:0] random_state;
    reg [31:0] random_value;

    reg [7:0] emergency_phase_seen;

    localparam S_WAIT       = 0;
    localparam S_NS_GREEN   = 1;
    localparam S_NS_YELLOW  = 2;
    localparam S_RED_NS_EW  = 3;
    localparam S_EW_GREEN   = 4;
    localparam S_EW_YELLOW  = 5;
    localparam S_RED_EW_NS  = 6;
    localparam S_PED        = 7;

    amtgc_top #(
        .MIN_GREEN_TIME(MIN_GREEN_TIME),
        .MAX_GREEN_TIME(MAX_GREEN_TIME),
        .GREEN_EXTENSION(GREEN_EXTENSION),
        .GREEN_WAVE_CYCLES(GREEN_WAVE_CYCLES)
    ) dut (
        .clk(clk),
        .reset(reset),
        .traffic_density_a(traffic_density_a),
        .traffic_density_b(traffic_density_b),
        .ped_req_a(ped_req_a),
        .ped_req_b(ped_req_b),
        .emergency_override(emergency_override),

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
        .ped_walk_b(ped_walk_b),

        .green_wave_active(green_wave_active)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    // --------------------------------------------------
    // Check emergency override outputs
    // --------------------------------------------------
    task check_emergency;
    begin
        #1;
        checks = checks + 1;

        if (ns_green_a !== 1'b0 ||
            ns_yellow_a !== 1'b0 ||
            ew_green_a !== 1'b0 ||
            ew_yellow_a !== 1'b0 ||
            all_red_a !== 1'b1 ||
            ped_walk_a !== 1'b0) begin
            $display("ERROR: Junction A emergency outputs incorrect at %0t", $time);
            errors = errors + 1;
        end

        if (ns_green_b !== 1'b0 ||
            ns_yellow_b !== 1'b0 ||
            ew_green_b !== 1'b0 ||
            ew_yellow_b !== 1'b0 ||
            all_red_b !== 1'b1 ||
            ped_walk_b !== 1'b0) begin
            $display("ERROR: Junction B emergency outputs incorrect at %0t", $time);
            errors = errors + 1;
        end
    end
    endtask

    // --------------------------------------------------
    // Check for unknown output values
    // --------------------------------------------------
    task check_known_outputs;
    begin
        checks = checks + 1;

        if ((^{
            ns_green_a, ns_yellow_a, ew_green_a, ew_yellow_a,
            all_red_a, ped_walk_a,
            ns_green_b, ns_yellow_b, ew_green_b, ew_yellow_b,
            all_red_b, ped_walk_b, green_wave_active
        }) === 1'bx) begin
            $display("ERROR: X/Z detected on outputs at %0t", $time);
            errors = errors + 1;
        end
    end
    endtask

    // --------------------------------------------------
    // Wait for a specific Junction A FSM state
    // --------------------------------------------------
    task wait_for_phase;
        input integer phase_id;
        input integer max_cycles;
        integer count;
        reg found;
    begin
        count = 0;
        found = 1'b0;

        while (count < max_cycles && !found) begin
            @(negedge clk);

            if (dut.junction_A.state == phase_id)
                found = 1'b1;

            count = count + 1;
        end

        if (!found) begin
            $display("ERROR: Timeout waiting for Junction A state %0d", phase_id);
            errors = errors + 1;
        end else begin
            $display("Reached Junction A state %0d at %0t",
                     phase_id, $time);
        end
    end
    endtask

    // ==================================================
    // MAIN TEST SEQUENCE
    // ==================================================
    initial begin
        errors = 0;
        checks = 0;
        grants_a = 0;
        grants_b = 0;
        phase_seen_count = 0;

        random_seed = 32'h51A7C0DE;
        random_state = random_seed;
        random_value = 0;
        emergency_phase_seen = 8'b0;

        reset = 1'b1;
        emergency_override = 1'b0;
        traffic_density_a = 0;
        traffic_density_b = 0;
        ped_req_a = 0;
        ped_req_b = 0;

        $display("==============================================");
        $display("AMTGC TASK 5 SELF-CHECKING VERIFICATION");
        $display("==============================================");

        // TEST 1: Initial reset
        repeat (3) @(negedge clk);

        if (dut.junction_A.state !== S_WAIT ||
            dut.junction_B.state !== S_WAIT) begin
            $display("ERROR: FSM did not enter WAIT on reset");
            errors = errors + 1;
        end else begin
            $display("TEST 1 PASS: reset sequence");
        end

        reset = 1'b0;
        repeat (2) @(negedge clk);

        // TEST 2: Adaptive green targets, density 0 through 7
        $display("TEST 2: Adaptive green targets");

        for (i = 0; i < 8; i = i + 1) begin
            traffic_density_a = i;
            traffic_density_b = i;
            #1;

            target_expected = MIN_GREEN_TIME + i * GREEN_EXTENSION;

            if (target_expected > MAX_GREEN_TIME)
                target_expected = MAX_GREEN_TIME;

            target_actual = dut.junction_A.calculated_green_target;
            checks = checks + 1;

            if (target_actual !== target_expected) begin
                $display("ERROR: A density=%0d target=%0d expected=%0d",
                         i, target_actual, target_expected);
                errors = errors + 1;
            end

            target_actual = dut.junction_B.calculated_green_target;
            checks = checks + 1;

            if (target_actual !== target_expected) begin
                $display("ERROR: B density=%0d target=%0d expected=%0d",
                         i, target_actual, target_expected);
                errors = errors + 1;
            end
        end

        $display("TEST 2 completed");

        // TEST 3: Green-wave activation
        $display("TEST 3: Green-wave activation");

        phase_timeout = 0;

        while (green_wave_active !== 1'b1 &&
               phase_timeout < 20) begin
            @(negedge clk);
            phase_timeout = phase_timeout + 1;
        end

        checks = checks + 1;

        if (green_wave_active !== 1'b1) begin
            $display("ERROR: Green wave did not activate");
            errors = errors + 1;
        end else begin
            $display("TEST 3 PASS: green wave activated");
        end

        // Exercise six density combinations while green wave is active
        for (i = 0; i < 6; i = i + 1) begin
            traffic_density_a = i % 8;
            traffic_density_b = (i * 3) % 8;

            repeat (2) @(negedge clk);

            checks = checks + 1;

            if (green_wave_active !== 1'b1) begin
                $display("ERROR: Green wave unexpectedly dropped");
                errors = errors + 1;
            end
        end

        $display("TEST 3 density combinations completed");

        // TEST 4: Pedestrian round-robin fairness
        $display("TEST 4: Pedestrian arbitration fairness");

        ped_req_a = 1'b1;
        ped_req_b = 1'b1;
        grants_a = 0;
        grants_b = 0;

        // 200 samples; both requests remain asserted
        repeat (200) begin
            @(negedge clk);

            if (dut.ped_grant_a === 1'b1)
                grants_a = grants_a + 1;

            if (dut.ped_grant_b === 1'b1)
                grants_b = grants_b + 1;
        end

        $display("Pedestrian grants: A=%0d B=%0d", grants_a, grants_b);

        checks = checks + 1;

        if (grants_a == 0 || grants_b == 0 ||
            (grants_a - grants_b > 1) ||
            (grants_b - grants_a > 1)) begin
            $display("ERROR: Pedestrian arbitration fairness failed");
            errors = errors + 1;
        end else begin
            $display("TEST 4 PASS: both requests received grants");
        end

        // ==================================================
        // TEST 5: Emergency override in every FSM state
        // Keep pedestrian requests asserted so S_PED can
        // be reached if the controller's FSM allows it.
        // ==================================================
        $display("TEST 5: Emergency override phase coverage");

        ped_req_a = 1'b1;
        ped_req_b = 1'b1;

        reset = 1'b1;
        emergency_override = 1'b0;
        @(negedge clk);

        // Check emergency in WAIT state
        emergency_override = 1'b1;
        check_emergency();
        emergency_phase_seen[S_WAIT] = 1'b1;

        @(negedge clk);
        reset = 1'b0;
        emergency_override = 1'b0;

        // Walk through states 1..7 and assert emergency
        // as soon as each state is observed.
        for (i = S_NS_GREEN; i <= S_PED; i = i + 1) begin
            wait_for_phase(i, 500);

            if (dut.junction_A.state == i) begin
                emergency_override = 1'b1;
                check_emergency();

                emergency_phase_seen[i] = 1'b1;

                // Let the emergency be observed at a clock edge.
                @(negedge clk);
                emergency_override = 1'b0;

                // Allow the FSM to resume before next phase search.
                repeat (1) @(negedge clk);
            end
        end

        phase_seen_count = 0;

        for (i = 0; i < 8; i = i + 1) begin
            if (emergency_phase_seen[i] === 1'b1)
                phase_seen_count = phase_seen_count + 1;
            else begin
                $display("ERROR: Emergency test missed state %0d", i);
                errors = errors + 1;
            end
        end

        $display("Emergency phase coverage: %0d/8", phase_seen_count);

        // Clear pedestrian requests after phase coverage test
        ped_req_a = 1'b0;
        ped_req_b = 1'b0;

        // TEST 6: Rapid emergency assertion/deassertion
        $display("TEST 6: Rapid emergency toggling");

        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);

            emergency_override = 1'b1;
            check_emergency();

            #1;
            emergency_override = 1'b0;
        end

        $display("TEST 6 completed");

        // TEST 7: Mid-run reset
        $display("TEST 7: Mid-run reset");

        repeat (4) @(negedge clk);

        reset = 1'b1;
        repeat (2) @(negedge clk);

        checks = checks + 1;

        if (dut.junction_A.state !== S_WAIT ||
            dut.junction_B.state !== S_WAIT) begin
            $display("ERROR: Mid-run reset did not return FSMs to WAIT");
            errors = errors + 1;
        end else begin
            $display("TEST 7 PASS: both FSMs returned to WAIT");
        end

        reset = 1'b0;

        // TEST 8: Deterministic randomized stimulus
        // 300 cycles, reproducible LCG seed.
        $display("TEST 8: Deterministic randomized stimulus seed=%h",
                 random_seed);

        for (i = 0; i < 300; i = i + 1) begin
            @(negedge clk);

            random_state =
                random_state * 32'd1664525 + 32'd1013904223;
            traffic_density_a = random_state[2:0];

            random_state =
                random_state * 32'd1664525 + 32'd1013904223;
            traffic_density_b = random_state[2:0];

            random_state =
                random_state * 32'd1664525 + 32'd1013904223;
            ped_req_a = random_state[0];

            random_state =
                random_state * 32'd1664525 + 32'd1013904223;
            ped_req_b = random_state[0];

            // Brief emergency pulses
            if ((i % 17) == 0)
                emergency_override = 1'b1;
            else
                emergency_override = 1'b0;

            // Mid-run reset pulses
            if (i == 100 || i == 220)
                reset = 1'b1;
            else if (i == 102 || i == 222)
                reset = 1'b0;

            #1;
            check_known_outputs();

            if (emergency_override)
                check_emergency();
        end

        emergency_override = 1'b0;
        reset = 1'b0;
        ped_req_a = 1'b0;
        ped_req_b = 1'b0;

        repeat (3) @(negedge clk);

        // Final summary
        $display("----------------------------------------------");
        $display("TASK 5 VERIFICATION SUMMARY");
        $display("Checks performed : %0d", checks);
        $display("Pedestrian grants: A=%0d B=%0d", grants_a, grants_b);
        $display("Emergency phase coverage: %0d/8", phase_seen_count);
        $display("Detected errors  : %0d", errors);

        if (errors == 0)
            $display("RESULT: PASS - ALL ENABLED CHECKS PASSED");
        else
            $display("RESULT: FAIL - PLEASE REVIEW ERRORS");

        $display("----------------------------------------------");
        $finish;
    end

endmodule
