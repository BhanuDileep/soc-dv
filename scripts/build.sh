#!/bin/bash
# Build the simulator once: RTL file list + UVM testbench.
# Used by both run.sh and regress.sh, so the build command exists in one place only.
set -e
SIMDIR=~/soc-dv/build/sim
TB=$HOME/soc-dv/tb
mkdir -p $SIMDIR && cd $SIMDIR

rm -rf obj_tb
verilator --binary --timing -j 0 -Wno-fatal --timescale 1ns/1ps \
  -DDISABLE_PRIM_CDC_RAND_DELAY \
  --trace-fst --trace-structs \
  +define+UVM_NO_DPI +define+UVM \
  +incdir+$HOME/uvm-core/src \
  +incdir+$TB/agents/dbus +incdir+$TB/agents/uart +incdir+$TB/agents/gpio +incdir+$TB/env +incdir+$TB/tests \
  $HOME/uvm-core/src/uvm_pkg.sv \
  $TB/ral/uvm12_compat.svh \
  -f $HOME/soc-dv/build/tb.vc \
  $HOME/uvm-core/src/uvm_pkg.sv \
  $TB/agents/dbus/ib_dbus_if.sv \
  $TB/agents/uart/uart_if.sv \
  $TB/agents/dbus/dbus_pkg.sv \
  $TB/agents/uart/uart_pkg.sv \
  $TB/agents/gpio/gpio_if.sv \
  $TB/agents/gpio/gpio_pakg.sv \
  $TB/env/soc_env_pkg.sv \
  $TB/tests/soc_test_pkg.sv \
  $TB/tb_top.sv \
  --top-module tb_top --Mdir obj_tb -o tb_sim \
  > build.log 2>&1 || { echo "BUILD FAILED (see $SIMDIR/build.log)"; exit 1; }
echo "Build OK"