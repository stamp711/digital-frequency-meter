module FMeasureTop (
    input  clk, rst_n,
    input  wave,
    input  start,
    output busy,
    output int ca, cb
);

    typedef enum bit[1:0] {
        Ready   = 2'b01,
        Busy    = 2'b10
    } state_t;

    state_t state;
    wire safe;
    int a, b;

    FMeasure worker(.*);

    // drives: state, ca, cb
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= Ready;
            ca <= 0;
            cb <= 0;
        end:

        else case(state)
            Ready:
                if (start) state <= Busy;
            
            Busy:
                if (safe) begin
                    ca <= a;
                    cb <= b;
                    state <= Ready;
                end
            
            default: state <= Ready;
        endcase
    end

    //drives: busy
    always_comb busy = (state == Busy);

endmodule
