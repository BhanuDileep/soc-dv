class uart_agent extends uvm_agent;
  `uvm_component_utils(uart_agent)

  uart_monitor   tx_mon;   // what the chip transmits
  uart_monitor   rx_mon;   // what was driven into the chip
  uart_driver    drv;
  uart_sequencer sqr;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    tx_mon = uart_monitor::type_id::create("tx_mon", this);
    rx_mon = uart_monitor::type_id::create("rx_mon", this);
    rx_mon.watch_rx = 1;

    // Active agent: also drive. Passive agent: only observe.
    if (get_is_active() == UVM_ACTIVE) begin
      drv = uart_driver::type_id::create("drv", this);
      sqr = uart_sequencer::type_id::create("sqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (get_is_active() == UVM_ACTIVE)
      drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass