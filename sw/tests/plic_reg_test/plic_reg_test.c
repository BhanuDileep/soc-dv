// plic_reg_test: PLIC register accesses, checked entirely by the UVM register model.
// Never touches CC0 (a read claims an interrupt, a write completes one),
// MSIP0 (a software interrupt) or ALERT_TEST (an alert).

#include <stdint.h>
#include "simple_system_common.h"
#include "soc.h"
#include "rv_plic_regs.h"

#define PLIC_REG(off)  REG32(PLIC_BASE + (off))
#define COUNT(a)       (sizeof(a) / sizeof((a)[0]))
#define N_SOURCES      42                        // must match ip/cfg/rv_plic.hjson
#define PRIO(i)        (RV_PLIC_PRIO_0_REG_OFFSET + 4 * (i))

// Read/write registers besides the priorities
static const uint32_t rw_regs[] = {
  RV_PLIC_IE0_0_REG_OFFSET, RV_PLIC_IE0_1_REG_OFFSET, RV_PLIC_THRESHOLD0_REG_OFFSET,
};

static const uint32_t patterns[] = { 0xFFFFFFFF, 0x00000000, 0xA5A5A5A5, 0x5A5A5A5A };

int main(void) {
  puts("plic_reg_test: start\n");

  // Part 1: reset values (IP_0/IP_1 are read-only pending bits: read, not written)
  for (unsigned i = 0; i < N_SOURCES; i++)  (void)PLIC_REG(PRIO(i));
  (void)PLIC_REG(RV_PLIC_IP_0_REG_OFFSET);
  (void)PLIC_REG(RV_PLIC_IP_1_REG_OFFSET);
  for (unsigned r = 0; r < COUNT(rw_regs); r++)  (void)PLIC_REG(rw_regs[r]);

  // Part 2: write each pattern, then read back
  for (unsigned p = 0; p < COUNT(patterns); p++) {
    for (unsigned i = 0; i < N_SOURCES; i++) {
      PLIC_REG(PRIO(i)) = patterns[p];
      (void)PLIC_REG(PRIO(i));
    }
    for (unsigned r = 0; r < COUNT(rw_regs); r++) {
      PLIC_REG(rw_regs[r]) = patterns[p];
      (void)PLIC_REG(rw_regs[r]);
    }
  }

  puts("TEST PASSED\n");
  sim_halt();
  return 0;
}