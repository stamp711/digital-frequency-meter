module TxTop (
    input  clk, rst_n,
    input  start,
    output busy,
    output TxD,
    input  int word,
    input  [2:0] bytes
);

    typedef enum bit [5:0] {
        Ready,
        CheckZero,
        RiseStart,
        DropStart,
        CountDec,
        WaitTx
    } state_t;

    state_t state;
    always_comb busy = (state != Ready);

    bit  [2:0] bytes_count;
    int  word_reg;
    wire tx_busy, tx_start;
    byte txbyte;

    assign txbyte = word_reg[7:0];
    
    Transmitter tx(.clk, .rst_n, .start(tx_start), .data(txbyte), .TxD, .busy(tx_busy));

    // drives: state, word_reg, bytes_count, tx_start
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) state <= Ready;

        else case(state)

            Ready: if (start) begin
                word_reg <= word;
                bytes_count <= bytes;
                state <= CheckZero;
            end

            CheckZero: begin
                if (bytes_count == 0) state <= Ready;
                else state <= RiseStart;
            end

            RiseStart: begin
                tx_start <= 1;
                state <= DropStart;
            end

            DropStart: if (tx_busy) begin
                tx_start <= 0;
                state <= CountDec;
            end

            CountDec: begin
                bytes_count <= bytes_count - 1;
                word_reg <= word_reg >> 8;
                state <= WaitTx;
            end

            WaitTx: if (!tx_busy) state <= CheckZero;

            default: state <= Ready;
        endcase
    end
    
endmodule
