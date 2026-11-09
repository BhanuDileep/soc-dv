// uart_tx_test: send a string out of the chip on the real TX pin (no loopback).
// The testbench's UART monitor decodes it from the wire.

#include <stdint.h>
#include "simple_system_common.h"
#include "soc.h"
#include "uart_regs.h"

#define UART_REG(off)  REG32(UART_BASE + (off))
#define NCO_1MBAUD     10486u
#define TIMEOUT        100000

static const char msg[] = "BHANU DILEEP REDDY MARYADA";

static void fail(const char *what) {
  puts("TEST FAILED: ");
  puts(what);
  puts("\n");
  sim_halt();
  while (1) { }
}

int main(void) {
  puts("uart_tx_test: start\n");

  // Transmitter on, 1 Mbaud. No RX, no loopback: bytes leave on the TX pin.
  UART_REG(UART_CTRL_REG_OFFSET) = (1u << UART_CTRL_TX_BIT)
                                 | (NCO_1MBAUD << UART_CTRL_NCO_OFFSET);

  // Send each character, waiting for room in the TX FIFO
  for (const char *p = msg; *p != '\0'; p++) {
    int timeout = TIMEOUT;
    while (UART_REG(UART_STATUS_REG_OFFSET) & (1u << UART_STATUS_TXFULL_BIT)) {
      if (--timeout == 0) fail("timeout: TX FIFO stayed full");
    }
    UART_REG(UART_WDATA_REG_OFFSET) = (uint32_t)*p;
  }

  // Wait until the FIFO is empty AND the transmitter is idle:
  // only then has the last bit actually left the pin.
  uint32_t done = (1u << UART_STATUS_TXEMPTY_BIT) | (1u << UART_STATUS_TXIDLE_BIT);
  int timeout = TIMEOUT;
  while ((UART_REG(UART_STATUS_REG_OFFSET) & done) != done) {
    if (--timeout == 0) fail("timeout: transmitter never went idle");
  }

  puts("TEST PASSED\n");
  sim_halt();
  return 0;
}