module TopController (
    input  clk, rst_n,
    input  Fbusy, Tbusy, Cbusy,
    output Fstart, Tstart, Cstart,
    input  [1:0] opcode,
    output ready,
    output [1:0] mode
);
    
    typedef enum bit[4:0] {
        Ready        = 5'b00001,
        StartMeasure = 5'b00010,
        WaitMeasure  = 5'b00100,
        StartTx      = 5'b01000,
        WaitTx       = 5'b10000
    } state_t;
    state_t state;

    typedef enum bit[1:0] {
        None    = 2'b00,
        Mode10  = 2'b10,
        Mode01  = 2'b01,
        Mode11  = 2'b11
    } mode_t;

    // drives: ready
    always_comb ready = (state == Ready);

    // drives: state, Xstart, mode
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= Ready;
            {Fstart, Tstart, Cstart} <= 0;
            mode <= None;
        end

        else case(state)

            Ready: begin
                {Fstart, Tstart, Cstart} <= 0;
                mode <= opcode;
                if (opcode != None) state <= StartMeasure;
            end

            StartMeasure: begin
                {Fstart, Tstart} <= mode;
                if ({Fbusy, Tbusy} != 2'b00) state <= WaitMeasure;
            end

            WaitMeasure: begin
                {Fstart, Tstart} <= 2'b00;
                if ({Fbusy, Tbusy} == 2'b00) state <= StartTx;
            end

            StartTx: begin
                Cstart <= 1;
                if (Cbusy == 1) state <= WaitTx;
            end

            WaitTx: begin
                Cstart <= 0;
                if (Cbusy == 0) state <= Ready;
            end

            default: begin
                state <= Ready;
                {Fstart, Tstart, Cstart} <= 0;
                mode <= None;
            end
        endcase
    end

endmodule
