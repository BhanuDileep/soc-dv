// Driver smoke test: drive a few random bytes on RX and let rx_mon decode them.
// The chip isn't involved (its receiver stays off). This checks driver + monitor alone.
class uart_drv_smoke_test extends soc_base_test;
  `uvm_component_utils(uart_drv_smoke_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    uart_rx_seq seq;
    phase.raise_objection(this);

    seq = uart_rx_seq::type_id::create("seq");
    // 4 bytes = 40 µs at 1 Mbaud: well inside hello_test's runtime
    if (!seq.randomize() with { num_bytes == 4; }) `uvm_error("TEST", "randomize() failed")
    seq.start(env.uart_agt.sqr);          // runs to completion: all 4 bytes driven

    wait_for_halt();                      // then end with the program, as usual
    phase.drop_objection(this);
  endtask
endclass