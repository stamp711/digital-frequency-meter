module BaudGenerator (
    input  clk, rst_n,
    output tick
);
    parameter   clkfreq     = 100_000_000,
                altclkfreq  = 1_000_000,
                baud        = 9600,
                accwidth    = 16,
                inc         = 629;   // baud * (2^accwidth) / altclkfreq

    bit [6:0] altclkacc;
    wire altclk = altclkacc[6];
    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) altclkacc <= 0;
        else begin
            if (altclkacc == 99) altclkacc <= 0;
            else altclkacc <= altclkacc + 1;
        end
    end

    bit [accwidth-1:0] acc;
    always_ff @(posedge altclk or negedge rst_n) begin
        if (~rst_n) acc <= 0;
        else acc <= acc + inc;
    end

    assign tick = acc[accwidth-1];

endmodule
