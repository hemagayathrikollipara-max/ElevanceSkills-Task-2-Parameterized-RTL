
`timescale 1ns/1ps

module amtgc_top_tb;

    parameter MIN_GREEN_TIME  = 3;
    parameter MAX_GREEN_TIME  = 10;
    parameter GREEN_EXTENSION = 1;
    parameter GREEN_WAVE_CYCLES = 5;
    parameter COUNTER_WIDTH   = 8;

    reg clk;
    reg reset;

    reg [2:0] traffic_density_a;
    reg [2:0] traffic_density_b;

    reg ped_req_a;
    reg ped_req_b;
    reg emergency_override;

    wire ns_green_a, ns_yellow_a;
    wire ew_green_a, ew_yellow_a;
    wire all_red_a, ped_walk_a;

    wire ns_green_b, ns_yellow_b;
    wire ew_green_b, ew_yellow_b;
    wire all_red_b, ped_walk_b;

    wire green_wave_active;

    integer density;
    integer expected_cycles;
    integer actual_cycles;
    integer density_test_count;
    integer density_fail_count;
    integer timeout_count;

    time junction_a_start;
    time junction_b_start;
    time green_wave_delay;
    time green_start_time;
    time green_end_time;

    reg green_wave_pass;
    reg pedestrian_seen_a;
    reg pedestrian_seen_b;
    reg emergency_pass;

    // Device Under Test
    amtgc_top #(
        .MIN_GREEN_TIME(MIN_GREEN_TIME),
        .MAX_GREEN_TIME(MAX_GREEN_TIME),
        .GREEN_EXTENSION(GREEN_EXTENSION),
        .GREEN_WAVE_CYCLES(GREEN_WAVE_CYCLES),
        .COUNTER_WIDTH(COUNTER_WIDTH)
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

    // 100 MHz simulation clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Record whether each pedestrian phase has occurred
    always @(posedge clk) begin
        if (reset) begin
            pedestrian_seen_a <= 0;
            pedestrian_seen_b <= 0;
        end else begin
            if (ped_walk_a)
                pedestrian_seen_a <= 1;

            if (ped_walk_b)
                pedestrian_seen_b <= 1;
        end
    end

    // Measure the next NS-green phase.
    // The task uses a bounded wait to avoid hanging forever.
    task measure_ns_green;
        input integer density_value;
        integer expected;
        integer wait_cycles;
        integer measured;
        begin
            expected = MIN_GREEN_TIME +
                       density_value * GREEN_EXTENSION;

            if (expected < MIN_GREEN_TIME)
                expected = MIN_GREEN_TIME;

            if (expected > MAX_GREEN_TIME)
                expected = MAX_GREEN_TIME;

            wait_cycles = 0;

            // Wait for NS green to become active.
            while ((ns_green_a !== 1'b1) &&
                   (wait_cycles < 3000)) begin
                @(negedge clk);
                wait_cycles = wait_cycles + 1;
            end

            if (ns_green_a !== 1'b1) begin
                $display(
                    "FAIL: Timeout waiting for NS green at density %0d",
                    density_value
                );
                density_fail_count = density_fail_count + 1;
            end else begin
                green_start_time = $time;

                // Wait for this green phase to end.
                while ((ns_green_a === 1'b1) &&
                       (wait_cycles < 3000)) begin
                    @(negedge clk);
                    wait_cycles = wait_cycles + 1;
                end

                green_end_time = $time;
                measured = (green_end_time - green_start_time) / 10;

                actual_cycles = measured;

                $display(
                    "Density A=%0d: expected=%0d cycles, measured=%0d cycles",
                    density_value, expected, actual_cycles
                );

                density_test_count = density_test_count + 1;

                if (actual_cycles == expected) begin
                    $display("PASS: Adaptive green duration matched.");
                end else begin
                    $display("FAIL: Adaptive green duration mismatch.");
                    density_fail_count = density_fail_count + 1;
                end
            end
        end
    endtask

    // Green-wave timing check.
    // Measure first NS-green start at A and first NS-green start at B.
    initial begin
        junction_a_start = 0;
        junction_b_start = 0;
        green_wave_delay = 0;
        green_wave_pass = 0;

        wait (reset == 1'b0);

        @(posedge ns_green_a);
        junction_a_start = $time;

        @(posedge ns_green_b);
        junction_b_start = $time;

        green_wave_delay = junction_b_start - junction_a_start;

        $display(
            "Green-wave delay = %0t ns",
            green_wave_delay
        );

        if (green_wave_delay >= GREEN_WAVE_CYCLES * 10) begin
            green_wave_pass = 1;
            $display("PASS: Green-wave minimum delay achieved.");
        end else begin
            $display("FAIL: Green-wave delay is too short.");
        end
    end

    // Main test sequence
    initial begin
        reset = 1;

        traffic_density_a = 0;
        traffic_density_b = 0;

        ped_req_a = 0;
        ped_req_b = 0;
        emergency_override = 0;

        density_test_count = 0;
        density_fail_count = 0;
        emergency_pass = 0;

        $display("========================================");
        $display(" AMTGC TASK 4 TESTBENCH");
        $display(" Adaptive Green Timing Verification");
        $display("========================================");

        repeat (3) @(negedge clk);
        reset = 0;

        // Allow the initial phases to settle.
        repeat (8) @(negedge clk);

        // Test all 8 density input values.
        for (density = 0; density < 8; density = density + 1) begin
            @(negedge clk);

            traffic_density_a = density;
            traffic_density_b = 7 - density;

            $display(
                "Applying traffic density A=%0d, B=%0d at %0t ns",
                density, 7-density, $time
            );

            measure_ns_green(density);
        end

        // Pedestrian requests at both junctions
        @(negedge clk);
        ped_req_a = 1;
        ped_req_b = 1;

        $display(
            "Both pedestrian requests asserted at %0t ns",
            $time
        );

        repeat (40) @(negedge clk);

        ped_req_a = 0;
        ped_req_b = 0;

        // Emergency all-red check
        repeat (5) @(negedge clk);

        emergency_override = 1;
        $display(
            "Emergency override asserted at %0t ns",
            $time
        );

        repeat (3) @(negedge clk);

        if (all_red_a && all_red_b) begin
            emergency_pass = 1;
            $display("PASS: Both junctions are all-red.");
        end else begin
            $display("FAIL: Both junctions are not all-red.");
        end

        emergency_override = 0;

        $display(
            "Emergency override released at %0t ns",
            $time
        );

        repeat (30) @(negedge clk);

        // Final summary
        $display("");
        $display("========================================");
        $display(" TASK 4 TEST SUMMARY");
        $display("========================================");

        $display(
            "Density measurements: %0d",
            density_test_count
        );

        $display(
            "Density duration failures: %0d",
            density_fail_count
        );

        $display(
            "Green-wave check: %s",
            green_wave_pass ? "PASS" : "FAIL"
        );

        $display(
            "Emergency all-red check: %s",
            emergency_pass ? "PASS" : "FAIL"
        );

        $display(
            "Pedestrian A served: %s",
            pedestrian_seen_a ? "YES" : "NO"
        );

        $display(
            "Pedestrian B served: %s",
            pedestrian_seen_b ? "YES" : "NO"
        );

        if ((density_test_count == 8) &&
            (density_fail_count == 0) &&
            green_wave_pass &&
            emergency_pass &&
            pedestrian_seen_a &&
            pedestrian_seen_b) begin

            $display("OVERALL RESULT: PASS");

        end else begin
            $display("OVERALL RESULT: CHECK FAILURES ABOVE");
        end

        $display("========================================");
        $finish;
    end

    // Global simulation safety timeout
    initial begin
        #500000;
        $display("ERROR: Simulation timeout.");
        $finish;
    end

endmodule
