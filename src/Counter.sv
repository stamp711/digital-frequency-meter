module Counter (
    input  clk, rst_n, wave,
    input  start,
    output busy,
    output int val
);
    typedef enum bit[2:0] {
        Ready = 3'b001,
        Wait  = 3'b010,
        Count = 3'b100
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
                    state <= Wait;
                end

            Wait:
                if (wave) state <= Count;
            
            Count: begin
                val <= val + 1;
                if (~wave) state <= Ready;
            end
            
            default: state <= Ready;
        endcase
    end
endmodule
