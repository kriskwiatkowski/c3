/*
 * Copyright (C) Kris Kwiatkowski, Among Bytes LTD
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation; either version 2 of the License, or (at your
 * option) any later version.  See <http://www.fsf.org/copyleft/gpl.txt>.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for more details.
 *
 * This file is part of C3 library https://github.com/kriskwiatkowski/c3.
 */

// Location of a round counter on a stack
#define KECCAK_ROUNDS 24
#define COUNT_LOC #(8*1)
#define IOTA_LOC #(8*2)
#define COUNT_REG x28
#define IOTA_REG x27

#if !defined(__APPLE__)
.align 8
.type IOTA24,%object
#endif
IOTA24:
    .quad   0x0000000000000001
    .quad   0x0000000000008082
    .quad   0x800000000000808a
    .quad   0x8000000080008000
    .quad   0x000000000000808b
    .quad   0x0000000080000001
    .quad   0x8000000080008081
    .quad   0x8000000000008009
    .quad   0x000000000000008a
    .quad   0x0000000000000088
    .quad   0x0000000080008009
    .quad   0x000000008000000a
IOTA12:
    .quad   0x000000008000808b
    .quad   0x800000000000008b
    .quad   0x8000000000008089
    .quad   0x8000000000008003
    .quad   0x8000000000008002
    .quad   0x8000000000000080
    .quad   0x000000000000800a
    .quad   0x800000008000000a
    .quad   0x8000000080008081
    .quad   0x8000000000008080
    .quad   0x0000000080000001
    .quad   0x8000000080008008
#if !defined(__APPLE__)
.size   IOTA24,.-IOTA24
#endif

#ifdef __APPLE__
.macro ldr_iota_ptr
    adrp IOTA_REG, IOTA24@PAGE
    add  IOTA_REG, IOTA_REG, :lo12:IOTA24@PAGEOFF
.endm
#else
.macro ldr_iota_ptr
    adrp IOTA_REG, IOTA24
    add  IOTA_REG, IOTA_REG, :lo12:IOTA24
.endm
#endif

.macro ldr_iota_val
    ldr IOTA_REG, [sp, IOTA_LOC]
    ldr IOTA_REG, [IOTA_REG, COUNT_REG, lsl #3]
.endm

// Stores callee-saved registers
.macro STR_PROC_REGS
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    stp x29, x30, [sp, #-16]! // LR and SP
    // TODO: will crash on Mac, but see keccak_aarch64_2.S
    sub sp, sp, #32           // Leave a space to store round counter
                              // Note, sp address must be 16-byte aligned
.endm

// Load callee-saved registers
.macro LDR_PROC_REGS
    add sp, sp, #32
    ldp x29, x30, [sp], #16
    ldp x27, x28, [sp], #16
    ldp x25, x26, [sp], #16
    ldp x23, x24, [sp], #16
    ldp x21, x22, [sp], #16
    ldp x19, x20, [sp], #16
.endm

.macro LDRST
    mov x26,x0
    ldp x0,x1,  [x26,#16*0]
    ldp x2,x3,  [x26,#16*1]
    ldp x4,x5,  [x26,#16*2]
    ldp x6,x7,  [x26,#16*3]
    ldp x8,x9,  [x26,#16*4]
    ldp x10,x11,[x26,#16*5]
    ldp x12,x13,[x26,#16*6]
    ldp x14,x15,[x26,#16*7]
    ldp x16,x17,[x26,#16*8]
    ldp x25,x19,[x26,#16*9] // don't use x18 (platform reg.)
    ldp x20,x21,[x26,#16*10]
    ldp x22,x23,[x26,#16*11]
    ldr x24,    [x26,#16*12]
.endm

.macro STRST
    stp x0,x1,  [x26,#16*0]
    stp x2,x3,  [x26,#16*1]
    stp x4,x5,  [x26,#16*2]
    stp x6,x7,  [x26,#16*3]
    stp x8,x9,  [x26,#16*4]
    stp x10,x11,[x26,#16*5]
    stp x12,x13,[x26,#16*6]
    stp x14,x15,[x26,#16*7]
    stp x16,x17,[x26,#16*8]
    stp x25,x19,[x26,#16*9]
    stp x20,x21,[x26,#16*10]
    stp x22,x23,[x26,#16*11]
    str x24,    [x26,#16*12]
.endm

// Theta - Calculate C[x, (z-1) mod 64)
.macro THETA_CALC_C dd,aa1,aa2,aa3,aa4,aa5,t1,t2
    eor \t1,\aa1,\aa2               // A[_, 0] xor A[_, 2]
    eor \t2,\aa3,\aa4               // A[_, 3] xor A[_, 4]
    eor \dd,\t1, \aa5               //         xor A[_, 5]
    eor \dd,\dd, \t2
.endm

// A[x,y,z] = A[x,y,z] xor D[x]
.macro THETA_XOR_A aa1,aa2,aa3,aa4,aa5,c0
    eor \aa1,\aa1,\c0
    eor \aa2,\aa2,\c0
    eor \aa3,\aa3,\c0
    eor \aa4,\aa4,\c0
    eor \aa5,\aa5,\c0
.endm

.macro CHI aa1,aa2,aa3,aa4,aa5,c1,c2,c3,c4
    bic  \c1,\aa3,\aa2
    bic  \c2,\aa4,\aa3
    bic  \c3,\aa5,\aa4
    bic  \c4,\aa1,\aa5
        eor \aa3,\aa3, \c3
    bic  \c3,\aa2,\aa1
    eor \aa1,\aa1, \c1
    eor \aa2,\aa2, \c2
    eor \aa4,\aa4, \c4
    eor \aa5,\aa5, \c3
.endm

.macro ldr_count
    ldr COUNT_REG, [sp, COUNT_LOC]
.endm

.macro str_count
    str COUNT_REG, [sp, COUNT_LOC]
.endm

.macro full_round
    str_count

    ////////////////////////////////////////// Theta
    // D[0]
    THETA_CALC_C       x27,x4,x9,x14,x19,x24,x27,x29        // C4 -> x27
    THETA_CALC_C       x28,x0,x5,x10,x15,x20,x28,x30        // C0 -> x28: calculate before updating A
    THETA_CALC_C       x29,x1,x6,x11,x16,x21,x29,x30        // C1 -> x29
    eor x30, x27, x29, ror #63                              // D0
    THETA_XOR_A        x0,x5,x10,x15,x20,x30

    // D[2]
    THETA_CALC_C       x27,x3,x8,x13,x25,x23,x27,x30        // C3 -> x27
    eor x30, x29, x27, ror #63                              // D2
    THETA_CALC_C       x29,x2,x7,x12,x17,x22,x29,x27        // C2 -> x29: calculate before updating A
    THETA_XOR_A        x2,x7,x12,x17,x22,x30

    // D[1]
    eor x30, x28, x29, ror #63                              // D1
    THETA_XOR_A        x1,x6,x11,x16,x21,x30

    // D[4]
    THETA_CALC_C       x27,x3,x8,x13,x25,x23,x27,x30        // C3 -> x27 : Calculate C3 again
    eor x30, x27, x28, ror #63                              // D4
    THETA_CALC_C       x27,x4,x9,x14,x19,x24,x27,x28        // C4 -> x27 : Calculate C4 again
    THETA_XOR_A        x4,x9,x14,x19,x24,x30

    // D[3]
    eor x30, x29, x27, ror #63                              // D3
    THETA_XOR_A        x3,x8,x13,x25,x23,x30

    ////////////////////////////////////////// Rho
    mov x27, x1
    mov x28, x2
    mov x29, x3
    mov x30, x4

    ror  x1,  x6, #(64 - 44)
    ror  x2, x12, #(64 - 43)
    ror  x3, x25, #(64 - 21)
    ror  x4, x24, #(64 - 14)

    ror  x6,  x9, #(64 - 20)
    ror x12, x13, #(64 - 25)
    ror x25, x17, #(64 - 15)
    ror x24, x21, #(64 -  2)

    ror  x9, x22, #(64 - 61)
    ror x13, x19, #(64 -  8)
    ror x17, x11, #(64 - 10)
    ror x21,  x8, #(64 - 55)

    ror x22, x14, #(64 - 39)
    ror x19, x23, #(64 - 56)
    ror x11,  x7, #(64 -  6)
    ror  x8, x16, #(64 - 45)

    ror x14, x20, #(64 - 18)
    ror x23, x15, #(64 - 41)
    ror  x7, x10, #(64 -  3)
    ror x16,  x5, #(64 - 36)

    ror x20, x28, #(64 - 62)
    ror x15, x30, #(64 - 27)
    ror x10, x27, #(64 -  1)
    ror  x5, x29, #(64 - 28)

    CHI  x0, x1, x2, x3, x4,x27,x28,x29,x30
    CHI  x5, x6, x7, x8, x9,x27,x28,x29,x30
    CHI x10,x11,x12,x13,x14,x27,x28,x29,x30
    CHI x15,x16,x17,x25,x19,x27,x28,x29,x30
    CHI x20,x21,x22,x23,x24,x27,x28,x29,x30

    ldr_count
    ldr_iota_val
    eor x0, x0, IOTA_REG
.endm

#ifdef __APPLE__
.text
.p2align 4,,15
.globl _keccakf1600_asm_1
_keccakf1600_asm_1:
#else
.text
.p2align 4,,15
.globl keccakf1600_asm_1
.hidden keccakf1600_asm_1
.type keccakf1600_asm_1, @function
keccakf1600_asm_1:
#endif
    STR_PROC_REGS
    LDRST

    ldr_iota_ptr
    str IOTA_REG, [sp, IOTA_LOC]
    // Initialize counter to 0
    mov COUNT_REG, #0
.Loop:
    str_count
    full_round
    add COUNT_REG, COUNT_REG, #1
    cmp COUNT_REG, KECCAK_ROUNDS
    b.ne .Loop

    // end
    STRST
    LDR_PROC_REGS
    blr lr
