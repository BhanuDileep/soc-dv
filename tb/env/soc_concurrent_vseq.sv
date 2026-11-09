// Virtual sequence: UART bytes and GPIO patterns at the same time.
// It drives nothing itself: it starts the agents' own sequences on their
// sequencers, reached through the virtual sequencer's handles.
class soc_concurrent_vseq extends uvm_sequence;
  `uvm_object_utils(soc_concurrent_vseq)
  `uvm_declare_p_sequencer(soc_vsequencer)

  function new(string name = "soc_concurrent_vseq");
    super.new(name);
  endfunction

  task body();
    uart_rx_seq uart_seq;
    gpio_in_seq gpio_seq;

    uart_seq = uart_rx_seq::type_id::create("uart_seq");
    gpio_seq = gpio_in_seq::type_id::create("gpio_seq");
    if (!uart_seq.randomize()) `uvm_fatal("VSEQ", "uart_seq randomize() failed")
    if (!gpio_seq.randomize()) `uvm_fatal("VSEQ", "gpio_seq randomize() failed")

    `uvm_info("VSEQ", $sformatf("Starting %0d UART bytes and %0d GPIO patterns concurrently",
                                uart_seq.num_bytes, gpio_seq.n_inputs), UVM_LOW)

    // Both interfaces at once; the virtual sequence ends when BOTH have finished
    fork
      uart_seq.start(p_sequencer.uart_sqr, this);
      gpio_seq.start(p_sequencer.gpio_sqr, this);
    join
  endtask
endclass