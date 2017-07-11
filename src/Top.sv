module Top (
    input  clk_50m, rst_n,
    input  A, B,
    input  [2:0] btn,
    output [3:0] state,
    output TxD
);

	wire [1:0] opcode;
    ModeSel ms (
        .clk, .rst_n,
        .btn,
        .mode(opcode)
    );

    wire clkgrp [0:4];
    Toplevel t (
        .clk, .rst_n,
        .clkgrp,
        .A, .B,
        .opcode,
        .state,
        .TxD
    );

    pll0 p0 (
        .inclk0 ( clk ),
        .c0     ( clkgrp[0] ),
        .c1     ( clkgrp[1] ),
        .c2     ( clkgrp[2] ),
        .c3     ( clkgrp[3] ),
        .c4     ( clkgrp[4] )
    );

    pll1 p1 (
        .inclk0 ( clk_50m ),
        .c0     ( clk )
    );

endmodule
