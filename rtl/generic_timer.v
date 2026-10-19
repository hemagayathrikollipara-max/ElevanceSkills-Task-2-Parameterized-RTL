module generic_timer #(
    parameter integer COUNTER_WIDTH = 8
)(
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     start,
    input  wire [COUNTER_WIDTH-1:0] count_target,

    output reg                      done,
    output reg  [COUNTER_WIDTH-1:0] count
);

always @(posedge clk) begin

    if (reset) begin
        count <= {COUNTER_WIDTH{1'b0}};
        done  <= 1'b0;
    end

    else begin
        done <= 1'b0;

        if (start) begin

            // Zero target condition
            if (count_target == {COUNTER_WIDTH{1'b0}}) begin
                count <= {COUNTER_WIDTH{1'b0}};
                done  <= 1'b1;
            end

            // Target count reached
            else if (count >= (count_target - 1'b1)) begin
                count <= {COUNTER_WIDTH{1'b0}};
                done  <= 1'b1;
            end

            // Continue counting
            else begin
                count <= count + 1'b1;
            end
        end

        else begin
            count <= {COUNTER_WIDTH{1'b0}};
        end
    end

end

endmodule