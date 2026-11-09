module tb_top;

import uvm_pkg::*;
`include "uvm_macros.svh"
import soc_test_pkg::*; 

localparam RST_CYCLES = 10;
localparam CLK_PERRIOD = 10;
localparam TIMEOUT_CYCLES = 1_000_000;

logic clk;
logic rst_n;

ib_dbus_if dbus_if(.clk(clk), .rst_n(rst_n));
uart_if u_uart_if();
gpio_if g_gpio_if(.clk(clk));

//initial u_uart_if.rx = 1'b1;          // RX idles high until the UART driver exists (step 4.3)

initial begin
  uvm_config_db #(virtual ib_dbus_if)::set(null, "uvm_test_top*", "vif",        dbus_if);
  uvm_config_db #(virtual uart_if)   ::set(null, "uvm_test_top*", "uart_vif",   u_uart_if);
  uvm_config_db #(time)              ::set(null, "uvm_test_top*", "bit_period", 1000ns);
  uvm_config_db #(virtual gpio_if)   ::set(null, "uvm_test_top*", "gpio_vif",   g_gpio_if);
  run_test("soc_base_test");
end

initial begin
    clk = 1'b0;
end

always #(CLK_PERRIOD/2) clk = ~clk;

initial begin
    rst_n = 1'b1;
    #1 rst_n = 1'b0;
    repeat(RST_CYCLES) @(posedge clk);
    @(negedge clk);
    rst_n = 1'b1;
end

soc_top dut (
    .clk_i     (clk),
    .rst_ni    (rst_n),
    .uart_rx_i (u_uart_if.rx),     // idle high
    .uart_tx_o (u_uart_if.tx),
    .gpio_i    (g_gpio_if.gpio_i), 
    .gpio_o    (g_gpio_if.gpio_o),
    .gpio_oe_o (g_gpio_if.gpio_oe)
);
//ibex_simple_system#(.SRAMInitFile("/Users/bhanudileepreddymaryada/ibex/examples/sw/simple_system/hello_test/hello_test.vmem")) dut(.IO_CLK(clk), .IO_RST_N(rst_n));

  // Program loading: backdoor-load the .vmem given on the command line
  initial begin
    string vmem_path;
    if ($value$plusargs("vmem=%s", vmem_path)) begin
      $display("TB: loading program %s", vmem_path);
      $readmemh(vmem_path, dut.u_ram.mem);
    end else begin
      $display("ERROR: no program given. Run with +vmem=<path to .vmem>");
      $finish;
    end
  end


assign dbus_if.req = dut.u_core.data_req_o;
assign dbus_if.gnt = dut.u_core.data_gnt_i;
assign dbus_if.we = dut.u_core.data_we_o;
assign dbus_if.rvalid = dut.u_core.data_rvalid_i;
assign dbus_if.err = dut.u_core.data_err_i;
assign dbus_if.be = dut.u_core.data_be_o;
assign dbus_if.addr = dut.u_core.data_addr_o;
assign dbus_if.wdata = dut.u_core.data_wdata_o;
assign dbus_if.rdata = dut.u_core.data_rdata_i;


initial begin
    repeat(TIMEOUT_CYCLES) @(posedge clk);
    $display("TIMEOUT: no $finish after %0d cycles", TIMEOUT_CYCLES);
    $finish;
end


initial begin
    $dumpfile("tb.fst");
    $dumpvars(0, tb_top);
end

endmodule
