module ModeSel (
    input  clk, rst_n,
    input  [2:0] btn,
    output [1:0] mode
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) mode <= 2'b10;
        else case(1'b0)

            btn[0]: mode <= 2'b10;
            btn[1]: mode <= 2'b01;
            btn[2]: mode <= 2'b11;
            
            default: mode <= mode;
        endcase
    end

endmodule
