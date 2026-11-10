#!/bin/bash
# Regenerate the UVM register models from the IPs' .hjson descriptions,
# with the same OpenTitan regtool that generated the RTL registers and C headers.
set -e
REGTOOL=$HOME/opentitan/util/regtool.py
OUT=$HOME/soc-dv/tb/ral/gen
mkdir -p $OUT

$REGTOOL -s -t $OUT $HOME/opentitan/hw/ip/uart/data/uart.hjson    # UART: OpenTitan's own, not reconfigured
$REGTOOL -s -t $OUT $HOME/soc-dv/ip/gpio/data/gpio.hjson          # GPIO: your ipgen configuration
$REGTOOL -s -t $OUT $HOME/soc-dv/ip/rv_plic/data/rv_plic.hjson    # PLIC: your ipgen configuration

# The generator writes a .core per model, named in OpenTitan's namespace.
# Remove them: tb/ral/*.core (outside gen/) are the ones FuseSoC should use.
rm -f $OUT/*.core
echo "RAL models generated in $OUT"
