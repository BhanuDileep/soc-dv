// Concurrent UART + GPIO test: once software has configured both devices,
// run the concurrent virtual sequence. Software services both through one
// interrupt handler; each scoreboard checks its own interface.
class soc_concurrent_test extends soc_base_test;
  `uvm_component_utils(soc_concurrent_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_db #(bit)::set(this, "env.gpio_agt.gpio_drv", "loopback",        0);  // GPIO: drive mode
    uvm_config_db #(bit)::set(this, "env.gpio_scb",          "check_gpio_echo", 1);  // GPIO check on
    uvm_config_db #(bit)::set(this, "env.uart_scb",          "check_echo",      1);  // UART echo check on
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    soc_concurrent_vseq vseq;
    phase.raise_objection(this);

    fork
      begin
        // HW/SW sync: GPIO INTR_ENABLE is software's LAST configuration write
        wait_for_store(GPIO_INTR_ENABLE);
        `uvm_info("TEST", "Software configured UART and GPIO: starting concurrent stimulus", UVM_LOW)

        vseq = soc_concurrent_vseq::type_id::create("vseq");
        vseq.start(env.vsqr);          // the VIRTUAL sequencer
      end
    join_none

    wait_for_halt();
    phase.drop_objection(this);
  endtask
endclass