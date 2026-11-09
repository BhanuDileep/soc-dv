#!/bin/bash
set -e                                   # stop at the first failing command
cd ~/ibex/build/lowrisc_ibex_ibex_simple_system_0/sim-verilator

# 1. Clean old outputs
rm -rf obj_tb ibex_simple_system.log trace_core_00000000.log tb.fst

# 2. Build
verilator --binary --timing -j 0 -Wno-fatal --timescale 1ns/1ps \
  -DDISABLE_PRIM_CDC_RAND_DELAY --unroll-count 72 \
  --trace-fst --trace-structs \
  +define+UVM_NO_DPI \
  +incdir+$HOME/uvm-core/src +incdir+$HOME/ibex/tb \
  -f tb.vc \
  $HOME/uvm-core/src/uvm_pkg.sv \
  $HOME/ibex/tb/ib_dbus_if.sv \
  $HOME/ibex/tb/soc_tb_pkg.sv \
  $HOME/ibex/tb/tb_top.sv \
  --top-module tb_top --Mdir obj_tb -o tb_sim > build.log 2>&1

# 3. Run (test name is the first argument; default hello_test)
TEST=${1:-hello_test}
VMEM=~/ibex/examples/sw/simple_system/$TEST/$TEST.vmem
./obj_tb/tb_sim +vmem=$VMEM | tail -5

# 4. Show results
echo "---- log ----"
cat ibex_simple_system.log 2>/dev/null || echo "(no log file)"
echo "---- last trace lines ----"
tail -3 trace_core_00000000.log 2>/dev/null || echo "(no trace file)"