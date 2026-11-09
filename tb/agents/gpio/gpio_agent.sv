class gpio_agent extends uvm_agent;
    `uvm_component_utils(gpio_agent)

    gpio_driver gpio_drv;
    gpio_monitor gpio_mon;
    gpio_sequencer sqr;

    function new(string name = "gpio_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
            gpio_drv = gpio_driver::type_id::create("gpio_drv", this);
            sqr = gpio_sequencer::type_id::create("sqr", this);
        end
        gpio_mon = gpio_monitor::type_id::create("gpio_mon", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        if(get_is_active() == UVM_ACTIVE) begin
            gpio_drv.seq_item_port.connect(sqr.seq_item_export);
        end
    endfunction
endclass