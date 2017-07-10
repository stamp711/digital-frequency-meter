module Counter (
    input  clk, rst_n, wave,
    input  start,
    output busy,
    output int val
);
    typedef enum bit[3:0] {
        Ready    = 4'b0001,
        WaitLow  = 4'b0010,
        WaitHigh = 4'b0100,
        Count    = 4'b1000
    } state_t;
    state_t state;

    // drives: busy
    always_comb busy = (state != Ready);

    // drives: state, val
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= Ready;
            val <= 0;
        end

        else case(state)
            Ready:
                if (start) begin
                    val <= 0;
                    state <= WaitLow;
                end

            WaitLow:
                if (~wave) state <= WaitHigh;

            WaitHigh:
                if (wave) state <= Count;
            
            Count: begin
                val <= val + 1;
                if (~wave) state <= Ready;
            end
            
            default: state <= Ready;
        endcase
    end
endmodule
