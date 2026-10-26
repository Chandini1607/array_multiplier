# 4-bit Array Multiplier, RTL to GDSII (SKY130, open-source flow)

## Team
- Veekshita Sai, roll number 2024102026
- Chandini Gayathri, roll number 2024102020

## Environment
Ubuntu Linux, Docker, IIC-OSIC-TOOLS image (hpretl/iic-osic-tools:latest).

    sudo usermod -aG docker $USER
    git clone --depth=1 https://github.com/iic-jku/IIC-OSIC-TOOLS.git ~/IIC-OSIC-TOOLS
    cd ~/IIC-OSIC-TOOLS && ./start_vnc.sh
    (open http://localhost:80/?password=abc123 in the browser)

Inside the container, in every new terminal (/foss/designs is the same folder as ~/eda/designs on the host):

    sak-pdk sky130A
    cd /foss/designs/mult_project

## Part A: RTL and verification

    iverilog -g2012 -o sim tb/tb_mult.v rtl/full_adder.v rtl/mult_array.v
    vvp sim
    gtkwave mult.vcd

Result: PASS: 256 vectors checked, 0 errors.

Error test: sum in full_adder.v was temporarily changed to a ^ b with

    sed -i 's/assign sum  = a ^ b ^ cin;/assign sum  = a ^ b;/' rtl/full_adder.v

The testbench printed FAIL: 256 vectors checked, 95 errors, then the file was restored.

Hand example: A = last digit of roll number 2024102026 (6) + 5 = 11, B = 7, product 77.
Waveform: a=11, b=7 applied at 3680 ns, p=77 at 3695 ns (2 clock edges later).

## Part B: synthesis (Yosys)

    yosys -c synth/synth.tcl
    CELLS=$PDK_ROOT/sky130A/libs.ref/sky130_fd_sc_hd/verilog
    iverilog -g2012 -DFUNCTIONAL -DUNIT_DELAY=#1 -o gls tb/tb_mult.v $CELLS/primitives.v $CELLS/sky130_fd_sc_hd.v synth/mult_array_netlist.v
    vvp gls

Result: 73 cells, 16 flip-flops, 805.773 um2 total area. Netlist simulation: PASS: 256 vectors checked, 0 errors.

## Part C: static timing analysis (OpenSTA)
First run with "set T 10" in sta/sta.tcl, then changed to T = Tmin:

    sta -exit sta/sta.tcl
    sed -i 's/^set T 10$/set T 2.60/' sta/sta.tcl
    sta -exit sta/sta.tcl

T = 10 ns: worst slack 7.404 ns. T = 2.60 ns: worst slack +0.004 ns.
Result: Tmin = 2.596 ns, Fmax = 385.2 MHz.

## Part D: place and route (LibreLane)

    cd pnr
    sed -i -E 's/"CLOCK_PERIOD": [0-9.]+/"CLOCK_PERIOD": 7.0/' config.json
    librelane config.json
    cp runs/RUN_2026-10-24_23-10-37/final/metrics.json metrics.json
    cp runs/RUN_2026-10-24_23-10-37/final/gds/mult_array.gds mult_array.gds

Layout images were made with small local KLayout Python scripts (not committed), run as: klayout -b -r <script>.py
Final CLOCK_PERIOD = 7.0 ns (setup slack +0.335 ns, 0 DRC errors, 0 LVS errors).

## Part D run log
Rule used: CLOCK_PERIOD = 1.2 x Tmin (2.596 ns) = 3.12, rounded up to 3.5 ns. If timing fails, add 0.5 ns and run again.
- Run 1: 3.5 ns. FAIL, worst setup slack -2.144 ns (max_ss_100C_1v60). DRC, LVS, antenna passed.
- Run 2: 4.0 ns. FAIL, worst setup slack -1.644 ns.
- Run 3: 4.5 ns. FAIL, worst setup slack -1.144 ns.
- Run 4: 5.0 ns. FAIL, worst setup slack -0.644 ns.
- Run 5: 5.5 ns. FAIL, worst setup slack -0.144 ns.
- Run 6: 6.0 ns. FAIL, worst setup slack -0.082 ns.
- Run 7: 6.5 ns. FAIL, worst setup slack -0.165 ns (critical path is the multiplier logic ending at p_next[6]).
- Run 8: 7.0 ns. PASS, worst setup slack 0.3353042383098231 ns, 0 DRC, 0 LVS. Folder runs/RUN_2026-10-24_23-10-37
