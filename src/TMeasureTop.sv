module TMeasureTop (
    input  clk, rst_n,
    input  clkgrp [0:4],
    input  wave,
    input  start,
    output busy,
    output [3:0] out_state,
    output int val [0:4]
);

    assign out_state =  state[4:1];

    typedef enum bit[5:0] {
        Ready,
        RiseStart0,
        RiseStart1,
        DropStart,
        WaitMeasure0,
        WaitMeasure1
    } state_t;

    state_t state;
    bit counter_start;
    
    wire [4:0] counter_busy;
    
    generate genvar i;
        for (i = 0; i < 5; i++) begin : generate_counters
            Counter worker(
                .clk( clkgrp[i] ),
                .rst_n, .wave,
                .start( counter_start ),
                .busy( counter_busy[i] ),
                .val( val[i] )
            );
        end
    endgenerate

    // drives: busy
    always_comb busy = (state != Ready);

    // drives: state, counter_start
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= Ready;
            counter_start <= 0;
        end

        else case(state)
            Ready:
                if (start) state <= RiseStart0;

            RiseStart0: begin
                counter_start <= 1;
                state <= RiseStart1;
            end

            RiseStart1: begin
                counter_start <= 1;
                state <= DropStart;
            end

            DropStart: begin
                counter_start <= 0;
                state <= WaitMeasure0;
            end

            WaitMeasure0: begin
                if (counter_busy == 5'b0) begin
                    state <= WaitMeasure1;
                end
            end

            WaitMeasure1: begin
                if (counter_busy == 5'b0) begin
                    state <= Ready;
                end
            end

            default: begin
                state <= Ready;
                counter_start <= 0;
            end
        endcase
    end

endmodule
