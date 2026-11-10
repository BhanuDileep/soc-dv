class soc_env extends uvm_env;
`uvm_component_utils(soc_env)

dbus_monitor dbus_mon;
uart_agent uart_agt;
gpio_agent gpio_agt;
uart_scoreboard uart_scb;
gpio_scoreboard gpio_scb;
soc_vsequencer vsqr;
soc_scoreboard scb;
// Register model for UART, kept up to date by observing the bus
uart_reg_block                uart_ral;
dbus_reg_adapter              reg_adapter;
uvm_reg_predictor #(dbus_item) uart_pred;

function new(string name = "soc_env", uvm_component parent = null);
    super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    dbus_mon = dbus_monitor::type_id::create("dbus_mon", this);
    uart_agt = uart_agent::type_id::create("uart_agt", this);
    gpio_agt = gpio_agent::type_id::create("gpio_agt", this);
    uart_scb = uart_scoreboard::type_id::create("uart_scb", this);
    gpio_scb = gpio_scoreboard::type_id::create("gpio_scb", this);
    vsqr = soc_vsequencer::type_id::create("vsqr", this);
    scb = soc_scoreboard::type_id::create("scb", this);
    // The register block is an OBJECT, not a component: no parent argument
    uart_ral = uart_reg_block::type_id::create("uart_ral");
    uart_ral.build(.base_addr  (uvm_reg_addr_t'(32'h0000_1000)),  // must match soc_addr_decode.sv
                .csr_excl   (null),   // OpenTitan's exclusion list for its own CSR tests: unused here
                .addr_width (32),     // your bus: 32-bit addresses
                .data_width (32),     //           32-bit data
                .be_width   (4));     //           one byte enable per data byte      // must match UART's base in soc_addr_decode.sv
    uart_ral.lock_model();                // finalize the map, so registers can be found by address
    uart_ral.reset();                     // mirror = reset values, matching the hardware after reset
    //void'(uart_ral.ctrl.predict(32'h1234_5678));   // TEMPORARY: a deliberately wrong mirror
    uart_ral.default_map.set_check_on_read(1);   // the predictor compares every observed read

    reg_adapter = dbus_reg_adapter::type_id::create("reg_adapter");
    uart_pred   = uvm_reg_predictor #(dbus_item)::type_id::create("uart_pred", this);
endfunction

function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dbus_mon.ap.connect(scb.a_imp);
    dbus_mon.ap.connect(uart_scb.dbus_imp);
    uart_agt.tx_mon.ap.connect(uart_scb.uart_imp);
    uart_agt.rx_mon.ap.connect(uart_scb.rx_imp);      // 4.4b: bytes driven into RX\
    gpio_agt.gpio_mon.ap.connect(gpio_scb.analysis_export);
    vsqr.uart_sqr = uart_agt.sqr;
    vsqr.gpio_sqr = gpio_agt.sqr;
    uart_pred.map     = uart_ral.default_map;   // where the registers are
    uart_pred.adapter = reg_adapter;            // how to read a dbus_item
    dbus_mon.ap.connect(uart_pred.bus_in);      // every bus transaction goes to the predictor
endfunction

endclass

