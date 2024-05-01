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
 */


    .arch   armv8-a

// Number of rounds in the kaccak. Change to 12-1 for TurboShake
.equ KECCAK_ROUNDS, 24
// Register storing round counter
COUNT_REG       .req x5
// Location of a round counter on a stack
IOTA_BASE_REG   .req x6
// Register used to load IOTA
IOTA_REG        .req x7
// Register with populated IOTA (required by SIMD)
IOTA_VEC_REG    .req v25
// Temporary registers
TMP_REG1        .req x8
TMP_REG2        .req x9

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

#if defined(__APPLE__)
.macro ldr_iota_ptr
    adrp IOTA_BASE_REG, IOTA24@PAGE
    add  IOTA_BASE_REG, IOTA_BASE_REG, :lo12:IOTA24@PAGEOFF
.endm
#else
.macro ldr_iota_ptr
    adrp IOTA_BASE_REG, IOTA24
    add  IOTA_BASE_REG, IOTA_BASE_REG, :lo12:IOTA24
.endm
#endif

// Stores callee-saved registers
.macro STR_PROC_REGS
    // Leave a space to store round counter, iota location and
    // temporary value. NOTE: sp address must be 16-byte aligned.
    sub sp, sp, #64
    ST4 { v8.d-v11.d}[0], [sp], #32
    ST4 {v12.d-v15.d}[0], [sp], #32
.endm

// Load callee-saved registers
.macro LDR_PROC_REGS
    sub sp, sp, #64
    LD4 { v8.d-v11.d}[0], [sp], #32
    LD4 {v12.d-v15.d}[0], [sp], #32
.endm

.macro do_Load_State
    mov TMP_REG1,x0
    add TMP_REG2,x0,#200
    LD1 {  v0.d }[0], [TMP_REG1], #8
    LD1 {  v1.d }[0], [TMP_REG1], #8
    LD1 {  v2.d }[0], [TMP_REG1], #8
    LD1 {  v3.d }[0], [TMP_REG1], #8
    LD1 {  v0.d }[1], [TMP_REG2], #8
    LD1 {  v1.d }[1], [TMP_REG2], #8
    LD1 {  v2.d }[1], [TMP_REG2], #8
    LD1 {  v3.d }[1], [TMP_REG2], #8
    LD1 {  v4.d }[0], [TMP_REG1], #8
    LD1 {  v5.d }[0], [TMP_REG1], #8
    LD1 {  v6.d }[0], [TMP_REG1], #8
    LD1 {  v7.d }[0], [TMP_REG1], #8
    LD1 {  v4.d }[1], [TMP_REG2], #8
    LD1 {  v5.d }[1], [TMP_REG2], #8
    LD1 {  v6.d }[1], [TMP_REG2], #8
    LD1 {  v7.d }[1], [TMP_REG2], #8
    LD1 {  v8.d }[0], [TMP_REG1], #8
    LD1 {  v9.d }[0], [TMP_REG1], #8
    LD1 { v10.d }[0], [TMP_REG1], #8
    LD1 { v11.d }[0], [TMP_REG1], #8
    LD1 {  v8.d }[1], [TMP_REG2], #8
    LD1 {  v9.d }[1], [TMP_REG2], #8
    LD1 { v10.d }[1], [TMP_REG2], #8
    LD1 { v11.d }[1], [TMP_REG2], #8
    LD1 { v12.d }[0], [TMP_REG1], #8
    LD1 { v13.d }[0], [TMP_REG1], #8
    LD1 { v14.d }[0], [TMP_REG1], #8
    LD1 { v15.d }[0], [TMP_REG1], #8
    LD1 { v12.d }[1], [TMP_REG2], #8
    LD1 { v13.d }[1], [TMP_REG2], #8
    LD1 { v14.d }[1], [TMP_REG2], #8
    LD1 { v15.d }[1], [TMP_REG2], #8
    LD1 { v16.d }[0], [TMP_REG1], #8
    LD1 { v17.d }[0], [TMP_REG1], #8
    LD1 { v18.d }[0], [TMP_REG1], #8
    LD1 { v19.d }[0], [TMP_REG1], #8
    LD1 { v16.d }[1], [TMP_REG2], #8
    LD1 { v17.d }[1], [TMP_REG2], #8
    LD1 { v18.d }[1], [TMP_REG2], #8
    LD1 { v19.d }[1], [TMP_REG2], #8
    LD1 { v20.d }[0], [TMP_REG1], #8
    LD1 { v21.d }[0], [TMP_REG1], #8
    LD1 { v22.d }[0], [TMP_REG1], #8
    LD1 { v23.d }[0], [TMP_REG1], #8
    LD1 { v20.d }[1], [TMP_REG2], #8
    LD1 { v21.d }[1], [TMP_REG2], #8
    LD1 { v22.d }[1], [TMP_REG2], #8
    LD1 { v23.d }[1], [TMP_REG2], #8
    LD1 { v24.d }[0], [TMP_REG1]
    LD1 { v24.d }[1], [TMP_REG2]
.endm

.macro do_Store_State
    mov TMP_REG1,x0
    add TMP_REG2,x0,#200
    ST1 {  v0.d }[0], [TMP_REG1], #8
    ST1 {  v1.d }[0], [TMP_REG1], #8
    ST1 {  v2.d }[0], [TMP_REG1], #8
    ST1 {  v3.d }[0], [TMP_REG1], #8
    ST1 {  v0.d }[1], [TMP_REG2], #8
    ST1 {  v1.d }[1], [TMP_REG2], #8
    ST1 {  v2.d }[1], [TMP_REG2], #8
    ST1 {  v3.d }[1], [TMP_REG2], #8
    ST1 {  v4.d }[0], [TMP_REG1], #8
    ST1 {  v5.d }[0], [TMP_REG1], #8
    ST1 {  v6.d }[0], [TMP_REG1], #8
    ST1 {  v7.d }[0], [TMP_REG1], #8
    ST1 {  v4.d }[1], [TMP_REG2], #8
    ST1 {  v5.d }[1], [TMP_REG2], #8
    ST1 {  v6.d }[1], [TMP_REG2], #8
    ST1 {  v7.d }[1], [TMP_REG2], #8
    ST1 {  v8.d }[0], [TMP_REG1], #8
    ST1 {  v9.d }[0], [TMP_REG1], #8
    ST1 { v10.d }[0], [TMP_REG1], #8
    ST1 { v11.d }[0], [TMP_REG1], #8
    ST1 {  v8.d }[1], [TMP_REG2], #8
    ST1 {  v9.d }[1], [TMP_REG2], #8
    ST1 { v10.d }[1], [TMP_REG2], #8
    ST1 { v11.d }[1], [TMP_REG2], #8
    ST1 { v12.d }[0], [TMP_REG1], #8
    ST1 { v13.d }[0], [TMP_REG1], #8
    ST1 { v14.d }[0], [TMP_REG1], #8
    ST1 { v15.d }[0], [TMP_REG1], #8
    ST1 { v12.d }[1], [TMP_REG2], #8
    ST1 { v13.d }[1], [TMP_REG2], #8
    ST1 { v14.d }[1], [TMP_REG2], #8
    ST1 { v15.d }[1], [TMP_REG2], #8
    ST1 { v16.d }[0], [TMP_REG1], #8
    ST1 { v17.d }[0], [TMP_REG1], #8
    ST1 { v18.d }[0], [TMP_REG1], #8
    ST1 { v19.d }[0], [TMP_REG1], #8
    ST1 { v16.d }[1], [TMP_REG2], #8
    ST1 { v17.d }[1], [TMP_REG2], #8
    ST1 { v18.d }[1], [TMP_REG2], #8
    ST1 { v19.d }[1], [TMP_REG2], #8
    ST1 { v20.d }[0], [TMP_REG1], #8
    ST1 { v21.d }[0], [TMP_REG1], #8
    ST1 { v22.d }[0], [TMP_REG1], #8
    ST1 { v23.d }[0], [TMP_REG1], #8
    ST1 { v20.d }[1], [TMP_REG2], #8
    ST1 { v21.d }[1], [TMP_REG2], #8
    ST1 { v22.d }[1], [TMP_REG2], #8
    ST1 { v23.d }[1], [TMP_REG2], #8
    ST1 { v24.d }[0], [TMP_REG1]
    ST1 { v24.d }[1], [TMP_REG2]
.endm

.macro ROR64 dd,aa1,v
    shl  \dd\().2d, \aa1\().2d, #64-\v
    sri  \dd\().2d, \aa1\().2d, #\v
.endm

.macro ROR64x2 dd1,dd2,aa1,aa2,v1,v2
    shl  \dd1\().2d, \aa1\().2d, #64-\v1
    shl  \dd2\().2d, \aa2\().2d, #64-\v2
    sri  \dd1\().2d, \aa1\().2d, #\v1
    sri  \dd2\().2d, \aa2\().2d, #\v2
.endm

.macro ROR64x3 dd1,dd2,dd3,aa1,aa2,aa3,v1,v2,v3
    shl  \dd1\().2d, \aa1\().2d, #64-\v1
    shl  \dd2\().2d, \aa2\().2d, #64-\v2
    shl  \dd3\().2d, \aa3\().2d, #64-\v3
    sri  \dd1\().2d, \aa1\().2d, #\v1
    sri  \dd2\().2d, \aa2\().2d, #\v2
    sri  \dd3\().2d, \aa3\().2d, #\v3
.endm

.macro ROR64x4 dd1,dd2,dd3,dd4,aa1,aa2,aa3,aa4,v1,v2,v3,v4
    shl  \dd1\().2d, \aa1\().2d, #64-\v1
    shl  \dd2\().2d, \aa2\().2d, #64-\v2
    shl  \dd3\().2d, \aa3\().2d, #64-\v3
    shl  \dd4\().2d, \aa4\().2d, #64-\v4
    sri  \dd1\().2d, \aa1\().2d, #\v1
    sri  \dd2\().2d, \aa2\().2d, #\v2
    sri  \dd3\().2d, \aa3\().2d, #\v3
    sri  \dd4\().2d, \aa4\().2d, #\v4
.endm

.macro do_Full_Theta
    eor v28.16b,  v1.16b,  v6.16b       // c1
    eor v29.16b,  v2.16b,  v7.16b       // c2
    eor v31.16b,  v4.16b,  v9.16b       // c4
    eor v28.16b, v28.16b, v11.16b       // c1
    eor v29.16b, v29.16b, v12.16b       // c2
    eor v31.16b, v31.16b, v14.16b       // c4
    eor v28.16b, v28.16b, v16.16b       // c1
    eor v29.16b, v29.16b, v17.16b       // c2
    eor v31.16b, v31.16b, v19.16b       // c4
    eor v28.16b, v28.16b, v21.16b       // c1
    eor v29.16b, v29.16b, v22.16b       // c2
    eor v31.16b, v31.16b, v24.16b       // c4

    // v25 = ROR(C1,63), v26 = ROR(C4,63)
    ROR64x2 v25,v26,v28,v31,63,63

    eor v27.16b,  v0.16b,  v5.16b       // c0
    eor v30.16b,  v3.16b,  v8.16b       // c3
    eor v27.16b, v27.16b, v10.16b       // c0
        eor v25.16b, v31.16b, v25.16b   //   D0 = C4 xor ROR(C1,63)
    eor v30.16b, v30.16b, v13.16b       // c3
    eor v27.16b, v27.16b, v15.16b       // c0
    eor v30.16b, v30.16b, v18.16b       // c3
        eor v26.16b, v29.16b, v26.16b   //   D3 = C2 xor ROR(C4,63)
    eor v27.16b, v27.16b, v20.16b       // c0
    eor v30.16b, v30.16b, v23.16b       // c3

    // Update A[] xor D0 and A[] xor D3
    eor  v0.16b,  v0.16b, v25.16b
    eor  v3.16b,  v3.16b, v26.16b
    eor  v5.16b,  v5.16b, v25.16b
    eor  v8.16b,  v8.16b, v26.16b
    eor v10.16b, v10.16b, v25.16b
    eor v13.16b, v13.16b, v26.16b
    eor v15.16b, v15.16b, v25.16b
    eor v18.16b, v18.16b, v26.16b
    eor v20.16b, v20.16b, v25.16b
    eor v23.16b, v23.16b, v26.16b
    // v31 is released now.

    // Calculate D1,2,4 and update A[] xor D1, A[] xor D2, A[] xor D4
    ROR64x3 v25,v26,v31,v27,v29,v30,63,63,63
    eor v26.16b, v27.16b, v26.16b // D1 = C0 xor ROR(C2,63)
    eor v31.16b, v28.16b, v31.16b // D2 = C1 xor ROR(C3,63)
    eor v25.16b, v30.16b, v25.16b // D4 = C3 xor ROR(C0,63)
    eor  v1.16b, v1.16b,v26.16b
    eor  v2.16b, v2.16b,v31.16b
    eor  v4.16b, v4.16b,v25.16b
    eor  v6.16b, v6.16b,v26.16b
    eor  v7.16b, v7.16b,v31.16b
    eor  v9.16b, v9.16b,v25.16b
    eor v11.16b,v11.16b,v26.16b
    eor v12.16b,v12.16b,v31.16b
    eor v14.16b,v14.16b,v25.16b
    eor v16.16b,v16.16b,v26.16b
    eor v17.16b,v17.16b,v31.16b
    eor v19.16b,v19.16b,v25.16b
    eor v21.16b,v21.16b,v26.16b
    eor v22.16b,v22.16b,v31.16b
    eor v24.16b,v24.16b,v25.16b
.endm

.macro do_Rho_Pi
    // Try to double-issue MOVs with SHLi/r. Below is same as:
    //  mov v27.16b, v1.16b
    //  mov v28.16b, v2.16b
    //  mov v29.16b, v3.16b
    //  mov v30.16b, v4.16b
    //  ROR64x4  v1, v2, v3, v4, v6,v12,v18,v24,20,21,43,50
    mov v27.16b, v1.16b
    mov v28.16b, v2.16b   //*
        ROR64 v1, v6, 20  //*
    mov v29.16b, v3.16b   //-
        ROR64 v2, v12, 21 //-
    mov v30.16b, v4.16b   //+
        ROR64 v3, v18, 43 //+
        ROR64 v4, v24, 50

    ROR64x4  v6,v12,v18,v24, v9,v13,v17,v21,44,39,49,62
    ROR64x4  v9,v13,v17,v21,v22,v19,v11, v8, 3,56,54, 9
    ROR64x4 v22,v19,v11, v8,v14,v23, v7,v16,25, 8,58,19
    ROR64x4 v14,v23, v7,v16,v20,v15,v10, v5,46,23,61,28
    ROR64x4 v20,v15,v10, v5,v28,v30,v27,v29, 2,37,63,36
.endm

.macro CHI aa1,aa2,aa3,aa4,aa5,c1,c2,c3,c4,c5
    bic  \c1\().16b,\aa3\().16b,\aa2\().16b
    bic  \c2\().16b,\aa4\().16b,\aa3\().16b
    bic  \c3\().16b,\aa5\().16b,\aa4\().16b
    bic  \c4\().16b,\aa1\().16b,\aa5\().16b
    bic  \c5\().16b,\aa2\().16b,\aa1\().16b
    eor \aa1\().16b,\aa1\().16b, \c1\().16b
    eor \aa2\().16b,\aa2\().16b, \c2\().16b
    eor \aa3\().16b,\aa3\().16b, \c3\().16b
    eor \aa4\().16b,\aa4\().16b, \c4\().16b
    eor \aa5\().16b,\aa5\().16b, \c5\().16b
.endm

.macro do_Full_Chi
    CHI  v0, v1, v2, v3, v4,v26,v27,v28,v29,v30
    CHI  v5, v6, v7, v8, v9,v26,v27,v28,v29,v30
    CHI v10,v11,v12,v13,v14,v26,v27,v28,v29,v30
    CHI v15,v16,v17,v18,v19,v26,v27,v28,v29,v30
    CHI v20,v21,v22,v23,v24,v26,v27,v28,v29,v30
.endm

// Performs Iota
.macro do_Iota
    add IOTA_REG, IOTA_BASE_REG, COUNT_REG, lsl #3
    ld1r {IOTA_VEC_REG.2d}, [IOTA_REG]
    eor v0.16b, v0.16b, IOTA_VEC_REG.16b
.endm

// SHA3x2 core
.text
#if defined(__APPLE__)
.p2align 4,,15
.globl _keccakf1600x2_asm_2
_keccakf1600x2_asm_2:
#else
.p2align 4,,15
.globl keccakf1600x2_asm_2
.hidden keccakf1600x2_asm_2
.type keccakf1600x2_asm_2, @function
keccakf1600x2_asm_2:
#endif
    STR_PROC_REGS
    // Move pointer to the array storing state to x26
    // Store pointer to IOTA's on the stack
    do_Load_State
    // Load pointer to table storing IOTA's into IOTA_BASE_REG
    ldr_iota_ptr
    // Initialize counter to 0
    mov COUNT_REG, #0
.Loop:
    do_Full_Theta
    do_Rho_Pi
    do_Full_Chi
    do_Iota
    add COUNT_REG, COUNT_REG, #1
    cmp COUNT_REG, KECCAK_ROUNDS
    b.ne .Loop

    do_Store_State
    LDR_PROC_REGS
    blr lr
