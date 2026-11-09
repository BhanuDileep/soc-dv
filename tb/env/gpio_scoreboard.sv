class gpio_scoreboard extends uvm_subscriber #(gpio_item);
    `uvm_component_utils(gpio_scoreboard)

    bit check_gpio_echo;
    logic[15:0] pending[$];
    logic[15:0] last_out;
    int matched, errors;

    function new(string name = "gpio_scoreboard", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        void'(uvm_config_db #(bit)::get(this, "", "check_gpio_echo", check_gpio_echo));
        if(check_gpio_echo) `uvm_info("GPIO_SCO", $sformatf("GPIO CHECK ENABLED"), UVM_LOW)
        else `uvm_info("GPIO_SCB", $sformatf("GPIO CHECK DISABLED"), UVM_LOW);
    endfunction

    function void write(gpio_item t);
        logic [15:0] new_out;
        logic [15:0] exp;
        if (!check_gpio_echo) return;            // only checks in the GPIO input test

        // ---- Rule 1: an input change becomes the pattern we now expect on the outputs ----
        if(t.in_changed) begin
            if(pending.size() != 0) begin
                `uvm_error("GPIO_SCB", $sformatf("Input pattern 0x%04h was never reflected before the next input 0x%04h",
                                         pending[0], t.gpio_i[15:0]))
                errors++;
                pending.delete();
            end
            pending.push_back(t.gpio_i[15:0]);
        end

        // ---- Rule 2: an output VALUE change must reflect the pending pattern ----
        new_out = t.gpio_o[31:16];
        if (new_out !== last_out) begin
            last_out = new_out;                    // remember it, whatever the verdict
            if (pending.size() == 0) begin
                `uvm_error("GPIO_SCB", $sformatf("Outputs changed to 0x%04h with no input change to reflect", new_out))
                errors++;
            end
            else begin
                exp = pending.pop_front();
                if (new_out !== exp) begin
                    `uvm_error("GPIO_SCB", $sformatf("Outputs 0x%04h don't match inputs 0x%04h", new_out, exp))
                    errors++;
                end
                else
                    matched++;
            end
        end
    endfunction

    function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        if (!check_gpio_echo) return;

        if (pending.size() != 0) begin
            `uvm_error("GPIO_SCB", $sformatf("Last input pattern 0x%04h was never reflected", pending[0]))
            errors++;
        end

        if (errors == 0)
            `uvm_info("GPIO_SCB", $sformatf("GPIO echo: all %0d input patterns reflected", matched), UVM_LOW)
    endfunction

endclass