module Counter (
    input  clk, rst_n, wave,
    input  start,
    output busy,
    output int val
);
    enum {
        Ready    = 0,
        WaitLow  = 1,
        WaitHigh = 2,
        Count    = 3
    } state_index_t;

    bit [3:0] state;

    // drives: busy
    always_comb busy = ~state[Ready];

    // drives: state, val
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= 4'b0001;
            val <= 0;
        end

        else case(1'b1)
            state[Ready]:
                if (start) begin
                    val <= 0;
                    state <= 4'b0010;
                end

            state[WaitLow]:
                if (~wave) state <= 4'b0100;

            state[WaitHigh]:
                if (wave) state <= 4'b1000;
            
            state[Count]: begin
                val <= val + 1;
                if (~wave) state <= Ready;
            end
            
            default: begin
                state <= 4'b0001;
            end
        endcase
    end
endmodule
