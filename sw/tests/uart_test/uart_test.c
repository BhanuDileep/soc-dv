// uart_test: UART system-loopback test.
// With SLPBK on, everything transmitted is fed straight back into the
// receiver inside UART. Send a byte pattern, read it back, compare.
// Prints TEST PASSED or TEST FAILED, then halts the simulation.

#include <stdint.h>
#include "soc.h"
#include "simple_system_common.h"
#include "uart_regs.h"

#define UART_REG(off) (REG32(UART_BASE + (off)))

#define NCO_1MBAUD 10486u
#define TIMEOUT 100000

static const uint8_t pattern[] = {0x55, 0xAA, 0xFF, 0x00, 0x12, 0x34};
#define N_BYTES (sizeof(pattern) / sizeof(pattern[0]))

static void fail(const char *msg, uint32_t value) {
    puts("TEST FAILED");
    puts(msg);
    puts("0x");
    puthex(value);
    putchar('\n');
    sim_halt();
    while(1){};
}

static void wait_while_set(uint32_t bit, const char *what) {
    int timeout = TIMEOUT;
    while(UART_REG(UART_STATUS_REG_OFFSET) & (1<<bit)) {
        if(--timeout == 0) fail(what, UART_REG(UART_STATUS_REG_OFFSET));
    }
}

int main(void) {
    uint32_t status, ctrl, rx;

    puts("UART Test Starts: \n");

    status = UART_REG(UART_STATUS_REG_OFFSET);
    if (status != UART_STATUS_REG_RESVAL) fail("STATUS reset value, got", status);

    ctrl = (1u << UART_CTRL_TX_BIT)
         | (1u << UART_CTRL_RX_BIT)
         | (1u << UART_CTRL_SLPBK_BIT)
         | (NCO_1MBAUD << UART_CTRL_NCO_OFFSET);

    UART_REG(UART_CTRL_REG_OFFSET) = ctrl;

    if(UART_REG(UART_CTRL_REG_OFFSET) != ctrl){
        fail("CTRL readback, got", UART_REG(UART_CTRL_REG_OFFSET));
    }

    for (unsigned i = 0; i < N_BYTES; i++) {
        wait_while_set(UART_STATUS_TXFULL_BIT, "timeout: TX FIFO stayed full, STATUS =");
        UART_REG(UART_WDATA_REG_OFFSET) = pattern[i];
    }

    for (unsigned i = 0; i < N_BYTES; i++) {
    wait_while_set(UART_STATUS_RXEMPTY_BIT, "timeout: no RX data, STATUS =");
    rx = UART_REG(UART_RDATA_REG_OFFSET) & 0xFF;
    if (rx != pattern[i]) {
      puts("expected 0x");
      puthex(pattern[i]);
      puts("\n");
      fail("RX data mismatch, got", rx);
    }
  }

  puts("TEST PASSED\n");
  sim_halt();
  return 0;


}

