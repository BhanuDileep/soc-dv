/**
 * @file
 * @brief Generated register defines for rv_plic
 */

// Copyright information found in source file:
// Copyright lowRISC contributors (OpenTitan project).

// Licensing information found in source file:
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef _RV_PLIC_REG_DEFS_
#define _RV_PLIC_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Number of interrupt sources
#define RV_PLIC_PARAM_NUM_SRC 42

// Number of Targets (Harts)
#define RV_PLIC_PARAM_NUM_TARGET 1

// Width of priority signals
#define RV_PLIC_PARAM_PRIO_WIDTH 3

// Number of alerts
#define RV_PLIC_PARAM_NUM_ALERTS 1

// Register width
#define RV_PLIC_PARAM_REG_WIDTH 32

// Interrupt Source Priority (common parameters)
#define RV_PLIC_PRIO_PRIO_FIELD_WIDTH 3
#define RV_PLIC_PRIO_MULTIREG_COUNT 42

// Interrupt Source Priority
#define RV_PLIC_PRIO_0_REG_OFFSET 0x0
#define RV_PLIC_PRIO_0_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_0_PRIO_0_MASK 0x7u
#define RV_PLIC_PRIO_0_PRIO_0_OFFSET 0
#define RV_PLIC_PRIO_0_PRIO_0_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_0_PRIO_0_MASK, .index = RV_PLIC_PRIO_0_PRIO_0_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_1_REG_OFFSET 0x4
#define RV_PLIC_PRIO_1_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_1_PRIO_1_MASK 0x7u
#define RV_PLIC_PRIO_1_PRIO_1_OFFSET 0
#define RV_PLIC_PRIO_1_PRIO_1_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_1_PRIO_1_MASK, .index = RV_PLIC_PRIO_1_PRIO_1_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_2_REG_OFFSET 0x8
#define RV_PLIC_PRIO_2_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_2_PRIO_2_MASK 0x7u
#define RV_PLIC_PRIO_2_PRIO_2_OFFSET 0
#define RV_PLIC_PRIO_2_PRIO_2_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_2_PRIO_2_MASK, .index = RV_PLIC_PRIO_2_PRIO_2_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_3_REG_OFFSET 0xc
#define RV_PLIC_PRIO_3_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_3_PRIO_3_MASK 0x7u
#define RV_PLIC_PRIO_3_PRIO_3_OFFSET 0
#define RV_PLIC_PRIO_3_PRIO_3_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_3_PRIO_3_MASK, .index = RV_PLIC_PRIO_3_PRIO_3_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_4_REG_OFFSET 0x10
#define RV_PLIC_PRIO_4_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_4_PRIO_4_MASK 0x7u
#define RV_PLIC_PRIO_4_PRIO_4_OFFSET 0
#define RV_PLIC_PRIO_4_PRIO_4_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_4_PRIO_4_MASK, .index = RV_PLIC_PRIO_4_PRIO_4_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_5_REG_OFFSET 0x14
#define RV_PLIC_PRIO_5_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_5_PRIO_5_MASK 0x7u
#define RV_PLIC_PRIO_5_PRIO_5_OFFSET 0
#define RV_PLIC_PRIO_5_PRIO_5_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_5_PRIO_5_MASK, .index = RV_PLIC_PRIO_5_PRIO_5_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_6_REG_OFFSET 0x18
#define RV_PLIC_PRIO_6_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_6_PRIO_6_MASK 0x7u
#define RV_PLIC_PRIO_6_PRIO_6_OFFSET 0
#define RV_PLIC_PRIO_6_PRIO_6_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_6_PRIO_6_MASK, .index = RV_PLIC_PRIO_6_PRIO_6_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_7_REG_OFFSET 0x1c
#define RV_PLIC_PRIO_7_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_7_PRIO_7_MASK 0x7u
#define RV_PLIC_PRIO_7_PRIO_7_OFFSET 0
#define RV_PLIC_PRIO_7_PRIO_7_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_7_PRIO_7_MASK, .index = RV_PLIC_PRIO_7_PRIO_7_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_8_REG_OFFSET 0x20
#define RV_PLIC_PRIO_8_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_8_PRIO_8_MASK 0x7u
#define RV_PLIC_PRIO_8_PRIO_8_OFFSET 0
#define RV_PLIC_PRIO_8_PRIO_8_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_8_PRIO_8_MASK, .index = RV_PLIC_PRIO_8_PRIO_8_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_9_REG_OFFSET 0x24
#define RV_PLIC_PRIO_9_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_9_PRIO_9_MASK 0x7u
#define RV_PLIC_PRIO_9_PRIO_9_OFFSET 0
#define RV_PLIC_PRIO_9_PRIO_9_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_9_PRIO_9_MASK, .index = RV_PLIC_PRIO_9_PRIO_9_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_10_REG_OFFSET 0x28
#define RV_PLIC_PRIO_10_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_10_PRIO_10_MASK 0x7u
#define RV_PLIC_PRIO_10_PRIO_10_OFFSET 0
#define RV_PLIC_PRIO_10_PRIO_10_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_10_PRIO_10_MASK, .index = RV_PLIC_PRIO_10_PRIO_10_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_11_REG_OFFSET 0x2c
#define RV_PLIC_PRIO_11_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_11_PRIO_11_MASK 0x7u
#define RV_PLIC_PRIO_11_PRIO_11_OFFSET 0
#define RV_PLIC_PRIO_11_PRIO_11_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_11_PRIO_11_MASK, .index = RV_PLIC_PRIO_11_PRIO_11_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_12_REG_OFFSET 0x30
#define RV_PLIC_PRIO_12_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_12_PRIO_12_MASK 0x7u
#define RV_PLIC_PRIO_12_PRIO_12_OFFSET 0
#define RV_PLIC_PRIO_12_PRIO_12_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_12_PRIO_12_MASK, .index = RV_PLIC_PRIO_12_PRIO_12_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_13_REG_OFFSET 0x34
#define RV_PLIC_PRIO_13_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_13_PRIO_13_MASK 0x7u
#define RV_PLIC_PRIO_13_PRIO_13_OFFSET 0
#define RV_PLIC_PRIO_13_PRIO_13_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_13_PRIO_13_MASK, .index = RV_PLIC_PRIO_13_PRIO_13_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_14_REG_OFFSET 0x38
#define RV_PLIC_PRIO_14_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_14_PRIO_14_MASK 0x7u
#define RV_PLIC_PRIO_14_PRIO_14_OFFSET 0
#define RV_PLIC_PRIO_14_PRIO_14_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_14_PRIO_14_MASK, .index = RV_PLIC_PRIO_14_PRIO_14_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_15_REG_OFFSET 0x3c
#define RV_PLIC_PRIO_15_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_15_PRIO_15_MASK 0x7u
#define RV_PLIC_PRIO_15_PRIO_15_OFFSET 0
#define RV_PLIC_PRIO_15_PRIO_15_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_15_PRIO_15_MASK, .index = RV_PLIC_PRIO_15_PRIO_15_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_16_REG_OFFSET 0x40
#define RV_PLIC_PRIO_16_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_16_PRIO_16_MASK 0x7u
#define RV_PLIC_PRIO_16_PRIO_16_OFFSET 0
#define RV_PLIC_PRIO_16_PRIO_16_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_16_PRIO_16_MASK, .index = RV_PLIC_PRIO_16_PRIO_16_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_17_REG_OFFSET 0x44
#define RV_PLIC_PRIO_17_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_17_PRIO_17_MASK 0x7u
#define RV_PLIC_PRIO_17_PRIO_17_OFFSET 0
#define RV_PLIC_PRIO_17_PRIO_17_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_17_PRIO_17_MASK, .index = RV_PLIC_PRIO_17_PRIO_17_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_18_REG_OFFSET 0x48
#define RV_PLIC_PRIO_18_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_18_PRIO_18_MASK 0x7u
#define RV_PLIC_PRIO_18_PRIO_18_OFFSET 0
#define RV_PLIC_PRIO_18_PRIO_18_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_18_PRIO_18_MASK, .index = RV_PLIC_PRIO_18_PRIO_18_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_19_REG_OFFSET 0x4c
#define RV_PLIC_PRIO_19_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_19_PRIO_19_MASK 0x7u
#define RV_PLIC_PRIO_19_PRIO_19_OFFSET 0
#define RV_PLIC_PRIO_19_PRIO_19_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_19_PRIO_19_MASK, .index = RV_PLIC_PRIO_19_PRIO_19_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_20_REG_OFFSET 0x50
#define RV_PLIC_PRIO_20_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_20_PRIO_20_MASK 0x7u
#define RV_PLIC_PRIO_20_PRIO_20_OFFSET 0
#define RV_PLIC_PRIO_20_PRIO_20_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_20_PRIO_20_MASK, .index = RV_PLIC_PRIO_20_PRIO_20_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_21_REG_OFFSET 0x54
#define RV_PLIC_PRIO_21_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_21_PRIO_21_MASK 0x7u
#define RV_PLIC_PRIO_21_PRIO_21_OFFSET 0
#define RV_PLIC_PRIO_21_PRIO_21_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_21_PRIO_21_MASK, .index = RV_PLIC_PRIO_21_PRIO_21_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_22_REG_OFFSET 0x58
#define RV_PLIC_PRIO_22_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_22_PRIO_22_MASK 0x7u
#define RV_PLIC_PRIO_22_PRIO_22_OFFSET 0
#define RV_PLIC_PRIO_22_PRIO_22_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_22_PRIO_22_MASK, .index = RV_PLIC_PRIO_22_PRIO_22_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_23_REG_OFFSET 0x5c
#define RV_PLIC_PRIO_23_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_23_PRIO_23_MASK 0x7u
#define RV_PLIC_PRIO_23_PRIO_23_OFFSET 0
#define RV_PLIC_PRIO_23_PRIO_23_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_23_PRIO_23_MASK, .index = RV_PLIC_PRIO_23_PRIO_23_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_24_REG_OFFSET 0x60
#define RV_PLIC_PRIO_24_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_24_PRIO_24_MASK 0x7u
#define RV_PLIC_PRIO_24_PRIO_24_OFFSET 0
#define RV_PLIC_PRIO_24_PRIO_24_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_24_PRIO_24_MASK, .index = RV_PLIC_PRIO_24_PRIO_24_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_25_REG_OFFSET 0x64
#define RV_PLIC_PRIO_25_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_25_PRIO_25_MASK 0x7u
#define RV_PLIC_PRIO_25_PRIO_25_OFFSET 0
#define RV_PLIC_PRIO_25_PRIO_25_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_25_PRIO_25_MASK, .index = RV_PLIC_PRIO_25_PRIO_25_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_26_REG_OFFSET 0x68
#define RV_PLIC_PRIO_26_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_26_PRIO_26_MASK 0x7u
#define RV_PLIC_PRIO_26_PRIO_26_OFFSET 0
#define RV_PLIC_PRIO_26_PRIO_26_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_26_PRIO_26_MASK, .index = RV_PLIC_PRIO_26_PRIO_26_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_27_REG_OFFSET 0x6c
#define RV_PLIC_PRIO_27_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_27_PRIO_27_MASK 0x7u
#define RV_PLIC_PRIO_27_PRIO_27_OFFSET 0
#define RV_PLIC_PRIO_27_PRIO_27_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_27_PRIO_27_MASK, .index = RV_PLIC_PRIO_27_PRIO_27_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_28_REG_OFFSET 0x70
#define RV_PLIC_PRIO_28_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_28_PRIO_28_MASK 0x7u
#define RV_PLIC_PRIO_28_PRIO_28_OFFSET 0
#define RV_PLIC_PRIO_28_PRIO_28_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_28_PRIO_28_MASK, .index = RV_PLIC_PRIO_28_PRIO_28_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_29_REG_OFFSET 0x74
#define RV_PLIC_PRIO_29_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_29_PRIO_29_MASK 0x7u
#define RV_PLIC_PRIO_29_PRIO_29_OFFSET 0
#define RV_PLIC_PRIO_29_PRIO_29_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_29_PRIO_29_MASK, .index = RV_PLIC_PRIO_29_PRIO_29_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_30_REG_OFFSET 0x78
#define RV_PLIC_PRIO_30_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_30_PRIO_30_MASK 0x7u
#define RV_PLIC_PRIO_30_PRIO_30_OFFSET 0
#define RV_PLIC_PRIO_30_PRIO_30_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_30_PRIO_30_MASK, .index = RV_PLIC_PRIO_30_PRIO_30_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_31_REG_OFFSET 0x7c
#define RV_PLIC_PRIO_31_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_31_PRIO_31_MASK 0x7u
#define RV_PLIC_PRIO_31_PRIO_31_OFFSET 0
#define RV_PLIC_PRIO_31_PRIO_31_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_31_PRIO_31_MASK, .index = RV_PLIC_PRIO_31_PRIO_31_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_32_REG_OFFSET 0x80
#define RV_PLIC_PRIO_32_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_32_PRIO_32_MASK 0x7u
#define RV_PLIC_PRIO_32_PRIO_32_OFFSET 0
#define RV_PLIC_PRIO_32_PRIO_32_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_32_PRIO_32_MASK, .index = RV_PLIC_PRIO_32_PRIO_32_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_33_REG_OFFSET 0x84
#define RV_PLIC_PRIO_33_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_33_PRIO_33_MASK 0x7u
#define RV_PLIC_PRIO_33_PRIO_33_OFFSET 0
#define RV_PLIC_PRIO_33_PRIO_33_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_33_PRIO_33_MASK, .index = RV_PLIC_PRIO_33_PRIO_33_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_34_REG_OFFSET 0x88
#define RV_PLIC_PRIO_34_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_34_PRIO_34_MASK 0x7u
#define RV_PLIC_PRIO_34_PRIO_34_OFFSET 0
#define RV_PLIC_PRIO_34_PRIO_34_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_34_PRIO_34_MASK, .index = RV_PLIC_PRIO_34_PRIO_34_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_35_REG_OFFSET 0x8c
#define RV_PLIC_PRIO_35_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_35_PRIO_35_MASK 0x7u
#define RV_PLIC_PRIO_35_PRIO_35_OFFSET 0
#define RV_PLIC_PRIO_35_PRIO_35_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_35_PRIO_35_MASK, .index = RV_PLIC_PRIO_35_PRIO_35_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_36_REG_OFFSET 0x90
#define RV_PLIC_PRIO_36_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_36_PRIO_36_MASK 0x7u
#define RV_PLIC_PRIO_36_PRIO_36_OFFSET 0
#define RV_PLIC_PRIO_36_PRIO_36_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_36_PRIO_36_MASK, .index = RV_PLIC_PRIO_36_PRIO_36_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_37_REG_OFFSET 0x94
#define RV_PLIC_PRIO_37_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_37_PRIO_37_MASK 0x7u
#define RV_PLIC_PRIO_37_PRIO_37_OFFSET 0
#define RV_PLIC_PRIO_37_PRIO_37_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_37_PRIO_37_MASK, .index = RV_PLIC_PRIO_37_PRIO_37_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_38_REG_OFFSET 0x98
#define RV_PLIC_PRIO_38_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_38_PRIO_38_MASK 0x7u
#define RV_PLIC_PRIO_38_PRIO_38_OFFSET 0
#define RV_PLIC_PRIO_38_PRIO_38_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_38_PRIO_38_MASK, .index = RV_PLIC_PRIO_38_PRIO_38_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_39_REG_OFFSET 0x9c
#define RV_PLIC_PRIO_39_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_39_PRIO_39_MASK 0x7u
#define RV_PLIC_PRIO_39_PRIO_39_OFFSET 0
#define RV_PLIC_PRIO_39_PRIO_39_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_39_PRIO_39_MASK, .index = RV_PLIC_PRIO_39_PRIO_39_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_40_REG_OFFSET 0xa0
#define RV_PLIC_PRIO_40_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_40_PRIO_40_MASK 0x7u
#define RV_PLIC_PRIO_40_PRIO_40_OFFSET 0
#define RV_PLIC_PRIO_40_PRIO_40_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_40_PRIO_40_MASK, .index = RV_PLIC_PRIO_40_PRIO_40_OFFSET })

// Interrupt Source Priority
#define RV_PLIC_PRIO_41_REG_OFFSET 0xa4
#define RV_PLIC_PRIO_41_REG_RESVAL 0x0u
#define RV_PLIC_PRIO_41_PRIO_41_MASK 0x7u
#define RV_PLIC_PRIO_41_PRIO_41_OFFSET 0
#define RV_PLIC_PRIO_41_PRIO_41_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_PRIO_41_PRIO_41_MASK, .index = RV_PLIC_PRIO_41_PRIO_41_OFFSET })

// Interrupt Pending (common parameters)
#define RV_PLIC_IP_P_FIELD_WIDTH 1
#define RV_PLIC_IP_MULTIREG_COUNT 2

// Interrupt Pending
#define RV_PLIC_IP_0_REG_OFFSET 0x1000
#define RV_PLIC_IP_0_REG_RESVAL 0x0u
#define RV_PLIC_IP_0_P_0_BIT 0
#define RV_PLIC_IP_0_P_1_BIT 1
#define RV_PLIC_IP_0_P_2_BIT 2
#define RV_PLIC_IP_0_P_3_BIT 3
#define RV_PLIC_IP_0_P_4_BIT 4
#define RV_PLIC_IP_0_P_5_BIT 5
#define RV_PLIC_IP_0_P_6_BIT 6
#define RV_PLIC_IP_0_P_7_BIT 7
#define RV_PLIC_IP_0_P_8_BIT 8
#define RV_PLIC_IP_0_P_9_BIT 9
#define RV_PLIC_IP_0_P_10_BIT 10
#define RV_PLIC_IP_0_P_11_BIT 11
#define RV_PLIC_IP_0_P_12_BIT 12
#define RV_PLIC_IP_0_P_13_BIT 13
#define RV_PLIC_IP_0_P_14_BIT 14
#define RV_PLIC_IP_0_P_15_BIT 15
#define RV_PLIC_IP_0_P_16_BIT 16
#define RV_PLIC_IP_0_P_17_BIT 17
#define RV_PLIC_IP_0_P_18_BIT 18
#define RV_PLIC_IP_0_P_19_BIT 19
#define RV_PLIC_IP_0_P_20_BIT 20
#define RV_PLIC_IP_0_P_21_BIT 21
#define RV_PLIC_IP_0_P_22_BIT 22
#define RV_PLIC_IP_0_P_23_BIT 23
#define RV_PLIC_IP_0_P_24_BIT 24
#define RV_PLIC_IP_0_P_25_BIT 25
#define RV_PLIC_IP_0_P_26_BIT 26
#define RV_PLIC_IP_0_P_27_BIT 27
#define RV_PLIC_IP_0_P_28_BIT 28
#define RV_PLIC_IP_0_P_29_BIT 29
#define RV_PLIC_IP_0_P_30_BIT 30
#define RV_PLIC_IP_0_P_31_BIT 31

// Interrupt Pending
#define RV_PLIC_IP_1_REG_OFFSET 0x1004
#define RV_PLIC_IP_1_REG_RESVAL 0x0u
#define RV_PLIC_IP_1_P_32_BIT 0
#define RV_PLIC_IP_1_P_33_BIT 1
#define RV_PLIC_IP_1_P_34_BIT 2
#define RV_PLIC_IP_1_P_35_BIT 3
#define RV_PLIC_IP_1_P_36_BIT 4
#define RV_PLIC_IP_1_P_37_BIT 5
#define RV_PLIC_IP_1_P_38_BIT 6
#define RV_PLIC_IP_1_P_39_BIT 7
#define RV_PLIC_IP_1_P_40_BIT 8
#define RV_PLIC_IP_1_P_41_BIT 9

// Interrupt Enable for Target 0 (common parameters)
#define RV_PLIC_IE0_E_FIELD_WIDTH 1
#define RV_PLIC_IE0_MULTIREG_COUNT 2

// Interrupt Enable for Target 0
#define RV_PLIC_IE0_0_REG_OFFSET 0x2000
#define RV_PLIC_IE0_0_REG_RESVAL 0x0u
#define RV_PLIC_IE0_0_E_0_BIT 0
#define RV_PLIC_IE0_0_E_1_BIT 1
#define RV_PLIC_IE0_0_E_2_BIT 2
#define RV_PLIC_IE0_0_E_3_BIT 3
#define RV_PLIC_IE0_0_E_4_BIT 4
#define RV_PLIC_IE0_0_E_5_BIT 5
#define RV_PLIC_IE0_0_E_6_BIT 6
#define RV_PLIC_IE0_0_E_7_BIT 7
#define RV_PLIC_IE0_0_E_8_BIT 8
#define RV_PLIC_IE0_0_E_9_BIT 9
#define RV_PLIC_IE0_0_E_10_BIT 10
#define RV_PLIC_IE0_0_E_11_BIT 11
#define RV_PLIC_IE0_0_E_12_BIT 12
#define RV_PLIC_IE0_0_E_13_BIT 13
#define RV_PLIC_IE0_0_E_14_BIT 14
#define RV_PLIC_IE0_0_E_15_BIT 15
#define RV_PLIC_IE0_0_E_16_BIT 16
#define RV_PLIC_IE0_0_E_17_BIT 17
#define RV_PLIC_IE0_0_E_18_BIT 18
#define RV_PLIC_IE0_0_E_19_BIT 19
#define RV_PLIC_IE0_0_E_20_BIT 20
#define RV_PLIC_IE0_0_E_21_BIT 21
#define RV_PLIC_IE0_0_E_22_BIT 22
#define RV_PLIC_IE0_0_E_23_BIT 23
#define RV_PLIC_IE0_0_E_24_BIT 24
#define RV_PLIC_IE0_0_E_25_BIT 25
#define RV_PLIC_IE0_0_E_26_BIT 26
#define RV_PLIC_IE0_0_E_27_BIT 27
#define RV_PLIC_IE0_0_E_28_BIT 28
#define RV_PLIC_IE0_0_E_29_BIT 29
#define RV_PLIC_IE0_0_E_30_BIT 30
#define RV_PLIC_IE0_0_E_31_BIT 31

// Interrupt Enable for Target 0
#define RV_PLIC_IE0_1_REG_OFFSET 0x2004
#define RV_PLIC_IE0_1_REG_RESVAL 0x0u
#define RV_PLIC_IE0_1_E_32_BIT 0
#define RV_PLIC_IE0_1_E_33_BIT 1
#define RV_PLIC_IE0_1_E_34_BIT 2
#define RV_PLIC_IE0_1_E_35_BIT 3
#define RV_PLIC_IE0_1_E_36_BIT 4
#define RV_PLIC_IE0_1_E_37_BIT 5
#define RV_PLIC_IE0_1_E_38_BIT 6
#define RV_PLIC_IE0_1_E_39_BIT 7
#define RV_PLIC_IE0_1_E_40_BIT 8
#define RV_PLIC_IE0_1_E_41_BIT 9

// Threshold of priority for Target 0
#define RV_PLIC_THRESHOLD0_REG_OFFSET 0x200000
#define RV_PLIC_THRESHOLD0_REG_RESVAL 0x0u
#define RV_PLIC_THRESHOLD0_THRESHOLD0_MASK 0x7u
#define RV_PLIC_THRESHOLD0_THRESHOLD0_OFFSET 0
#define RV_PLIC_THRESHOLD0_THRESHOLD0_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_THRESHOLD0_THRESHOLD0_MASK, .index = RV_PLIC_THRESHOLD0_THRESHOLD0_OFFSET })

// Claim interrupt by read, complete interrupt by write for Target 0.
#define RV_PLIC_CC0_REG_OFFSET 0x200004
#define RV_PLIC_CC0_REG_RESVAL 0x0u
#define RV_PLIC_CC0_CC0_MASK 0x3fu
#define RV_PLIC_CC0_CC0_OFFSET 0
#define RV_PLIC_CC0_CC0_FIELD \
  ((bitfield_field32_t) { .mask = RV_PLIC_CC0_CC0_MASK, .index = RV_PLIC_CC0_CC0_OFFSET })

// msip for Hart 0.
#define RV_PLIC_MSIP0_REG_OFFSET 0x4000000
#define RV_PLIC_MSIP0_REG_RESVAL 0x0u
#define RV_PLIC_MSIP0_MSIP0_BIT 0

// Alert Test Register.
#define RV_PLIC_ALERT_TEST_REG_OFFSET 0x4004000
#define RV_PLIC_ALERT_TEST_REG_RESVAL 0x80000000u
#define RV_PLIC_ALERT_TEST_FATAL_FAULT_BIT 0
#define RV_PLIC_ALERT_TEST_REGWEN_BIT 31

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _RV_PLIC_REG_DEFS_
// End generated register defines for rv_plic