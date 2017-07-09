module WaveSel (
    input  [1:0] mode,
    input  A, B,
    output FWave, TWave
);

    assign FWave = A;

    always_comb begin
        if (mode == 2'b01) TWave = ( A & (~B) );
        else TWave = A;
    end

endmodule
