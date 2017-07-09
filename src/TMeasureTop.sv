module TMeasureTop (
    input  clk [0:9], rst_n,
    input  wave,
    input  start,
    output busy,
    output int val [0:9]
);

    typedef enum bit[4:0] {
        Ready         = 5'b00001,
        RiseStart0    = 5'b00010,
        RiseStart1    = 5'b00100,
        DropStart     = 5'b01000,
        WaitMeasure   = 5'b10000
    } state_t;

    state_t state;
    bit counter_start;
    
    wire [0:9] counter_busy;
    
    generate genvar i;
        for (i = 0; i < 10; i++) begin : generate_counters
            Counter worker(
                .clk( clk[i] ),
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
    always_ff @(posedge clk[0] or negedge rst_n) begin
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
                state <= WaitMeasure;
            end

            WaitMeasure: begin
                if (counter_busy == 10'b0) begin
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
