// SoC top, step 3.3a: Ibex + TL-UL fabric + RAM, SimCtrl, Timer.
// UART (0), GPIO (1) and PLIC (5) slots answer with errors until step 3.3b.
module soc_top (
  input logic clk_i,
  input logic rst_ni,
  // UART pins
  input  logic        uart_rx_i,
  output logic        uart_tx_o,
  // GPIO pins
  input  logic [31:0] gpio_i,
  output logic [31:0] gpio_o,
  output logic [31:0] gpio_oe_o
);
  import tlul_pkg::*;

  localparam int NDev = 6;   // 0 UART, 1 GPIO, 2 SimCtrl, 3 Timer, 4 RAM, 5 PLIC

  // ------------------------------------------------------------------
  // Ibex core
  // ------------------------------------------------------------------
  logic        instr_req, instr_gnt, instr_rvalid, instr_err;
  logic [31:0] instr_addr, instr_rdata;

  logic        data_req, data_gnt, data_rvalid, data_we, data_err;
  logic [3:0]  data_be;
  logic [31:0] data_addr, data_wdata, data_rdata;

  logic        timer_irq;

    // ------------------------------------------------------------------
  // Interrupts: PLIC source map (part of the SoC specification)
  //   0      reserved ("no interrupt")
  //   1..9   UART, in uart.hjson interrupt_list order
  //   10..41 GPIO pins 0..31
  // ------------------------------------------------------------------
  logic intr_uart_tx_watermark, intr_uart_rx_watermark, intr_uart_tx_done,
        intr_uart_rx_overflow,  intr_uart_rx_frame_err, intr_uart_rx_break_err,
        intr_uart_rx_timeout,   intr_uart_rx_parity_err, intr_uart_tx_empty;
  logic [31:0] intr_gpio;
  logic [41:0] intr_src;
  logic        irq_external, irq_software;

  assign intr_src = {intr_gpio,                 // 41..10: GPIO pins 31..0
                     intr_uart_tx_empty,        // 9
                     intr_uart_rx_parity_err,   // 8
                     intr_uart_rx_timeout,      // 7
                     intr_uart_rx_break_err,    // 6
                     intr_uart_rx_frame_err,    // 5
                     intr_uart_rx_overflow,     // 4
                     intr_uart_tx_done,         // 3
                     intr_uart_rx_watermark,    // 2
                     intr_uart_tx_watermark,    // 1
                     1'b0};                     // 0: reserved

  ibex_top_tracing #(
    .RV32E            (1'b0),
    .RV32M            (ibex_pkg::RV32MFast),
    .RV32B            (ibex_pkg::RV32BNone),
    .RV32ZC           (ibex_pkg::RV32Zca),
    .RegFile          (ibex_pkg::RegFileFF),
    .PMPEnable        (1'b0),
    .MHPMCounterNum   (0),
    .MHPMCounterWidth (40),
    .ICache           (1'b0),
    .BranchPredictor  (1'b0),
    .WritebackStage   (1'b0),
    .BranchTargetALU  (1'b0),
    .DbgTriggerEn     (1'b0),
    .SecureIbex       (1'b0)
  ) u_core (
    .clk_i                  (clk_i),
    .rst_ni                 (rst_ni),
    .test_en_i              (1'b0),
    .scan_rst_ni            (1'b1),
    .ram_cfg_icache_tag_i   ('0),
    .ram_cfg_icache_tag_o   (),
    .ram_cfg_icache_data_i  ('0),
    .ram_cfg_icache_data_o  (),
    .trvk_heap_base_addr_i  ('0),
    .cheriot_enable_i       (ibex_pkg::IbexMuBiOff),
    .hart_id_i              (32'h0),
    .boot_addr_i            (32'h0010_0000),   // core starts at boot_addr + 0x80

    // Instruction port -> RAM port B
    .instr_req_o            (instr_req),
    .instr_gnt_i            (instr_gnt),
    .instr_rvalid_i         (instr_rvalid),
    .instr_addr_o           (instr_addr),
    .instr_rdata_i          (instr_rdata),
    .instr_rdata_intg_i     ('0),
    .instr_err_i            (instr_err),

    // Data port -> TL-UL host adapter
    .data_req_o             (data_req),
    .data_gnt_i             (data_gnt),
    .data_rvalid_i          (data_rvalid),
    .data_we_o              (data_we),
    .data_be_o              (data_be),
    .data_addr_o            (data_addr),
    .data_wdata_o           (data_wdata),
    .data_wdata_intg_o      (),
    .data_tag_o             (),
    .data_rdata_i           (data_rdata),
    .data_rdata_intg_i      ('0),
    .data_tag_i             (1'b0),
    .data_err_i             (data_err),

    // CHERIoT revocation bus: unused
    .trvk_revbm_req_o       (),
    .trvk_revbm_gnt_i       (1'b0),
    .trvk_revbm_rvalid_i    (1'b0),
    .trvk_revbm_addr_o      (),
    .trvk_revbm_rdata_i     ('0),
    .trvk_revbm_rdata_intg_i('0),
    .trvk_revbm_err_i       (1'b0),

    // Interrupts
    .irq_software_i         (irq_software),
    .irq_timer_i            (timer_irq),
    .irq_external_i         (irq_external),    // PLIC in step 3.3b
    .irq_fast_i             ('0),
    .irq_nm_i               (1'b0),

    // Icache scrambling: unused
    .scramble_key_valid_i   (1'b0),
    .scramble_key_i         ('0),
    .scramble_nonce_i       ('0),
    .scramble_req_o         (),

    // Debug: unused
    .debug_req_i            (1'b0),
    .crash_dump_o           (),
    .double_fault_seen_o    (),

    // Control
    .fetch_enable_i         (ibex_pkg::IbexMuBiOn),   // MUST be On, or the core never fetches
    .mcounteren_writable_i  (ibex_pkg::IbexMuBiOff),
    .alert_minor_o          (),
    .alert_major_internal_o (),
    .alert_major_bus_o      (),
    .core_sleep_o           (),
    .lockstep_cmp_en_o      (),

    // Shadow-core outputs: unused
    .data_req_shadow_o        (),
    .data_we_shadow_o         (),
    .data_be_shadow_o         (),
    .data_addr_shadow_o       (),
    .data_wdata_shadow_o      (),
    .data_wdata_intg_shadow_o (),
    .instr_req_shadow_o       (),
    .instr_addr_shadow_o      ()
  );

  // ------------------------------------------------------------------
  // Instruction port: always granted, data one cycle later, never errors
  // ------------------------------------------------------------------
  assign instr_gnt = instr_req;
  assign instr_err = 1'b0;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) instr_rvalid <= 1'b0;
    else         instr_rvalid <= instr_req;
  end

  // ------------------------------------------------------------------
  // Data port -> TL-UL
  // ------------------------------------------------------------------
  tl_h2d_t tl_core_h2d;
  tl_d2h_t tl_core_d2h;

  tlul_adapter_host #(
    .MAX_REQS (2),
    .EnableDataIntgGen (1) // enable data integrity generation
  ) u_host_adapter (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .req_i        (data_req),
    .gnt_o        (data_gnt),
    .addr_i       (data_addr),
    .we_i         (data_we),
    .wdata_i      (data_wdata),
    .wdata_intg_i ('0),
    .be_i         (data_be),
    .instr_type_i (prim_mubi_pkg::MuBi4False),   // data accesses, not fetches
    .user_rsvd_i  ('0),
    .valid_o      (data_rvalid),
    .rdata_o      (data_rdata),
    .rdata_intg_o (),
    .err_o        (data_err),
    .intg_err_o   (),
    .tl_o         (tl_core_h2d),
    .tl_i         (tl_core_d2h)
  );

  // ------------------------------------------------------------------
  // Address decode + socket
  // ------------------------------------------------------------------
  logic [2:0] dev_sel;

  soc_addr_decode u_decode (
    .addr_i    (tl_core_h2d.a_address),
    .dev_sel_o (dev_sel)
  );

  tl_h2d_t tl_dev_h2d [NDev];
  tl_d2h_t tl_dev_d2h [NDev];

  tlul_socket_1n #(
    .N (NDev)
  ) u_socket (
    .clk_i        (clk_i),
    .rst_ni       (rst_ni),
    .tl_h_i       (tl_core_h2d),
    .tl_h_o       (tl_core_d2h),
    .tl_d_o       (tl_dev_h2d),
    .tl_d_i       (tl_dev_d2h),
    .dev_select_i (dev_sel)
  );

    // ------------------------------------------------------------------
  // Slot 0: UART
  // ------------------------------------------------------------------
  uart u_uart (
    .clk_i                 (clk_i),
    .rst_ni                (rst_ni),
    .tl_i                  (tl_dev_h2d[0]),
    .tl_o                  (tl_dev_d2h[0]),
    .alert_rx_i            ({uart_reg_pkg::NumAlerts{prim_alert_pkg::ALERT_RX_DEFAULT}}),
    .alert_tx_o            (),
    .racl_policies_i       ('0),          // RACL disabled (EnableRacl = 0)
    .racl_error_o          (),
    .lsio_trigger_o        (),
    .cio_rx_i              (uart_rx_i),
    .cio_tx_o              (uart_tx_o),
    .cio_tx_en_o           (),
    .intr_tx_watermark_o   (intr_uart_tx_watermark),
    .intr_tx_empty_o       (intr_uart_tx_empty),
    .intr_rx_watermark_o   (intr_uart_rx_watermark),
    .intr_tx_done_o        (intr_uart_tx_done),
    .intr_rx_overflow_o    (intr_uart_rx_overflow),
    .intr_rx_frame_err_o   (intr_uart_rx_frame_err),
    .intr_rx_break_err_o   (intr_uart_rx_break_err),
    .intr_rx_timeout_o     (intr_uart_rx_timeout),
    .intr_rx_parity_err_o  (intr_uart_rx_parity_err)
  );

  // ------------------------------------------------------------------
  // Slot 1: GPIO
  // ------------------------------------------------------------------
  gpio u_gpio (
    .clk_i            (clk_i),
    .rst_ni           (rst_ni),
    .strap_en_i       (1'b0),              // no boot straps
    .sampled_straps_o (),
    .tl_i             (tl_dev_h2d[1]),
    .tl_o             (tl_dev_d2h[1]),
    .intr_gpio_o      (intr_gpio),
    .alert_rx_i       ({gpio_reg_pkg::NumAlerts{prim_alert_pkg::ALERT_RX_DEFAULT}}),
    .alert_tx_o       (),
    .racl_policies_i  ('0),
    .racl_error_o     (),
    .cio_gpio_i       (gpio_i),
    .cio_gpio_o       (gpio_o),
    .cio_gpio_en_o    (gpio_oe_o)
  );

  // ------------------------------------------------------------------
  // Slot 5: PLIC
  // ------------------------------------------------------------------
  rv_plic u_plic (
    .clk_i      (clk_i),
    .rst_ni     (rst_ni),
    .tl_i       (tl_dev_h2d[5]),
    .tl_o       (tl_dev_d2h[5]),
    .intr_src_i (intr_src),
    .alert_rx_i ({rv_plic_reg_pkg::NumAlerts{prim_alert_pkg::ALERT_RX_DEFAULT}}),
    .alert_tx_o (),
    .irq_o      (irq_external),
    .irq_id_o   (),
    .msip_o     (irq_software)
  );


  // ------------------------------------------------------------------
  // Slot 2: SimCtrl (1 KB -> 8-bit word address)
  // ------------------------------------------------------------------
  logic        sim_req, sim_we, sim_rd_q;
  logic [7:0]  sim_addr;
  logic [31:0] sim_wdata, sim_wmask, sim_rdata;

  tlul_adapter_sram #(
    .SramAw           (8),
    .SramDw           (32),
    .Outstanding      (1),
    .ByteAccess       (1),
    .EnableRspIntgGen (1)
  ) u_sim_adapter (
    .clk_i                      (clk_i),
    .rst_ni                     (rst_ni),
    .tl_i                       (tl_dev_h2d[2]),
    .tl_o                       (tl_dev_d2h[2]),
    .en_ifetch_i                (prim_mubi_pkg::MuBi4False),
    .req_o                      (sim_req),
    .req_type_o                 (),
    .gnt_i                      (1'b1),
    .we_o                       (sim_we),
    .addr_o                     (sim_addr),
    .wdata_o                    (sim_wdata),
    .wmask_o                    (sim_wmask),
    .intg_error_o               (),
    .user_rsvd_o                (),
    .rdata_i                    (sim_rdata),
    .rvalid_i                   (sim_rd_q),        // reads only
    .rerror_i                   (2'b00),
    .compound_txn_in_progress_o (),
    .readback_en_i              (prim_mubi_pkg::MuBi4False),
    .readback_error_o           (),
    .wr_collision_i             (1'b0),
    .write_pending_i            (1'b0)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) sim_rd_q <= 1'b0;
    else         sim_rd_q <= sim_req & ~sim_we;
  end

  simulator_ctrl #(
    .LogName ("ibex_simple_system.log")
  ) u_simulator_ctrl (
    .clk_i    (clk_i),
    .rst_ni   (rst_ni),
    .req_i    (sim_req),
    .we_i     (sim_we),
    .be_i     ({sim_wmask[24], sim_wmask[16], sim_wmask[8], sim_wmask[0]}),
    .addr_i   ({22'b0, sim_addr, 2'b00}),       // word -> byte address
    .wdata_i  (sim_wdata),
    .rvalid_o (),                               // replaced by sim_rd_q
    .rdata_o  (sim_rdata)
  );

  // ------------------------------------------------------------------
  // Slot 3: Timer (1 KB -> 8-bit word address)
  // ------------------------------------------------------------------
  logic        tmr_req, tmr_we, tmr_rd_q;
  logic [7:0]  tmr_addr;
  logic [31:0] tmr_wdata, tmr_wmask, tmr_rdata;

  tlul_adapter_sram #(
    .SramAw      (8),
    .SramDw      (32),
    .Outstanding (1),
    .ByteAccess  (1),
    .EnableRspIntgGen (1)
  ) u_tmr_adapter (
    .clk_i                      (clk_i),
    .rst_ni                     (rst_ni),
    .tl_i                       (tl_dev_h2d[3]),
    .tl_o                       (tl_dev_d2h[3]),
    .en_ifetch_i                (prim_mubi_pkg::MuBi4False),
    .req_o                      (tmr_req),
    .req_type_o                 (),
    .gnt_i                      (1'b1),
    .we_o                       (tmr_we),
    .addr_o                     (tmr_addr),
    .wdata_o                    (tmr_wdata),
    .wmask_o                    (tmr_wmask),
    .intg_error_o               (),
    .user_rsvd_o                (),
    .rdata_i                    (tmr_rdata),
    .rvalid_i                   (tmr_rd_q),        // reads only
    .rerror_i                   (2'b00),
    .compound_txn_in_progress_o (),
    .readback_en_i              (prim_mubi_pkg::MuBi4False),
    .readback_error_o           (),
    .wr_collision_i             (1'b0),
    .write_pending_i            (1'b0)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) tmr_rd_q <= 1'b0;
    else         tmr_rd_q <= tmr_req & ~tmr_we;
  end

  timer #(
    .DataWidth    (32),
    .AddressWidth (32)
  ) u_timer (
    .clk_i          (clk_i),
    .rst_ni         (rst_ni),
    .timer_req_i    (tmr_req),
    .timer_addr_i   ({22'b0, tmr_addr, 2'b00}), // word -> byte address
    .timer_we_i     (tmr_we),
    .timer_be_i     ({tmr_wmask[24], tmr_wmask[16], tmr_wmask[8], tmr_wmask[0]}),
    .timer_wdata_i  (tmr_wdata),
    .timer_rvalid_o (),                         // replaced by tmr_rd_q
    .timer_rdata_o  (tmr_rdata),
    .timer_err_o    (),
    .timer_intr_o   (timer_irq)
  );

  // ------------------------------------------------------------------
  // Slot 4: RAM port A (1 MB -> 18-bit word address); port B = instruction fetch
  // ------------------------------------------------------------------
  logic        ram_req, ram_we, ram_rd_q;
  logic [17:0] ram_addr;
  logic [31:0] ram_wdata, ram_wmask, ram_rdata;

  tlul_adapter_sram #(
    .SramAw      (18),
    .SramDw      (32),
    .Outstanding (1),
    .ByteAccess  (1),
    .EnableRspIntgGen (1)
  ) u_ram_adapter (
    .clk_i                      (clk_i),
    .rst_ni                     (rst_ni),
    .tl_i                       (tl_dev_h2d[4]),
    .tl_o                       (tl_dev_d2h[4]),
    .en_ifetch_i                (prim_mubi_pkg::MuBi4False),
    .req_o                      (ram_req),
    .req_type_o                 (),
    .gnt_i                      (1'b1),
    .we_o                       (ram_we),
    .addr_o                     (ram_addr),
    .wdata_o                    (ram_wdata),
    .wmask_o                    (ram_wmask),
    .intg_error_o               (),
    .user_rsvd_o                (),
    .rdata_i                    (ram_rdata),
    .rvalid_i                   (ram_rd_q),        // reads only
    .rerror_i                   (2'b00),
    .compound_txn_in_progress_o (),
    .readback_en_i              (prim_mubi_pkg::MuBi4False),
    .readback_error_o           (),
    .wr_collision_i             (1'b0),
    .write_pending_i            (1'b0)
  );

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) ram_rd_q <= 1'b0;
    else         ram_rd_q <= ram_req & ~ram_we;
  end

  soc_ram_2p #(
    .Depth (262144)
  ) u_ram (
    .clk_i     (clk_i),
    .a_req_i   (ram_req),
    .a_we_i    (ram_we),
    .a_be_i    ({ram_wmask[24], ram_wmask[16], ram_wmask[8], ram_wmask[0]}),
    .a_addr_i  (ram_addr),
    .a_wdata_i (ram_wdata),
    .a_rdata_o (ram_rdata),
    .b_req_i   (instr_req),
    .b_addr_i  (instr_addr[19:2]),              // byte -> word address, offset within RAM
    .b_rdata_o (instr_rdata)
  );

endmodule
