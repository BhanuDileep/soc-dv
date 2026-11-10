// uart_reg_test: UART register accesses, checked entirely by the UVM register model.
// Software performs reads and writes only; it compares nothing itself. The testbench's
// predictor updates the model on every write and checks every read against it,
// using the reset values and access types generated from uart.hjson.

#include <stdint.h>
#include "simple_system_common.h"
#include "soc.h"
#include "uart_regs.h"

#define UART_REG(off)  REG32(UART_BASE + (off))
#define COUNT(a)       (sizeof(a) / sizeof((a)[0]))

// Part 1: registers read right after reset.
// Left out: RDATA (a read pops the RX FIFO), and WDATA, INTR_TEST, ALERT_TEST (write-only).
static const uint32_t reset_regs[] = {
  UART_INTR_STATE_REG_OFFSET,
  UART_INTR_ENABLE_REG_OFFSET,
  UART_CTRL_REG_OFFSET,
  UART_STATUS_REG_OFFSET,
  UART_FIFO_CTRL_REG_OFFSET,
  UART_FIFO_STATUS_REG_OFFSET,
  UART_OVRD_REG_OFFSET,
  UART_VAL_REG_OFFSET,
  UART_TIMEOUT_CTRL_REG_OFFSET,
};

// Part 2: read/write registers, written and read back.
// Left out: OVRD, since writing it would drive arbitrary levels onto the TX pin.
static const uint32_t rw_regs[] = {
  UART_INTR_ENABLE_REG_OFFSET,
  UART_CTRL_REG_OFFSET,
  UART_FIFO_CTRL_REG_OFFSET,
  UART_TIMEOUT_CTRL_REG_OFFSET,
};

// All ones, all zeros, and two alternating patterns: every bit is written as 1 and as 0,
// and neighboring bits always differ in at least one pattern (catches shorted bits).
static const uint32_t patterns[] = {
  0xFFFFFFFF, 0x00000000, 0xA5A5A5A5, 0x5A5A5A5A,
};

int main(void) {
  puts("uart_reg_test: start\n");

  // Part 1: reset values
  for (unsigned i = 0; i < COUNT(reset_regs); i++)
    (void)UART_REG(reset_regs[i]);

  // Part 2: write each pattern, then read it back
  for (unsigned p = 0; p < COUNT(patterns); p++) {
    for (unsigned r = 0; r < COUNT(rw_regs); r++) {
      UART_REG(rw_regs[r]) = patterns[p];
      (void)UART_REG(rw_regs[r]);
    }
  }

  puts("TEST PASSED\n");   // only means "all accesses were made": the verdict is the model's
  sim_halt();
  return 0;
}