module Toplevel (
    input  clkgrp [0:9], rst_n,
    input  A, B,
    input  [1:0] opcode,
    output ready,
    output TxD
);

    wire clk;
    assign clk = clkgrp[0];

    wire Fbusy,  Tbusy,  Cbusy;
    wire Fstart, Tstart, Cstart;
    wire [1:0] mode;

    TopController controller (
        .clk, .rst_n,
        .Fbusy,  .Tbusy,  .Cbusy,
        .Fstart, .Tstart, .Cstart,
        .opcode,
        .ready,
        .mode
    );

    wire FWave, TWave;
    WaveSel wsel (
        .mode,
        .A, .B,
        .FWave, .TWave
    );

    wire int Tval [1:10];
    wire int Fval [1:2];
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
        .clk( clkgrp ),
        .rst_n,
        .wave( TWave ),
        .start( Tstart ),
        .busy( Tbusy ),
        .val( Tval )
    );

endmodule
