// gpio_in_test: inputs on pins 0-15 are driven by the testbench at random times.
// On every edge, the interrupt handler copies DATA_IN[15:0] to the outputs on pins 16-31.
// The testbench checks that the outputs follow the inputs.

#include <stdint.h>
#include "simple_system_common.h"
#include "soc.h"
#include "gpio_regs.h"
#include "rv_plic_regs.h"

#define GPIO_REG(off)  REG32(GPIO_BASE + (off))
#define PLIC_REG(off)  REG32(PLIC_BASE + (off))

#define CSR_SET(csr, bits)   asm volatile ("csrs " #csr ", %0" :: "r"(bits))
#define CSR_CLEAR(csr, bits) asm volatile ("csrc " #csr ", %0" :: "r"(bits))
#define MIE_MEIE     (1u << 11)
#define MSTATUS_MIE  (1u << 3)

#define IN_MASK        0x0000FFFFu     // pins 0-15: inputs
#define OUT_MASK       0xFFFF0000u     // pins 16-31: outputs
#define FIRST_TIMEOUT  5000            // polls waiting for the first interrupt
#define IDLE_TIMEOUT   1000            // polls (~100 us) with no new interrupt: the stream is over

static volatile uint32_t irq_count      = 0;    // real events handled
static volatile uint32_t spurious_count = 0;

static void fail(const char *msg, uint32_t expected, uint32_t got) {
  puts("TEST FAILED: ");  puts(msg);
  puts(" expected 0x");   puthex(expected);
  puts(" got 0x");        puthex(got);
  puts("\n");
  sim_halt();
  while (1) { }
}

void simple_external_handler(void) __attribute__((interrupt));
void simple_external_handler(void) {
  uint32_t id = PLIC_REG(RV_PLIC_CC0_REG_OFFSET);               // claim

  if (id >= PLIC_SRC_GPIO(0) && id <= PLIC_SRC_GPIO(15)) {
    uint32_t pin = id - PLIC_SRC_GPIO(0);
    if (GPIO_REG(GPIO_INTR_STATE_REG_OFFSET) & (1u << pin)) {   // the device confirms the event
      GPIO_REG(GPIO_INTR_STATE_REG_OFFSET) = 1u << pin;          // 1. acknowledge FIRST
      uint32_t in = GPIO_REG(GPIO_DATA_IN_REG_OFFSET) & IN_MASK; // 2. then read the inputs
      GPIO_REG(GPIO_MASKED_OUT_UPPER_REG_OFFSET) = (0xFFFFu << 16) | in;  // 3. all 16 outputs = inputs
      irq_count++;
    } else {
      spurious_count++;                                          // late re-trigger: nothing pending
    }
  } else {
    spurious_count++;                                            // a source this test didn't enable
  }

  PLIC_REG(RV_PLIC_CC0_REG_OFFSET) = id;                         // complete
}

int main(void) {
  puts("gpio_in_test: start\n");

  // 1-3. GPIO: outputs on 16-31, edge interrupts on 0-15, nothing pending
  GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET)           = 0;
  GPIO_REG(GPIO_DIRECT_OE_REG_OFFSET)            = OUT_MASK;
  GPIO_REG(GPIO_INTR_CTRL_EN_RISING_REG_OFFSET)  = IN_MASK;
  GPIO_REG(GPIO_INTR_CTRL_EN_FALLING_REG_OFFSET) = IN_MASK;
  GPIO_REG(GPIO_INTR_STATE_REG_OFFSET)           = 0xFFFFFFFF;

  // 4-5. PLIC: priority 1 and enabled for sources 10-25 (GPIO pins 0-15)
  for (uint32_t pin = 0; pin < 16; pin++)
    PLIC_REG(RV_PLIC_PRIO_0_REG_OFFSET + 4 * PLIC_SRC_GPIO(pin)) = 1;
  PLIC_REG(RV_PLIC_IE0_0_REG_OFFSET)      = 0xFFFFu << PLIC_SRC_GPIO(0);
  PLIC_REG(RV_PLIC_THRESHOLD0_REG_OFFSET) = 0;

  // 6. The core's gates
  CSR_SET(mie, MIE_MEIE);
  CSR_SET(mstatus, MSTATUS_MIE);

  // 7. LAST: GPIO interrupts on. This write is also the testbench's signal to start.
  GPIO_REG(GPIO_INTR_ENABLE_REG_OFFSET) = IN_MASK;

  // Wait while interrupts keep arriving; stop after a long silence
  uint32_t seen = 0;
  int limit = FIRST_TIMEOUT;
  while (limit-- > 0) {
    if (irq_count != seen) {          // a new event was handled: reset the silence timer
      seen  = irq_count;
      limit = IDLE_TIMEOUT;
    }
  }
  CSR_CLEAR(mstatus, MSTATUS_MIE);

  if (irq_count == 0) fail("no GPIO interrupts received, irq_count", 1, 0);

  // Software's own final check: the outputs must show the current inputs
  uint32_t in  = GPIO_REG(GPIO_DATA_IN_REG_OFFSET) & IN_MASK;
  uint32_t out = GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET) >> 16;
  if (out != in) fail("final outputs don't match inputs,", in, out);

  puts("handled 0x");   puthex(irq_count);      puts(" events, spurious 0x");
  puthex(spurious_count);                       puts("\n");
  puts("TEST PASSED\n");
  sim_halt();
  return 0;
}