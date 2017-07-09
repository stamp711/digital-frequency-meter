module Transmitter (
    input  clk, rst_n,
    input  start,
    input  byte data,
    output TxD, busy
);

    wire tick;
    BaudGenerator bg(.clk, rst_n, .tick);

    typedef enum bit[3:0] {
        Ready  = 4'b0000,
        Start  = 4'b0100,
        Bit0   = 4'b1000,
        Bit1   = 4'b1001,
        Bit2   = 4'b1010,
        Bit3   = 4'b1011,
        Bit4   = 4'b1100,
        Bit5   = 4'b1101,
        Bit6   = 4'b1110,
        Bit7   = 4'b1111,
        Stop0  = 4'b0001,
        Stop1  = 4'b0010
    } state_t;

    state_t state;
    byte data_reg;

    // drives: TxD
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) TxD <= 1;
        else begin
            if (~state[3]) TxD <= ~state[2];
            else TxD <= data_reg[state[2:0]];
        end
    end

    // drives: busy
    always_comb busy = (state != Ready);

    // drives: state, data_reg
    always_ff @(posedge tick or negedge rst_n) begin
        if (~rst_n) state <= Ready;
        else case(state)
            Ready:  if(start) begin
                state <= Start;
                data_reg <= data;
            end
            Start:  state <= Bit0;
            Bit0:   state <= Bit1;
            Bit1:   state <= Bit2;
            Bit2:   state <= Bit3;
            Bit3:   state <= Bit4;
            Bit4:   state <= Bit5;
            Bit5:   state <= Bit6;
            Bit6:   state <= Bit7;
            Bit7:   state <= Stop0;
            Stop0:  state <= Stop1;
            Stop1:  state <= Ready;
            default: begin
                state <= Ready;
                data_reg <= data;
            end
        endcase
    end
    
endmodule
