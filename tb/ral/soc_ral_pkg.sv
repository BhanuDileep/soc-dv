// SoC-level register model: the three IP register blocks, placed at their base
// addresses in one map, so a single predictor covers every register in the chip.
package soc_ral_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import uart_ral_pkg::*;
  import gpio_ral_pkg::*;
  import rv_plic_ral_pkg::*;

  class soc_reg_block extends uvm_reg_block;
    `uvm_object_utils(soc_reg_block)

    // Base addresses: must match rtl/soc_addr_decode.sv
    localparam uvm_reg_addr_t UART_BASE    = 'h0000_1000;
    localparam uvm_reg_addr_t GPIO_BASE    = 'h0000_2000;
    localparam uvm_reg_addr_t RV_PLIC_BASE = 'h1000_0000;

    rand uart_reg_block    uart;
    rand gpio_reg_block    gpio;
    rand rv_plic_reg_block rv_plic;

    function new(string name = "soc_reg_block");
      super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void build();
      // The SoC's map: starts at 0, 4-byte bus, byte addresses
      default_map = create_map(.name("default_map"), .base_addr(0), .n_bytes(4),
                               .endian(UVM_LITTLE_ENDIAN), .byte_addressing(1));

      // Each sub-block: built at address 0, then placed at its base by add_submap
      uart = uart_reg_block::type_id::create("uart");
      uart.configure(.parent(this));
      uart.build(.base_addr(0), .csr_excl(null), .addr_width(32), .data_width(32), .be_width(4));
      default_map.add_submap(uart.default_map, UART_BASE);

      gpio = gpio_reg_block::type_id::create("gpio");
      gpio.configure(.parent(this));
      gpio.build(.base_addr(0), .csr_excl(null), .addr_width(32), .data_width(32), .be_width(4));
      default_map.add_submap(gpio.default_map, GPIO_BASE);

      rv_plic = rv_plic_reg_block::type_id::create("rv_plic");
      rv_plic.configure(.parent(this));
      rv_plic.build(.base_addr(0), .csr_excl(null), .addr_width(32), .data_width(32), .be_width(4));
      default_map.add_submap(rv_plic.default_map, RV_PLIC_BASE);
    endfunction
  endclass
endpackage