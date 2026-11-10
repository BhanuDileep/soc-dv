class soc_env extends uvm_env;
`uvm_component_utils(soc_env)

dbus_monitor dbus_mon;
uart_agent uart_agt;
gpio_agent gpio_agt;
uart_scoreboard uart_scb;
gpio_scoreboard gpio_scb;
soc_vsequencer vsqr;
soc_scoreboard scb;
// Register model for the whole SoC, kept up to date by observing the bus
soc_reg_block                  soc_ral;
dbus_reg_adapter               reg_adapter;
uvm_reg_predictor #(dbus_item) reg_pred;

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
    soc_ral = soc_reg_block::type_id::create("soc_ral");
    soc_ral.build();                                // creates all three IP blocks at their bases
    soc_ral.lock_model();
    soc_ral.reset();
    soc_ral.default_map.set_check_on_read(1);      // plus each submap, if the grep shows no recursion

    reg_adapter = dbus_reg_adapter::type_id::create("reg_adapter");
    reg_pred    = uvm_reg_predictor #(dbus_item)::type_id::create("reg_pred", this);
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
    reg_pred.map     = soc_ral.default_map;    // the SoC's map: every register in the chip
    reg_pred.adapter = reg_adapter;            // the same adapter, unchanged
    dbus_mon.ap.connect(reg_pred.bus_in);
endfunction

endclass

