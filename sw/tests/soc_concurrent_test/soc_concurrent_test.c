// soc_concurrent_test: UART and GPIO interrupts at the same time, one handler.
//  - UART: every byte received on RX is echoed on TX (rx_watermark interrupt, PLIC source 2)
//  - GPIO: every edge on pins 0-15 is reflected on pins 16-31 (PLIC sources 10-25)
// UART has higher priority: a late UART response can lose bytes (RX FIFO overflow);
// a late GPIO response only delays the outputs.

#include <stdint.h>
#include "simple_system_common.h"
#include "soc.h"
#include "uart_regs.h"
#include "gpio_regs.h"
#include "rv_plic_regs.h"

#define UART_REG(off)  REG32(UART_BASE + (off))
#define GPIO_REG(off)  REG32(GPIO_BASE + (off))
#define PLIC_REG(off)  REG32(PLIC_BASE + (off))

#define CSR_SET(csr, bits)   asm volatile ("csrs " #csr ", %0" :: "r"(bits))
#define CSR_CLEAR(csr, bits) asm volatile ("csrc " #csr ", %0" :: "r"(bits))
#define MIE_MEIE     (1u << 11)
#define MSTATUS_MIE  (1u << 3)

// Must match the intr_src order in soc_top.sv: UART interrupts start at source 1
#define SRC_UART_RXWM   (1 + UART_INTR_COMMON_RX_WATERMARK_BIT)    // = 2
#define PRIO_UART       2
#define PRIO_GPIO       1

#define NCO_1MBAUD     10486u
#define IN_MASK        0x0000FFFFu
#define OUT_MASK       0xFFFF0000u
#define FIRST_TIMEOUT  5000
#define IDLE_TIMEOUT   1000          // ~100 us without ANY interrupt: both streams are over
#define TX_TIMEOUT     100000

static volatile uint32_t uart_count     = 0;   // bytes echoed
static volatile uint32_t gpio_count     = 0;   // GPIO events reflected
static volatile uint32_t spurious_count = 0;

static void fail(const char *msg, uint32_t expected, uint32_t got) {
  puts("TEST FAILED: ");  puts(msg);
  puts(" expected 0x");   puthex(expected);
  puts(" got 0x");        puthex(got);
  puts("\n");
  sim_halt();
  while (1) { }
}

static void handle_uart(void) {
  if (UART_REG(UART_STATUS_REG_OFFSET) & (1u << UART_STATUS_RXEMPTY_BIT)) {
    spurious_count++;                      // late re-trigger: the FIFO is already empty
    return;
  }
  // Drain EVERY waiting byte: this is what makes the watermark condition false
  while (!(UART_REG(UART_STATUS_REG_OFFSET) & (1u << UART_STATUS_RXEMPTY_BIT))) {
    uint32_t byte = UART_REG(UART_RDATA_REG_OFFSET) & 0xFF;
    int t = TX_TIMEOUT;
    while (UART_REG(UART_STATUS_REG_OFFSET) & (1u << UART_STATUS_TXFULL_BIT))
      if (--t == 0) fail("TX FIFO stayed full, level", 0, 1);
    UART_REG(UART_WDATA_REG_OFFSET) = byte;
    uart_count++;
  }
  UART_REG(UART_INTR_STATE_REG_OFFSET) = 1u << UART_INTR_COMMON_RX_WATERMARK_BIT;  // harmless if status-type
}

static void handle_gpio(uint32_t pin) {
  if (!(GPIO_REG(GPIO_INTR_STATE_REG_OFFSET) & (1u << pin))) {
    spurious_count++;
    return;
  }
  GPIO_REG(GPIO_INTR_STATE_REG_OFFSET) = 1u << pin;                   // acknowledge first
  uint32_t in = GPIO_REG(GPIO_DATA_IN_REG_OFFSET) & IN_MASK;          // then read
  GPIO_REG(GPIO_MASKED_OUT_UPPER_REG_OFFSET) = (0xFFFFu << 16) | in;  // reflect on 16-31
  gpio_count++;
}

void simple_external_handler(void) __attribute__((interrupt));
void simple_external_handler(void) {
  uint32_t id = PLIC_REG(RV_PLIC_CC0_REG_OFFSET);                    // claim: highest-priority pending

  if (id == SRC_UART_RXWM)
    handle_uart();
  else if (id >= PLIC_SRC_GPIO(0) && id <= PLIC_SRC_GPIO(15))
    handle_gpio(id - PLIC_SRC_GPIO(0));
  else
    spurious_count++;                                                 // a source this test didn't enable

  PLIC_REG(RV_PLIC_CC0_REG_OFFSET) = id;                              // complete
}

int main(void) {
  puts("soc_concurrent_test: start\n");

  // UART: TX + RX at 1 Mbaud, no loopback; interrupt when a byte arrives
  UART_REG(UART_CTRL_REG_OFFSET) = (1u << UART_CTRL_TX_BIT)
                                 | (1u << UART_CTRL_RX_BIT)
                                 | (NCO_1MBAUD << UART_CTRL_NCO_OFFSET);
  UART_REG(UART_INTR_ENABLE_REG_OFFSET) = 1u << UART_INTR_COMMON_RX_WATERMARK_BIT;

  // GPIO: outputs on 16-31, edge detection on 0-15, nothing pending
  GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET)           = 0;
  GPIO_REG(GPIO_DIRECT_OE_REG_OFFSET)            = OUT_MASK;
  GPIO_REG(GPIO_INTR_CTRL_EN_RISING_REG_OFFSET)  = IN_MASK;
  GPIO_REG(GPIO_INTR_CTRL_EN_FALLING_REG_OFFSET) = IN_MASK;
  GPIO_REG(GPIO_INTR_STATE_REG_OFFSET)           = 0xFFFFFFFF;

  // PLIC: UART above GPIO
  PLIC_REG(RV_PLIC_PRIO_0_REG_OFFSET + 4 * SRC_UART_RXWM) = PRIO_UART;
  for (uint32_t pin = 0; pin < 16; pin++)
    PLIC_REG(RV_PLIC_PRIO_0_REG_OFFSET + 4 * PLIC_SRC_GPIO(pin)) = PRIO_GPIO;
  PLIC_REG(RV_PLIC_IE0_0_REG_OFFSET) = (1u << SRC_UART_RXWM) | (0xFFFFu << PLIC_SRC_GPIO(0));
  PLIC_REG(RV_PLIC_THRESHOLD0_REG_OFFSET) = 0;

  CSR_SET(mie, MIE_MEIE);
  CSR_SET(mstatus, MSTATUS_MIE);

  // LAST: GPIO interrupts on. This write is the testbench's signal to start both streams.
  GPIO_REG(GPIO_INTR_ENABLE_REG_OFFSET) = IN_MASK;

  // Run until neither device has interrupted for a long time
  uint32_t seen = 0;
  int limit = FIRST_TIMEOUT;
  while (limit-- > 0) {
    uint32_t total = uart_count + gpio_count;
    if (total != seen) { seen = total; limit = IDLE_TIMEOUT; }
  }
  CSR_CLEAR(mstatus, MSTATUS_MIE);

  if (uart_count == 0) fail("no UART bytes echoed, count", 1, 0);
  if (gpio_count == 0) fail("no GPIO events handled, count", 1, 0);

  // Let the last echoed byte leave the TX pin
  uint32_t done = (1u << UART_STATUS_TXEMPTY_BIT) | (1u << UART_STATUS_TXIDLE_BIT);
  int t = TX_TIMEOUT;
  while ((UART_REG(UART_STATUS_REG_OFFSET) & done) != done)
    if (--t == 0) fail("transmitter never went idle, status", done, UART_REG(UART_STATUS_REG_OFFSET));

  // Software's own final GPIO check
  uint32_t in  = GPIO_REG(GPIO_DATA_IN_REG_OFFSET) & IN_MASK;
  uint32_t out = GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET) >> 16;
  if (out != in) fail("final GPIO outputs don't match inputs,", in, out);

  puts("UART bytes 0x");  puthex(uart_count);
  puts(", GPIO events 0x"); puthex(gpio_count);
  puts(", spurious 0x");  puthex(spurious_count);
  puts("\n");
  puts("TEST PASSED\n");
  sim_halt();
  return 0;
}