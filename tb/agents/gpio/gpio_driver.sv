class gpio_driver extends uvm_driver #(gpio_item);
    `uvm_component_utils(gpio_driver)

    virtual gpio_if gpio_vif;
    bit loopback = 1;            // default: behave like the old tb_top wire

    function new(string name = "gpio_driver", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual gpio_if)::get(this, "", "gpio_vif", gpio_vif)) `uvm_fatal("GPIO_DRV", $sformatf("Couldnt Find the GPIO Virtual Interface Handle"))
        void'(uvm_config_db #(bit)::get(this, "", "loopback", loopback));
        `uvm_info("GPIO_DRV", $sformatf("Mode %s", loopback ? "LOOPBACK" : "DRIVE"), UVM_LOW)
    endfunction

    task run_phase(uvm_phase phase);
        gpio_vif.gpio_i = '0;
        if(loopback) begin
            gpio_vif.gpio_i = gpio_vif.gpio_o & gpio_vif.gpio_oe;      // copy once at the start
            forever begin
                @(gpio_vif.gpio_o or gpio_vif.gpio_oe);                  // wait for either to change
                gpio_vif.gpio_i = gpio_vif.gpio_o & gpio_vif.gpio_oe;    // then copy
            end
        end
        else begin
            forever begin
                seq_item_port.get_next_item(req);
                #(req.delay_ns * 1ns);
                gpio_vif.gpio_i <= req.gpio_i;
                `uvm_info("GPIO_DRV", req.convert2string(), UVM_HIGH)
                seq_item_port.item_done(req);
            end
        end
    endtask
endclass