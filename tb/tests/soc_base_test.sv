class soc_base_test extends uvm_test;
  `uvm_component_utils(soc_base_test)

  localparam logic [31:0] GPIO_INTR_ENABLE = 32'h0000_2000 + 32'(gpio_reg_pkg::GPIO_INTR_ENABLE_OFFSET);

  soc_env env;
  virtual ib_dbus_if vif;

  function new(string name = "soc_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = soc_env::type_id::create("env", this);
    if(!uvm_config_db #(virtual ib_dbus_if)::get(this, "", "vif", vif)) `uvm_fatal("TEST", $sformatf("Cannot find the interface. Terminaing the simulation"));
  endfunction

    // Wait until software requests a halt (store of 1 to SimCtrl's control register)
  task wait_for_halt();
    do @(posedge vif.clk);
    while (!(vif.req && vif.gnt && vif.we &&
             vif.addr == 32'h0002_0008 && vif.wdata[0]));
    @(posedge vif.clk); #1;
  endtask

  // Wait until the core issues a store to the given address
  task wait_for_store(logic [31:0] addr);
    do @(posedge vif.clk);
    while (!(vif.req && vif.gnt && vif.we && vif.addr == addr));
  endtask

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    `uvm_info("TEST", "Running the test", UVM_MEDIUM)
    wait_for_halt();
    `uvm_info("TEST", "Halting simulation (condition met)", UVM_MEDIUM)
    phase.drop_objection(this);
  endtask

  // task run_phase(uvm_phase phase);
  //   super.run_phase(phase);
  //   phase.raise_objection(this);
  //   `uvm_info("TEST", "Running the test", UVM_MEDIUM)
  //   do @(posedge vif.clk);
  //   while(!(vif.req && vif.gnt && vif.we && vif.addr == 32'h0002_0008 && vif.wdata[0]));
  //   @(posedge vif.clk) #1;
  //   `uvm_info("TEST", "Halting simulation(Conditon was met)", UVM_MEDIUM)
  //   phase.drop_objection(this);
  // endtask

endclass