module Toplevel (
    input  clk, rst_n,
    input  clkgrp [0:4],
    input  A, B,
    input  [1:0] opcode,
    output [3:0] state,
    output TxD
);

    wire Fbusy,  Tbusy,  Cbusy;
    wire Fstart, Tstart, Cstart;
    wire [1:0] mode;

    TopController controller (
        .clk, .rst_n,
        .Fbusy,  .Tbusy,  .Cbusy,
        .Fstart, .Tstart, .Cstart,
        .opcode,
        .ready(),
        .out_state(state),
        .mode
    );

    wire FWave, TWave;
    WaveSel wsel (
        .mode,
        .A, .B,
        .FWave, .TWave
    );

    int Tval [1:5];
    int Fval [1:2];
    SerialTop serial (
        .clk, .rst_n,
        .start( Cstart ),
        .busy( Cbusy ),
        .mode,
        .Tval, .Fval,
        .TxD
    );

    FMeasureTop fm (
        .clk, .rst_n,
        .wave( FWave ),
        .start( Fstart ),
        .busy( Fbusy ),
        .ca( Fval[2] ),
        .cb( Fval[1] )
    );

    TMeasureTop tm (
        .clk,
        .rst_n,
        .clkgrp,
        .wave( TWave ),
        .start( Tstart ),
        .busy( Tbusy ),
        .out_state(),
        .val( Tval )
    );

endmodule
