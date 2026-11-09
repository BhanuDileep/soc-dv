// UVM side of the echo test: once software enables UART's receiver,
// send random bytes into the RX pin. Software echoes each one back on TX,
// and the scoreboard checks bytes in == bytes out, in order.
class uart_echo_test extends soc_base_test;
  `uvm_component_utils(uart_echo_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Turn on the scoreboard's echo check BEFORE the env (and scoreboard) is built
  function void build_phase(uvm_phase phase);
    uvm_config_db #(bit)::set(this, "env.uart_scb", "check_echo", 1);
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    uart_rx_seq seq;
    phase.raise_objection(this);

    fork
      begin
        // HW/SW sync: don't send until software has enabled RX
        uvm_event_pool::get_global("uart_rx_ready").wait_trigger();
        `uvm_info("TEST", "Software enabled UART RX: starting RX sequence", UVM_LOW)

        seq = uart_rx_seq::type_id::create("seq");
        if (!seq.randomize()) `uvm_error("TEST", "Sequence randomize() failed")
        seq.start(env.uart_agt.sqr);
      end
    join_none                       // the sequence runs in the background...

    wait_for_halt();                // ...while the test waits for software to finish
    phase.drop_objection(this);
  endtask
endclass