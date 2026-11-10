// gpio_reg_test: GPIO register accesses, checked entirely by the UVM register model.
// Software only reads and writes; the predictor checks every read against the model.

#include <stdint.h>
#include "simple_system_common.h"
#include "soc.h"
#include "gpio_regs.h"

#define GPIO_REG(off)  REG32(GPIO_BASE + (off))
#define COUNT(a)       (sizeof(a) / sizeof((a)[0]))

// Read right after reset. Left out: INTR_TEST and ALERT_TEST (write-only).
static const uint32_t reset_regs[] = {
  GPIO_INTR_STATE_REG_OFFSET,           GPIO_INTR_ENABLE_REG_OFFSET,
  GPIO_DATA_IN_REG_OFFSET,              GPIO_DIRECT_OUT_REG_OFFSET,
  GPIO_MASKED_OUT_LOWER_REG_OFFSET,     GPIO_MASKED_OUT_UPPER_REG_OFFSET,
  GPIO_DIRECT_OE_REG_OFFSET,            GPIO_MASKED_OE_LOWER_REG_OFFSET,
  GPIO_MASKED_OE_UPPER_REG_OFFSET,      GPIO_INTR_CTRL_EN_RISING_REG_OFFSET,
  GPIO_INTR_CTRL_EN_FALLING_REG_OFFSET, GPIO_INTR_CTRL_EN_LVLHIGH_REG_OFFSET,
  GPIO_INTR_CTRL_EN_LVLLOW_REG_OFFSET,  GPIO_CTRL_EN_INPUT_FILTER_REG_OFFSET,
  GPIO_HW_STRAPS_DATA_IN_VALID_REG_OFFSET, GPIO_HW_STRAPS_DATA_IN_REG_OFFSET,
};

// Written and read back: the non-volatile read/write registers.
// Left out: the pin registers (DIRECT_OUT, MASKED_*, DIRECT_OE), which the model
// marks volatile and doesn't compare, so writing them would only toggle pins.
static const uint32_t rw_regs[] = {
  GPIO_INTR_ENABLE_REG_OFFSET,
  GPIO_INTR_CTRL_EN_RISING_REG_OFFSET,  GPIO_INTR_CTRL_EN_FALLING_REG_OFFSET,
  GPIO_INTR_CTRL_EN_LVLHIGH_REG_OFFSET, GPIO_INTR_CTRL_EN_LVLLOW_REG_OFFSET,
  GPIO_CTRL_EN_INPUT_FILTER_REG_OFFSET,
};

static const uint32_t patterns[] = { 0xFFFFFFFF, 0x00000000, 0xA5A5A5A5, 0x5A5A5A5A };

int main(void) {
  puts("gpio_reg_test: start\n");

  for (unsigned i = 0; i < COUNT(reset_regs); i++)
    (void)GPIO_REG(reset_regs[i]);

  for (unsigned p = 0; p < COUNT(patterns); p++)
    for (unsigned r = 0; r < COUNT(rw_regs); r++) {
      GPIO_REG(rw_regs[r]) = patterns[p];
      (void)GPIO_REG(rw_regs[r]);
    }

  puts("TEST PASSED\n");   // the verdict is the model's: UVM_ERROR count
  sim_halt();
  return 0;
}