#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "VFMeasureTop.h"

VFMeasureTop *uut;
vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;       // in ns
}

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);

    uut = new VFMeasureTop();

    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    uut->trace(tfp, 99);
    tfp->open("wave.vcd");

    uut->rst_n = 0;

    vluint64_t timemod;

    while(main_time <= 4e9) {               // simulate 4s before finish

        if (main_time % int(1e6) == 0)      // dump wave at every ms
            tfp->dump(main_time);

        if (main_time % int(10e6) == 0)      // print time to stdout
            cout << '\r' << "Simulation time: ["<< main_time / 1e6 << " ms]" << flush;

        if (main_time > 100)                // disable reset
            uut->rst_n = 1;

        timemod = main_time % 10;          // 100MHz clocking
        if (timemod < 5)
            uut->clk = 0;
        else
            uut->clk = 1;

        timemod = main_time % int(0.75e9);   // T=0.75s wave
        if (timemod < 0.375e9)
            uut->wave = 0;
        else
            uut->wave = 1;

        if (main_time == 10e6)
            uut->start = 1;

        uut->eval();
        main_time += 1;
    }

    cout << '\r' << "Simulation done." << endl;
    uut->final();
    tfp->close();
    delete uut;
}
