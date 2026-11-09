// UVM side of the GPIO input test: once software has enabled GPIO interrupts,
// drive random patterns on pins 0-15. Software reflects each on pins 16-31,
// and the GPIO scoreboard checks that the outputs follow the inputs.
class gpio_in_test extends soc_base_test;
  `uvm_component_utils(gpio_in_test)

  // Must match the GPIO base in rtl/soc_addr_decode.sv
//   localparam logic [31:0] GPIO_INTR_ENABLE = 32'h0000_2000 + 32'(gpio_reg_pkg::GPIO_INTR_ENABLE_OFFSET);

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_db #(bit)::set(this, "env.gpio_agt.gpio_drv", "loopback",        0);   // drive mode
    uvm_config_db #(bit)::set(this, "env.gpio_scb",          "check_gpio_echo", 1);   // turn the check on
    super.build_phase(phase);
  endfunction

  task run_phase(uvm_phase phase);
    gpio_in_seq seq;
    phase.raise_objection(this);

    fork
      begin
        // HW/SW sync: software's last configuration write enables GPIO interrupts
        wait_for_store(GPIO_INTR_ENABLE);
        `uvm_info("TEST", "Software enabled GPIO interrupts: starting input sequence", UVM_LOW)

        seq = gpio_in_seq::type_id::create("seq");
        if (!seq.randomize()) `uvm_error("TEST", "Sequence randomize() failed")
        seq.start(env.gpio_agt.sqr);
      end
    join_none

    wait_for_halt();
    phase.drop_objection(this);
  endtask
endclass