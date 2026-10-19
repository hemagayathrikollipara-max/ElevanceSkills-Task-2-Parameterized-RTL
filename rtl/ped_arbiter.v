module ped_arbiter (
    input  wire clk,
    input  wire reset,

    input  wire req_a,
    input  wire req_b,

    output reg grant_a,
    output reg grant_b
);

    // 0 = Junction A gets priority next
    // 1 = Junction B gets priority next
    reg last_grant;

    // =========================================================
    // Round-Robin Arbitration
    // =========================================================

    always @(posedge clk) begin

        if (reset) begin

            last_grant <= 1'b1;
            grant_a    <= 1'b0;
            grant_b    <= 1'b0;

        end

        else begin

            // Default: no grant
            grant_a <= 1'b0;
            grant_b <= 1'b0;

            // -------------------------------------------------
            // Both requests are active
            // -------------------------------------------------

            if (req_a && req_b) begin

                if (last_grant == 1'b1) begin
                    grant_a    <= 1'b1;
                    last_grant <= 1'b0;
                end

                else begin
                    grant_b    <= 1'b1;
                    last_grant <= 1'b1;
                end

            end

            // -------------------------------------------------
            // Only Junction A requests
            // -------------------------------------------------

            else if (req_a) begin

                grant_a    <= 1'b1;
                last_grant <= 1'b0;

            end

            // -------------------------------------------------
            // Only Junction B requests
            // -------------------------------------------------

            else if (req_b) begin

                grant_b    <= 1'b1;
                last_grant <= 1'b1;

            end

        end

    end

endmodule