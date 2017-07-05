module TopController (
    input  clk, rst_n,
    input  Fbusy, Tbusy, Cbusy,
    output Fstart, Tstart, Cstart,
    input  [1:0] opcode,
    output ready,
    output [1:0] mode
);
    
    typedef enum bit[4:0] {
        Ready,
        StartMeasure,
        WaitMeasure,
        StartTx,
        WaitTx
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

    // drives: state
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) state <= Ready;

        else case(state)
            
            Ready: begin
                if (opcode != None) state <= StartMeasure;
            end

            StartMeasure: begin
                if ({Fbusy, Tbusy} == mode) state <= WaitMeasure;
            end

            WaitMeasure: begin
                if ({Fbusy, Tbusy} == 2'b00) state <= StartTx;
            end

            StartTx: begin
                if (Cbusy == 1) state <= WaitTx;
            end

            WaitTx: begin
                if (Cbusy == 0) state <= Ready;
            end

            default:
                state <= Ready;
        endcase
    end

    // drives: Xstart, mode
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            {Fstart, Tstart, Cstart} <= 0;
            mode <= None;
        end

        else case(state)

            Ready: begin
                {Fstart, Tstart, Cstart} <= 0;
                mode <= opcode;
            end

            StartMeasure: begin
                {Fstart, Tstart} <= mode;
                Cstart <= 0;
                mode <= mode;
            end

            WaitMeasure: begin
                {Fstart, Tstart, Cstart} <= 0;
                mode <= mode;
            end

            StartTx: begin
                {Fstart, Tstart} <= 0;
                Cstart <= 1;
                mode <= mode;
            end

            WaitTx: begin
                {Fstart, Tstart, Cstart} <= 0;
                mode <= mode;
            end

            default: begin
                {Fstart, Tstart, Cstart} <= 0;
                mode <= None;
            end
        endcase
    end

endmodule
