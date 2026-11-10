package soc_env_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import dbus_pkg::*;
  import gpio_pakg::*;
  import soc_ral_pkg::*;

  `include "soc_scoreboard.sv"
  `include "uart_scoreboard.sv"
  `include "gpio_scoreboard.sv"
  `include "soc_vsequencer.sv"
  `include "soc_concurrent_vseq.sv"
  `include "soc_env.sv"
  import uart_pkg::*;
endpackage