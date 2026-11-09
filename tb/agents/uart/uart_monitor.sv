class uart_monitor extends uvm_monitor;
  `uvm_component_utils(uart_monitor)

  virtual uart_if vif;
  uvm_analysis_port #(uart_item) ap;
  time bit_period;
  bit  watch_rx = 0;      // 0: watch tx (the chip's output); 1: watch rx (driven into the chip)

  function new(string name, uvm_component parent);
    super.new(name, parent);
    ap = new("ap", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", vif))
      `uvm_fatal("UART_MON", "No uart_if in config_db (key: uart_vif)")
    if (!uvm_config_db #(time)::get(this, "", "bit_period", bit_period))
      `uvm_fatal("UART_MON", "No bit_period in config_db")
  endfunction

  // ---- Helpers: the only places that know which wire is watched ----

  // Current level of the watched line, for sampling
  function logic line();
    return watch_rx ? vif.rx : vif.tx;
  endfunction

  // Wait for a falling edge on the watched line
  task wait_negedge();
    if (watch_rx) @(negedge vif.rx);
    else          @(negedge vif.tx);
  endtask

  // Wait until the watched line is high
  task wait_line_high();
    if (watch_rx) wait (vif.rx === 1'b1);
    else          wait (vif.tx === 1'b1);
  endtask

  // Return only after the line has stayed high for a full frame (10 bit periods)
  task wait_line_idle();
    forever begin
      wait_line_high();                     // ← was: wait (vif.tx === 1'b1)
      fork : idle_check
        #(10 * bit_period);
        wait_negedge();                     // ← was: @(negedge vif.tx)
      join_any
      disable idle_check;
      if (line() === 1'b1) return;          // ← was: vif.tx === 1'b1
    end
  endtask

  task run_phase(uvm_phase phase);
    uart_item item;

    wait_line_high();

    forever begin
      wait_negedge();                       // ← was: @(negedge vif.tx)

      #(bit_period / 2);
      if (line() !== 1'b0) begin            // ← was: vif.tx !== 1'b0
        `uvm_warning("UART_MON", "Start bit not low at mid-bit: glitch ignored")
        continue;
      end

      item = uart_item::type_id::create("item");
      for (int i = 0; i < 8; i++) begin
        #(bit_period);
        item.data[i] = line();              // ← was: vif.tx
      end

      #(bit_period);
      item.frame_err = (line() !== 1'b1);   // ← was: vif.tx !== 1'b1
      if (item.frame_err)
        `uvm_error("UART_MON", $sformatf("Framing error: %s", item.convert2string()))

      `uvm_info("UART_MON", item.convert2string(), UVM_MEDIUM)
      ap.write(item);

      if (item.frame_err) wait_line_idle();
    end
  endtask
endclass