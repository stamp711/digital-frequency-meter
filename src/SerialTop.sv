module SerialTop (
    input  clk, rst_n,
    input  start,
    output busy,
    input  [1:0] mode,
    input  int Tval [1:10],
    input  int Fval [1:2],
    output TxD
);

    parameter byte magic = 8'hff;
    typedef enum bit [10:0] {
        Ready       ,

        SetPara     ,

        TxMagicPrep ,
        TxMagic     ,
        TxMagicWait ,

        TxFreqCheck ,
        TxFreq      ,
        TxFreqWait  ,

        TxTimeCheck ,
        TxTime      ,
        TxTimeWait
    } state_t;

    state_t state;
    always_comb busy = (state != Ready);

    bit [1:0] mode_reg;
    bit [1:0] FWordCount;   // max 2
    bit [3:0] TWordCount;   // max 10
    bit [2:0] ByteCount;    // max 4

    wire tx_busy;
    int  tx_word;
    reg  tx_start;
    TxTop txTop (
        .clk, .rst_n,
        .start(tx_start), .busy(tx_busy),
        .TxD, .word(tx_word), .bytes(ByteCount)
    );

    // drives: state, mode_reg, FWordCount, TWordCount, tx_word, ByteCount, tx_start
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state <= Ready;
            tx_start <= 0;
        end

        else case(state)

            Ready: if (start) begin
                mode_reg <= mode;
                state <= SetPara;
            end

            SetPara: begin
                FWordCount <= mode_reg[1] ?  2 : 0;
                TWordCount <= mode_reg[0] ? 10 : 0;
                state <= TxMagicPrep;
            end

            /***** Transfer Magic *****/
            TxMagicPrep: begin
                tx_word <= {22'b0, mode_reg, magic};
                ByteCount <= 2;
                state <= TxMagic;
            end

            TxMagic: begin
                tx_start <= 1;
                if (tx_busy) state <= TxMagicWait;
            end

            TxMagicWait: begin
                tx_start <= 0;
                if (!tx_busy) state <= TxFreqCheck;
            end

            /***** Transfer Freq *****/
            TxFreqCheck: begin
                if (FWordCount == 0) state <= TxTimeCheck;
                else begin
                    tx_word <= Fval[FWordCount];
                    ByteCount <= 4;
                    FWordCount <= FWordCount - 1;
                    state <= TxFreq;
                end
            end

            TxFreq: begin
                tx_start <= 1;
                if (tx_busy) state <= TxFreqWait;
            end

            TxFreqWait: begin
                tx_start <= 0;
                if (!tx_busy) state <= TxFreqCheck;
            end

            /***** Transfer Time *****/
            TxTimeCheck: begin
                if (TWordCount == 0) state <= Ready;
                else begin
                    tx_word <= Tval[TWordCount];
                    ByteCount <= 4;
                    TWordCount <= TWordCount - 1;
                    state <= TxTime;
                end
            end

            TxTime: begin
                tx_start <= 1;
                if (tx_busy) state <= TxTimeWait;
            end

            TxTimeWait: begin
                tx_start <= 0;
                if (!tx_busy) state <= TxTimeCheck;
            end
            
            default: begin
                state <= Ready;
                tx_start <= 0;
            end
        endcase
    end
    
endmodule
