#include <verilated.h>
#include <verilated_vcd_c.h>
#include <iostream>
#include "VTopController.h"

VTopController *uut;
vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;       // in ns
}

void clocking() {
    vluint64_t timemod = main_time % 10; // 100MHz clocking
    if (timemod < 5)
        uut->clk = 0;
    else
        uut->clk = 1;
}

int main(int argc, char **argv, char **env) {
    Verilated::commandArgs(argc, argv);
    uut = new VTopController();

    Verilated::traceEverOn(true);
    VerilatedVcdC *tfp = new VerilatedVcdC;
    uut->trace(tfp, 99);
    tfp->open("wave.vcd");

    uut->rst_n = 0;
    uut->Fbusy = 0;
    uut->Tbusy = 0;
    uut->Cbusy = 0;
    uut->opcode = 0;

    while(main_time <= 2000) {               // simulate 100ms before finish

        if (main_time % int(10e6) == 0)      // print time to stdout
            cout << '\r' << "Simulation time: ["<< main_time / 1e6 << " ms]" << flush;

        if (main_time > 100)                // disable reset
            uut->rst_n = 1;

        clocking();

        switch (main_time) {
            case 200:
                uut->opcode = 3;
                break;

            case 210:
                uut->Fbusy = 1;
                break;

             case 220:
                 uut->Tbusy = 1;
                 break;

            case 350:
                uut->Fbusy = 0;
                uut->Tbusy = 0;
                break;

            case 390:
                uut->Cbusy = 1;
                break;

            case 1000 :
                uut->Cbusy = 0;
                break;

            default:
                break;
        }

        uut->eval();
        tfp->dump(main_time);
        main_time += 1;
    }

    cout << '\r' << "Simulation done." << endl;
    uut->final();
    tfp->close();
    delete uut;
}
