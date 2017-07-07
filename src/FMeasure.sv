module FMeasure (
    input  clk, rst_n,
    input  wave,        // wave under measurement
    output safe,
    output int a, b
);

    bit clk_2s, counter_en;
    bit a_busy, b_busy;

    // drives: safe
    always_comb safe = !(a_busy ^ b_busy);

    // generate T=2s clock (1s high & 1s low)
    // drives: sec, clk_2s
    int sec;
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            sec <= 0;
            clk_2s <= 0;
        end

        else begin
            if (sec == (100_000_000 - 1)) begin
                sec <= 0;
                clk_2s <= ~clk_2s;
            end else sec <= sec + 1;
        end
    end

    // generate enable singal for counters
    // drives: counter_en
    always_ff @(posedge wave or negedge rst_n) begin

        if (!rst_n) counter_en <= 0;

        else begin
            if (clk_2s) counter_en <= 1;
            else counter_en <= 0;
        end
    end

    // counter for clk
    // drives: counter_clk, a, a_busy
    int counter_clk;
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            counter_clk <= 0;
            a <= 0;
            a_busy <= 0;
        end

        else begin
            if (counter_en) begin
                counter_clk <= counter_clk + 1;
                a_busy <= 1;
            end
            else if (counter_clk != 0) begin
                    a <= counter_clk;
                    counter_clk <= 0;
                    a_busy <= 0;
            end
        end
    end

    // counter for wave
    // drives: counter_wave, b, b_busy
    int counter_wave;
    always_ff @(posedge wave or negedge rst_n) begin

        if (!rst_n) begin
            counter_wave <= 0;
            b <= 0;
            b_busy <= 0;
        end

        else begin
            if (counter_en) begin
                counter_wave <= counter_wave +1;
                b_busy <= 1;
            end
            else if (counter_wave != 0) begin
                b <= counter_wave;
                counter_wave <= 0;
                b_busy <= 0;
            end
        end
    end

endmodule
