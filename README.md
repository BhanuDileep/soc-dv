# Ibex SoC-Level Verification

SoC-level UVM verification of a small RISC-V SoC built around the lowRISC Ibex core,
with OpenTitan UART, GPIO, and PLIC peripherals on a TileLink-UL (TL-UL) fabric.
Bare-metal C firmware runs on the core and coordinates with the UVM testbench.
Built entirely with free tools (Verilator, FuseSoC, RISC-V GCC).

## What's where

| Folder | Contents | Origin |
|---|---|---|
| `rtl/` | SoC integration: `soc_top.sv` (TL-UL fabric, peripherals, interrupt map), `soc_addr_decode.sv`, `soc_ram_2p.sv`, `soc.core` | Own work. `simulator_ctrl.sv`, `timer.sv`, `ram_2p.sv` are adapted from the Ibex `simple_system` example |
| `tb/` | UVM testbench: bus, UART, and GPIO agents; scoreboards; virtual sequencer; tests; decoder unit test | Own work |
| `sw/tests/` | Bare-metal C tests | Own work |
| `sw/include/` | Register headers generated from the IPs' `.hjson` descriptions | Generated with OpenTitan's `regtool` |
| `sw/common/` | Startup code, linker script, helper functions | Adapted from the Ibex `simple_system` example (vector table and build flow modified) |
| `scripts/` | `build.sh`, `regress.sh`, `run.sh` | Own work |
| `ip/` | GPIO and PLIC IP, including their docs and OpenTitan's own DV environments | **Generated from OpenTitan** with `ipgen` from the configurations in `ip/cfg/`. Not my work; OpenTitan's DV code under `ip/*/dv/` is not used by this testbench |

Ibex and OpenTitan are developed by lowRISC and contributors, and are licensed under Apache 2.0.

## SoC overview

```
Ibex (RV32IMC) ── instruction port ─────────────────────────────→ RAM
       └──────── data port → TL-UL host adapter → TL-UL socket (1:6)
                   ├─ UART       0x0000_1000
                   ├─ GPIO       0x0000_2000
                   ├─ SimCtrl    0x0002_0000
                   ├─ Timer      0x0003_0000
                   ├─ RAM        0x0010_0000
                   └─ PLIC       0x1000_0000
```

Unmapped addresses return a bus error. Interrupt sources: 1–9 UART, 10–41 GPIO pins 0–31.

## Requirements

- Verilator 5.x, with `--timing` support
- Accellera `uvm-core`, cloned to `~/uvm-core`
- FuseSoC, and an OpenTitan checkout at `~/opentitan` (for the Ibex and peripheral cores)
- `riscv64-unknown-elf-gcc`

The scripts currently assume this repository is at `~/soc-dv`.

## Running

```bash
# 1. Lint the RTL with FuseSoC, and regenerate the Verilator file list (build/tb.vc)
fusesoc --cores-root=$HOME/opentitan --cores-root=$HOME/soc-dv \
        run --target=lint bhanu:soc:soc_top

# 2. Build the C tests
for t in sw/tests/*/; do make -C "$t"; done

# 3. Build the simulator and run the regression
scripts/regress.sh
```

## Tests

| Test | Checks |
|---|---|
| `hello_test` | Basic execution; bus monitor vs. simulator log |
| `unmapped_test` | Store to an unmapped address raises a store access fault |
| `uart_test` | UART data path through internal loopback |
| `uart_tx_test` | Bytes written by firmware appear on the TX pin (UART scoreboard) |
| `uart_echo_test` | Random bytes driven on RX are echoed back on TX (end-to-end) |
| `gpio_test` | GPIO outputs, output enables, masked writes (loopback) |
| `gpio_in_test` | Random input edges → GPIO interrupts → firmware reflects inputs on outputs |
| `plic_test` | Interrupt claim/complete flow through the PLIC |
| `soc_concurrent_test` | UART and GPIO stimulus at the same time via a virtual sequence; one interrupt handler services both |

## Status

All 9 tests pass. In progress: UVM register models (RAL), functional coverage and closure.
