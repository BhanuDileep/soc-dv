#ifndef SOC_H
#define SOC_H

#include <stdint.h>

// ---------------------------------------------------------------
// Register access
// ---------------------------------------------------------------
// Treat an address as a 32-bit hardware register.
#define REG32(addr) (*(volatile uint32_t *)(addr))

// ---------------------------------------------------------------
// Address map (must match rtl/soc_addr_decode.sv)
// ---------------------------------------------------------------
#define UART_BASE     0x00001000u
#define GPIO_BASE     0x00002000u
#define SIMCTRL_BASE  0x00020000u
#define TIMER_BASE    0x00030000u
#define RAM_BASE      0x00100000u
#define PLIC_BASE     0x10000000u

// ---------------------------------------------------------------
// PLIC interrupt source IDs (must match the intr_src map in rtl/soc_top.sv)
// ---------------------------------------------------------------
#define PLIC_SRC_UART_TX_WATERMARK   1
#define PLIC_SRC_UART_RX_WATERMARK   2
#define PLIC_SRC_UART_TX_DONE        3
#define PLIC_SRC_UART_RX_OVERFLOW    4
#define PLIC_SRC_UART_RX_FRAME_ERR   5
#define PLIC_SRC_UART_RX_BREAK_ERR   6
#define PLIC_SRC_UART_RX_TIMEOUT     7
#define PLIC_SRC_UART_RX_PARITY_ERR  8
#define PLIC_SRC_UART_TX_EMPTY       9
#define PLIC_SRC_GPIO(n)             (10 + (n))   // GPIO pin n -> source 10..41
#define PLIC_NUM_SRC                 42

#endif  // SOC_H