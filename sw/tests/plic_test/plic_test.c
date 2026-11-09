// plic_test: full external-interrupt path.
//   GPIO INTR_TEST (pin 0) -> GPIO interrupt line -> PLIC source 10 -> core irq_external
//   -> vector entry 11 -> simple_external_handler: claim, clear the source, complete -> mret
// Prints TEST PASSED or TEST FAILED, then halts the simulation.

#include <stdint.h>
#include "simple_system_common.h"   // puts, puthex, sim_halt
#include "soc.h"                    // GPIO_BASE, PLIC_BASE, PLIC_SRC_GPIO, REG32
#include "gpio_regs.h"
#include "rv_plic_regs.h"

#define GPIO_REG(off)  REG32(GPIO_BASE + (off))
#define PLIC_REG(off)  REG32(PLIC_BASE + (off))

// CSR access through inline assembly (bit positions from the RISC-V privileged spec)
#define CSR_SET(csr, bits) asm volatile ("csrs " #csr ", %0" :: "r"(bits))
#define CSR_CLEAR(csr, bits) asm volatile ("csrc " #csr ", %0" :: "r"(bits))
#define CSR_READ(csr) ({ uint32_t v; asm volatile ("csrr %0, " #csr : "=r"(v)); v; })

#define MIE_MEIE     (1u << 11)        // mie: machine external interrupt enable
#define MSTATUS_MIE  (1u << 3)         // mstatus: global machine interrupt enable
#define MCAUSE_EXT   0x8000000Bu       // top bit = interrupt, code 11 = machine external

#define TEST_PIN     0
#define TEST_SRC     PLIC_SRC_GPIO(TEST_PIN)   // = 10
#define TIMEOUT      100000

// Written by the handler, read by main: must be volatile
static volatile uint32_t irq_count  = 0;
static volatile uint32_t claimed_id = 0;
static volatile uint32_t irq_mcause = 0;
static volatile uint32_t ids[4];

static void fail(const char *msg, uint32_t expected, uint32_t got) {
    puts("TEST FAILED: ");
    puts(msg);
    puts(" expected 0x");
    puthex(expected);
    puts(" got 0x");
    puthex(got);
    puts("\n");
    sim_halt();
    while (1) { }
}

// The real external-interrupt handler. Not static: it must be a normal ("strong")
// global symbol to replace the weak default in simple_system_common.c.
static volatile uint32_t spurious_count = 0;   // add next to the other shared variables

void simple_external_handler(void) __attribute__((interrupt));
void simple_external_handler(void) {
  uint32_t id = PLIC_REG(RV_PLIC_CC0_REG_OFFSET);        // 1. claim
  if (irq_count + spurious_count < 4) ids[irq_count + spurious_count] = id;
  irq_mcause = CSR_READ(mcause);

  if (id == TEST_SRC && (GPIO_REG(GPIO_INTR_STATE_REG_OFFSET) & (1u << TEST_PIN))) {
    // 2. Real event: the device confirms it. Clear the source and count it.
    GPIO_REG(GPIO_INTR_STATE_REG_OFFSET) = 1u << TEST_PIN;
    claimed_id = id;
    irq_count++;
  } else {
    // The PLIC raised it, but the device has nothing pending: a late
    // re-trigger from synchronizer latency. Nothing to service.
    spurious_count++;
  }

  PLIC_REG(RV_PLIC_CC0_REG_OFFSET) = id;                 // 3. complete
}                                                        // 4. return = mret                                                      // 4. return = mret

int main(void) {
    puts("plic_test: start\n");

    // 0. Nothing is pending after reset, so a claim must return 0 ("no interrupt")
    uint32_t id = PLIC_REG(RV_PLIC_CC0_REG_OFFSET);
    if (id != 0) fail("claim with nothing pending,", 0, id);

    // 1. Open the gates, innermost first, and the core's global enable LAST
    GPIO_REG(GPIO_INTR_ENABLE_REG_OFFSET) = 1u << TEST_PIN;       // gate 1: GPIO passes pin 0 on
    PLIC_REG(RV_PLIC_PRIO_10_REG_OFFSET)  = 1;                    // gate 2: priority > 0
    PLIC_REG(RV_PLIC_IE0_0_REG_OFFSET)    = 1u << TEST_SRC;       //         enable source 10 (IE0_0 = sources 0-31)
    PLIC_REG(RV_PLIC_THRESHOLD0_REG_OFFSET) = 0;                  //         priority 1 > threshold 0
    CSR_SET(mie, MIE_MEIE);                                       // gate 3: external interrupts allowed
    CSR_SET(mstatus, MSTATUS_MIE);                                //         interrupts globally on

    // 2. Trigger: force GPIO pin 0's interrupt without any pin activity
    GPIO_REG(GPIO_INTR_TEST_REG_OFFSET) = 1u << TEST_PIN;
    (void)GPIO_REG(GPIO_INTR_STATE_REG_OFFSET);              // read back: wait for the clear to settle
    PLIC_REG(RV_PLIC_CC0_REG_OFFSET) = id;                   // complete 


    // 3. Wait for the handler to run
    int timeout = TIMEOUT;
    while (irq_count == 0) {
        if (--timeout == 0) fail("timeout: no interrupt arrived, irq_count", 1, irq_count);
    }

    // 4. Wait a little longer: a correct handler runs exactly ONCE.
    //    If the source weren't cleared, the interrupt would keep re-firing.
    for (volatile int i = 0; i < 200; i++) { }
    //if (irq_count != 1) fail("handler ran more than once,", 1, irq_count);
    if (irq_count != 1) {
        puts("claimed IDs per call:");
        for (uint32_t i = 0; i < irq_count && i < 4; i++) {
            puts(" 0x");
            puthex(ids[i]);
        }
        puts("\n");
        fail("handler ran more than once,", 1, irq_count);
    }

    puts("spurious re-triggers: 0x");
    puthex(spurious_count);
    puts("\n");

    // 5. Check what the handler saw, and that everything was cleaned up
    if (claimed_id != TEST_SRC)   fail("claimed source ID,", TEST_SRC, claimed_id);
    if (irq_mcause != MCAUSE_EXT) fail("mcause in handler,", MCAUSE_EXT, irq_mcause);

    uint32_t state = GPIO_REG(GPIO_INTR_STATE_REG_OFFSET);
    if (state & (1u << TEST_PIN)) fail("GPIO INTR_STATE not cleared,", 0, state);

    uint32_t pending = PLIC_REG(RV_PLIC_IP_0_REG_OFFSET);
    if (pending & (1u << TEST_SRC)) fail("PLIC still shows source pending,", 0, pending);

    // 6. Close the global gate again
    CSR_CLEAR(mstatus, MSTATUS_MIE);

    puts("TEST PASSED\n");
    sim_halt();
    return 0;
}