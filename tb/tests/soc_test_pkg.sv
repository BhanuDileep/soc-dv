package soc_test_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import soc_env_pkg::*;
  import soc_env_pkg::*;
  import uart_pkg::*;
  import gpio_pakg::*;
  `include "soc_base_test.sv"
  `include "soc_concurrent_test.sv"
  `include "uart_drv_smoke_test.sv"  
  `include "uart_echo_test.sv"
  `include "gpio_in_test.sv"
endpackage