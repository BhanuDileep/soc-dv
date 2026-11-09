// Unit test for soc_addr_decode: every device's boundaries + unmapped addresses
module tb_addr_decode;
  logic [31:0] addr;
  logic [2:0]  dev_sel;
  int          errors = 0;
  int          checks = 0;

  soc_addr_decode u_dut (.addr_i(addr), .dev_sel_o(dev_sel));

  // Apply one address and compare the result against the expected index
  task automatic check(input logic [31:0] a, input logic [2:0] expected);
    addr = a;
    #1;                                  // let the combinational logic settle
    checks++;
    if (dev_sel !== expected) begin
      $display("ERROR: addr=%h  got %0d  expected %0d", a, dev_sel, expected);
      errors++;
    end
  endtask

  initial begin
    // UART (0): 0x0000_1000 - 0x0000_103F
    check(32'h0000_0FFF, 6);
    check(32'h0000_1000, 0);
    check(32'h0000_1028, 0);   // inside
    check(32'h0000_103F, 0);
    check(32'h0000_1040, 6);

    // GPIO (1): 0x0000_2000 - 0x0000_207F
    check(32'h0000_1FFF, 6);
    check(32'h0000_2000, 1);
    check(32'h0000_206E, 1);   // inside
    check(32'h0000_207F, 1);
    check(32'h0000_2080, 6);

    // SimCtrl (2): 0x0002_0000 - 0x0002_03FF
    check(32'h0001_FFFF, 6);
    check(32'h0002_0000, 2);
    check(32'h0002_0008, 2);   // the halt register
    check(32'h0002_03FF, 2);
    check(32'h0002_0400, 6);

    // Timer (3): 0x0003_0000 - 0x0003_03FF
    check(32'h0002_FFFF, 6);
    check(32'h0003_0000, 3);
    check(32'h0003_03FF, 3);
    check(32'h0003_0400, 6);

    // RAM (4): 0x0010_0000 - 0x001F_FFFF
    check(32'h000F_FFFF, 6);
    check(32'h0010_0000, 4);
    check(32'h0010_0080, 4);   // the reset entry
    check(32'h001F_FFFF, 4);
    check(32'h0020_0000, 6);

    // rv_plic (5): 0x1000_0000 - 0x17FF_FFFF
    check(32'h0FFF_FFFF, 6);
    check(32'h1000_0000, 5);
    check(32'h1020_0004, 5);   // claim/complete register (CC0)
    check(32'h17FF_FFFF, 5);
    check(32'h1800_0000, 6);

    // Unmapped addresses
    check(32'h0000_0000, 6);   // null pointer
    check(32'h0004_0000, 6);   // used by unmapped_test: must stay unmapped
    check(32'hFFFF_FFFF, 6);   // top of the address space

    if (errors == 0) $display("PASS: all %0d address checks correct", checks);
    else             $display("FAIL: %0d of %0d checks wrong", errors, checks);
    $finish;
  end
endmodule
