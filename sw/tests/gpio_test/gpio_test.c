// gpio_test: GPIO data-path test, using a loopback in tb_top (gpio_i = gpio_o & gpio_oe).
// Checks: direct output on all pins, output-enable gating, and masked writes.
// Prints TEST PASSED or TEST FAILED, then halts the simulation.

#include <stdint.h>
#include "simple_system_common.h"   // puts, puthex, sim_halt
#include "soc.h"                    // GPIO_BASE, REG32
#include "gpio_regs.h"              // generated register offsets

#define GPIO_REG(off) REG32(GPIO_BASE + (off))

static void fail(const char *msg, uint32_t expected, uint32_t got) {
    puts("TEST FAILED: \n");
    puts(msg);
    puts("expected 0x");
    puthex(expected);
    puts(" got 0x");
    puthex(got);
    puts("\n");
    sim_halt();
    while(1) {};
}

// Give the input path time to update: an output change reaches DATA_IN only
// after the 2-flop synchronizer (2-3 cycles). Each loop iteration takes several
// cycles, and volatile stops the compiler from deleting the empty loop.
static void wait() {
    for(volatile int i = 0; i < 10; i++) {}
}

static void check_in(uint32_t expected, const char *what) {
    wait();
    uint32_t got = GPIO_REG(GPIO_DATA_IN_REG_OFFSET);
    if(expected != got) fail(what, expected, got);
}

int main(void) {
    puts("gpio_test: start\n");

    // 0. After reset no pin is driven (OE = 0), so every input reads 0
    check_in(0x00000000, "DATA_IN after reset,");

    // 1. Direct output, all pins enabled
    GPIO_REG(GPIO_DIRECT_OE_REG_OFFSET) = 0xFFFFFFFF;

    static const uint32_t patterns[] = {0x55555555, 0xAAAAAAAA, 0xFFFFFFFF, 0x00000000};
    for(unsigned i = 0; i < sizeof(patterns)/sizeof(patterns[0]); i++) {
    GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET) = patterns[i];
    check_in(patterns[i], "direct out pattern,");
    }

    // Walking 1: one pin high at a time, which catches swapped or shorted pins
    for(unsigned pin = 0; pin < 32; pin++) {
    GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET) = 1u << pin;
    check_in(1u << pin, "walking 1,");
    }

    // 2. Output enable: drive all 1s, but enable only half the pins.
    //    Undriven pins must read 0.
    GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET) = 0xFFFFFFFF;
    GPIO_REG(GPIO_DIRECT_OE_REG_OFFSET)  = 0x0000FFFF;
    check_in(0x0000FFFF, "OE lower half only,");
    GPIO_REG(GPIO_DIRECT_OE_REG_OFFSET)  = 0xFFFF0000;
    check_in(0xFFFF0000, "OE upper half only,");

    // 3. Masked writes: upper 16 bits = mask, lower 16 bits = data.
    //    Only pins whose mask bit is 1 may change.
    GPIO_REG(GPIO_DIRECT_OE_REG_OFFSET)  = 0xFFFFFFFF;
    GPIO_REG(GPIO_DIRECT_OUT_REG_OFFSET) = 0x00000000;

    // Set pin 3 (lower half, bit 3)
    GPIO_REG(GPIO_MASKED_OUT_LOWER_REG_OFFSET) = ((1u << 3) << 16) | (1u << 3);
    check_in(0x00000008, "masked set pin 3,");

    // Set pin 20 (upper half, bit 4 = pin 16 + 4); pin 3 must stay set
    GPIO_REG(GPIO_MASKED_OUT_UPPER_REG_OFFSET) = ((1u << 4) << 16) | (1u << 4);
    check_in(0x00100008, "masked set pin 20,");

    // Clear pin 3 only (mask bit set, data bit 0); pin 20 must stay set
    GPIO_REG(GPIO_MASKED_OUT_LOWER_REG_OFFSET) = ((1u << 3) << 16);
    check_in(0x00100000, "masked clear pin 3,");

    puts("TEST PASSED\n");
    sim_halt();
    return 0;
}



