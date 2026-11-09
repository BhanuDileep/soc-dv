// UART scoreboard with a small reference model of UART's configuration.
//  - TX check:   every byte written to WDATA appears on the TX pin, in order,
//                when TX is enabled and SLPBK is off.
//  - Echo check: (only when a test sets check_echo) every byte driven into RX
//                comes back out on TX, in order.
// Model assumption: UART's configuration doesn't change while bytes are in flight.

`uvm_analysis_imp_decl(_dbus)
`uvm_analysis_imp_decl(_uart)
`uvm_analysis_imp_decl(_rx)                                          // 4.4b

class uart_scoreboard extends uvm_scoreboard;
  `uvm_component_utils(uart_scoreboard)

  // Must match the UART base in rtl/soc_addr_decode.sv
  localparam logic [31:0] UART_BASE  = 32'h0000_1000;
  localparam logic [31:0] UART_CTRL  = UART_BASE + 32'(uart_reg_pkg::UART_CTRL_OFFSET);
  localparam logic [31:0] UART_WDATA = UART_BASE + 32'(uart_reg_pkg::UART_WDATA_OFFSET);

  uvm_analysis_imp_dbus #(dbus_item, uart_scoreboard) dbus_imp;
  uvm_analysis_imp_uart #(uart_item, uart_scoreboard) uart_imp;
  uvm_analysis_imp_rx   #(uart_item, uart_scoreboard) rx_imp;       // 4.4b

  // Reference model state
  bit tx_en;
  bit slpbk;

  logic [7:0] expected[$];    // TX check: bytes predicted on the TX pin
  int         matched;

  bit         check_echo;     // 4.4b: set by tests that expect software to echo RX
  logic [7:0] rx_bytes[$];    // 4.4b: bytes driven into RX, oldest first
  int         echoed;         // 4.4b

  function new(string name, uvm_component parent);
    super.new(name, parent);
    dbus_imp = new("dbus_imp", this);
    uart_imp = new("uart_imp", this);
    rx_imp   = new("rx_imp",   this);                               // 4.4b
  endfunction

  function void build_phase(uvm_phase phase);                       // 4.4b
    super.build_phase(phase);
    // Off unless a test turns it on; a missing setting simply means "off"
    void'(uvm_config_db #(bit)::get(this, "", "check_echo", check_echo));
    `uvm_info("UART_SCB", $sformatf("Echo check %s", check_echo ? "ENABLED" : "disabled"), UVM_LOW)
  endfunction

  // ---- From the bus monitor: update the model, make predictions ----
  function void write_dbus(dbus_item t);
    if (!t.we || t.err) return;

    if (t.addr == UART_CTRL) begin
      tx_en = t.wdata[0];                 // CTRL.TX    (bit 0)
      slpbk = t.wdata[4];                 // CTRL.SLPBK (bit 4)
      if (t.wdata[1])                     // CTRL.RX    (bit 1): software is ready to receive
        uvm_event_pool::get_global("uart_rx_ready").trigger();
      `uvm_info("UART_SCB", $sformatf("CTRL write: tx_en=%0d slpbk=%0d", tx_en, slpbk), UVM_HIGH)
    end
    else if (t.addr == UART_WDATA) begin
      if (tx_en && !slpbk)
        expected.push_back(t.wdata[7:0]);
    end
  endfunction

  // ---- 4.4b: from rx_mon, a byte was driven into the chip ----
  function void write_rx(uart_item t);
    if (check_echo) rx_bytes.push_back(t.data);
  endfunction

  // ---- From tx_mon: a byte appeared on the TX pin ----
  function void write_uart(uart_item t);
    logic [7:0] exp;

    // TX check
    if (expected.size() == 0)
      `uvm_error("UART_SCB", $sformatf("Unexpected byte on TX pin: 0x%02h (none was predicted)", t.data))
    else begin
      exp = expected.pop_front();
      if (t.data !== exp)
        `uvm_error("UART_SCB", $sformatf("TX byte mismatch: expected 0x%02h, got 0x%02h", exp, t.data))
      else
        matched++;
    end

    // 4.4b: echo check
    if (check_echo) begin
      if (rx_bytes.size() == 0)
        `uvm_error("UART_SCB", $sformatf("Echo: TX byte 0x%02h with no byte received to echo", t.data))
      else begin
        logic [7:0] rx_exp = rx_bytes.pop_front();
        if (t.data !== rx_exp)
          `uvm_error("UART_SCB", $sformatf("Echo mismatch: received 0x%02h, echoed 0x%02h", rx_exp, t.data))
        else
          echoed++;
      end
    end
  endfunction

  // ---- After the run ----
  function void check_phase(uvm_phase phase);
    super.check_phase(phase);

    if (expected.size() != 0)
      `uvm_error("UART_SCB", $sformatf("%0d byte(s) written to WDATA never appeared on TX; next expected 0x%02h",
                                       expected.size(), expected[0]))
    else
      `uvm_info("UART_SCB", $sformatf("All %0d TX bytes matched", matched), UVM_LOW)

    if (check_echo) begin                                            // 4.4b
      if (rx_bytes.size() != 0)
        `uvm_error("UART_SCB", $sformatf("Echo: %0d received byte(s) never echoed", rx_bytes.size()))
      else
        `uvm_info("UART_SCB", $sformatf("Echo: all %0d received bytes echoed correctly", echoed), UVM_LOW)
    end
  endfunction
endclass