class gpio_monitor extends uvm_monitor;
    `uvm_component_utils(gpio_monitor)

    uvm_analysis_port #(gpio_item) ap;
    virtual gpio_if gpio_vif;
    gpio_item item;
    logic[31:0] gpio_old_o, gpio_old_oe, gpio_old_i;
    bit in_changed;     // set by the monitor: gpio_i differs from the previous edge
    bit out_changed;    // set by the monitor: gpio_o or gpio_oe differs from the previous edge

    function new(string name = "gpio_monitor", uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual gpio_if)::get(this, "", "gpio_vif", gpio_vif)) `uvm_fatal("GPIO_MON", $sformatf("Couldnt find the interface handle"))
    endfunction

      task run_phase(uvm_phase phase);
        // The starting state: the first comparison is against real values
        @(posedge gpio_vif.clk);
        gpio_old_o  = gpio_vif.gpio_o;
        gpio_old_oe = gpio_vif.gpio_oe;
        gpio_old_i  = gpio_vif.gpio_i;

        forever begin
            @(posedge gpio_vif.clk);
            if (gpio_vif.gpio_o !== gpio_old_o || gpio_vif.gpio_oe !== gpio_old_oe || gpio_vif.gpio_i !== gpio_old_i) begin
                item = gpio_item::type_id::create("item");
                item.gpio_i  = gpio_vif.gpio_i;
                item.gpio_o  = gpio_vif.gpio_o;
                item.gpio_oe = gpio_vif.gpio_oe;
                `uvm_info("GPIO_MON", item.convert2string(), UVM_MEDIUM)
                item.in_changed  = (gpio_vif.gpio_i  !== gpio_old_i);
                item.out_changed = (gpio_vif.gpio_o  !== gpio_old_o) || (gpio_vif.gpio_oe !== gpio_old_oe);
                ap.write(item);
            end
            gpio_old_o  = gpio_vif.gpio_o;     // remember for the next edge
            gpio_old_oe = gpio_vif.gpio_oe;
            gpio_old_i  = gpio_vif.gpio_i;
        end
  endtask
endclass