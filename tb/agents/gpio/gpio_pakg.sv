package gpio_pakg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "gpio_item"
    `include "gpio_in_seq"
    `include "gpio_monitor"
    `include "gpio_driver"
    typedef uvm_sequencer #(gpio_item) gpio_sequencer;
    `include "gpio_agent"
endpackage