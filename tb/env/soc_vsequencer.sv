// Virtual sequencer: drives no items itself. It holds handles to the real
// sequencers, so a virtual sequence can coordinate stimulus across agents.
class soc_vsequencer extends uvm_sequencer;
  `uvm_component_utils(soc_vsequencer)

  uart_sequencer uart_sqr;    // set by the env in connect_phase
  gpio_sequencer gpio_sqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction
endclass