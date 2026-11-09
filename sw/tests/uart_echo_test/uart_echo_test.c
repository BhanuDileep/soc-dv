// uart_echo_test: echo every byte received on RX back out on TX.
// The testbench drives random bytes into RX and checks that the same
// bytes come out of TX, in order. Software never knows the data:
// it only reflects it. The end of the stream is detected by silence.

#include <stdint.h>
#include "simple_system_common.h"
#include "soc.h"
#include "uart_regs.h"

#define UART_REG(off)   REG32(UART_BASE + (off))
#define NCO_1MBAUD      10486u
#define FIRST_TIMEOUT   100000    // polls waiting for the first byte: none arriving is a failure
#define IDLE_TIMEOUT    20000      // polls (~200 us) of silence after a byte: the stream has ended
#define TX_TIMEOUT      100000

static void fail(const char *what) {
  puts("TEST FAILED: ");
  puts(what);
  puts("\n");
  sim_halt();
  while (1) { }
}

// Wait for a received byte. Returns 1 if one arrived, 0 if 'limit' polls passed in silence.
static int wait_rx(int limit) {
  while (UART_REG(UART_STATUS_REG_OFFSET) & (1u << UART_STATUS_RXEMPTY_BIT)) {
    if (--limit == 0) return 0;
  }
  return 1;
}

int main(void) {
  puts("uart_echo_test: start\n");

  // TX and RX on, 1 Mbaud, no loopback. This write is also the sync signal:
  // the testbench starts sending once it sees RX enabled.
  UART_REG(UART_CTRL_REG_OFFSET) = (1u << UART_CTRL_TX_BIT)
                                 | (1u << UART_CTRL_RX_BIT)
                                 | (NCO_1MBAUD << UART_CTRL_NCO_OFFSET);

  uint32_t count = 0;
  int limit = FIRST_TIMEOUT;

  while (wait_rx(limit)) {
    uint32_t byte = UART_REG(UART_RDATA_REG_OFFSET) & 0xFF;   // pop the received byte

    int t = TX_TIMEOUT;                                        // wait for room, then echo it
    while (UART_REG(UART_STATUS_REG_OFFSET) & (1u << UART_STATUS_TXFULL_BIT)) {
      if (--t == 0) fail("timeout: TX FIFO stayed full");
    }
    UART_REG(UART_WDATA_REG_OFFSET) = byte;

    count++;
    limit = IDLE_TIMEOUT;     // after the first byte, a short silence ends the stream
  }

  if (count == 0) fail("no bytes received");

  // Let the last echoed byte fully leave the TX pin
  uint32_t done = (1u << UART_STATUS_TXEMPTY_BIT) | (1u << UART_STATUS_TXIDLE_BIT);
  int t = TX_TIMEOUT;
  while ((UART_REG(UART_STATUS_REG_OFFSET) & done) != done) {
    if (--t == 0) fail("timeout: transmitter never went idle");
  }

  puts("echoed 0x");
  puthex(count);
  puts(" bytes\n");
  puts("TEST PASSED\n");
  sim_halt();
  return 0;
}