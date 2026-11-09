// UART driver: plays an external device on the RX wire.
// For each item: start bit, 8 data bits (LSB first), stop bit, each one bit period long.
typedef uvm_sequencer #(uart_item) uart_sequencer;

class uart_driver extends uvm_driver #(uart_item);
  `uvm_component_utils(uart_driver)

  virtual uart_if vif;
  time bit_period;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual uart_if)::get(this, "", "uart_vif", vif))
      `uvm_fatal("UART_DRV", "No uart_if in config_db (key: uart_vif)")
    if (!uvm_config_db #(time)::get(this, "", "bit_period", bit_period))
      `uvm_fatal("UART_DRV", "No bit_period in config_db")
  endfunction

  task run_phase(uvm_phase phase);
    vif.rx = 1'b1;                          // idle until there is something to send
    #(10 * bit_period);         // hold idle for one full frame time before any traffic,
                                // like a real line after power-up, so receivers can synchronize

    forever begin
      seq_item_port.get_next_item(req);     // 1. wait for a byte; the line stays idle meanwhile

      vif.rx = 1'b0;                        // 2. start bit
      #(bit_period);

      for (int i = 0; i < 8; i++) begin     // 3. eight data bits, LSB first
        vif.rx = req.data[i];
        #(bit_period);
      end

      vif.rx = 1'b1;                        // 4. stop bit, which also leaves the line idle
      #(bit_period);

      `uvm_info("UART_DRV", $sformatf("Drove byte 0x%02h", req.data), UVM_HIGH)
      seq_item_port.item_done();            // 5. tell the sequence this byte is finished
    end
  endtask
endclass