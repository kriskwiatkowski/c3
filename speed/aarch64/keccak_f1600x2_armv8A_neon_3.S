/*
 * Copyright (C) 2024 PQShield, LTD
 *
 * This software is provided only to PQShield, LTD’s
 * customers and partners, pursuant to the terms and
 * conditions of a separate written agreement with
 * PQShield, LTD or its affiliate. This software may
 * be subject to export or import laws in certain
 * countries.
 *
 * If you do not have an agreement with PQShield, LTD,
 * you may not access, use, modify, or distribute
 * this software. Please contact contact@pqshield.com
 * for more information.
 */

    .arch   armv8-a

// Name registers used by the implementation
COUNT_REG       .req x5
IOTA_BASE_REG   .req x6
IOTA_REG        .req x7
TMP_REG1        .req x8
TMP_REG2        .req x9
TMPS            .req x10
IOTA_VEC_REG    .req v25

.equ L0, 0*16
.equ L1, 1*16
.equ L2, 2*16
.equ L3, 3*16
.equ L4, 4*16
.equ L5, 5*16
.equ L6, 6*16
.equ L7, 7*16
.equ L8, 8*16
.equ L9, 9*16
.equ L10, 10*16
.equ L11, 11*16
.equ L12, 12*16
.equ L13, 13*16
.equ L14, 14*16
.equ L15, 15*16
.equ L16, 16*16
.equ L17, 17*16
.equ L18, 18*16
.equ L19, 19*16
.equ L20, 20*16
.equ L21, 21*16
.equ L22, 22*16
.equ L23, 23*16
.equ L24, 24*16
.equ L25, 25*16
.equ L26, 26*16
.equ L27, 27*16
.equ L28, 28*16
.equ L29, 29*16
.equ L30, 30*16
.equ L31, 31*16

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
    st4 { v8.d-v11.d}[0], [sp], #32
    st4 {v12.d-v15.d}[0], [sp], #32
.endm

// Load callee-saved registers
.macro LDR_PROC_REGS
    sub sp, sp, #64
    ld4 { v8.d-v11.d}[0], [sp], #32
    ld4 {v12.d-v15.d}[0], [sp], #32
    //add sp, sp, #400
.endm

.macro do_Load_State
    mov x8,x0
    add x9,x0,#200
    LD4 {  v0.d- v3.d }[0], [x8], #8*4
    LD4 {  v0.d- v3.d }[1], [x9], #8*4
    LD4 {  v4.d- v7.d }[0], [x8], #8*4
    LD4 {  v4.d- v7.d }[1], [x9], #8*4
    LD4 {  v8.d-v11.d }[0], [x8], #8*4
    LD4 {  v8.d-v11.d }[1], [x9], #8*4
    LD4 { v12.d-v15.d }[0], [x8], #8*4
    LD4 { v12.d-v15.d }[1], [x9], #8*4
    LD4 { v16.d-v19.d }[0], [x8], #8*4
    LD4 { v16.d-v19.d }[1], [x9], #8*4
    LD4 { v20.d-v23.d }[0], [x8], #8*4
    LD4 { v20.d-v23.d }[1], [x9], #8*4
    LD1 { v24.d }[0], [x8]
    LD1 { v24.d }[1], [x9]
.endm

.macro do_Store_State
    mov x8,x0
    add x9,x0,#200
    ST4 {  v0.d- v3.d }[0], [x8], #8*4
    ST4 {  v0.d- v3.d }[1], [x9], #8*4
    ST4 {  v4.d- v7.d }[0], [x8], #8*4
    ST4 {  v4.d- v7.d }[1], [x9], #8*4
    ST4 {  v8.d-v11.d }[0], [x8], #8*4
    ST4 {  v8.d-v11.d }[1], [x9], #8*4
    ST4 { v12.d-v15.d }[0], [x8], #8*4
    ST4 { v12.d-v15.d }[1], [x9], #8*4
    ST4 { v16.d-v19.d }[0], [x8], #8*4
    ST4 { v16.d-v19.d }[1], [x9], #8*4
    ST4 { v20.d-v23.d }[0], [x8], #8*4
    ST4 { v20.d-v23.d }[1], [x9], #8*4
    ST1 { v24.d }[0], [x8]
    ST1 { v24.d }[1], [x9]
.endm

.macro ROR64 dd,aa1,v
    shl  \dd\().2d, \aa1\().2d, #64-\v
    sri  \dd\().2d, \aa1\().2d, #\v
.endm

.macro ROR64T dd,aa1,v,t
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

.macro THETA_CALC_C dd,aa1,aa2,aa3,aa4,aa5,t1,t2
    eor \t1\().16b,\aa1\().16b,\aa2\().16b               // A[_, 0] xor A[_, 2]
    eor \t2\().16b,\aa3\().16b,\aa4\().16b               // A[_, 3] xor A[_, 4]
    eor \dd\().16b, \t1\().16b,\aa5\().16b               //         xor A[_, 5]
    eor \dd\().16b, \dd\().16b, \t2\().16b
.endm

// BIC(c,a1,a2,a3): c = (a1 AND ~a2) XOR a3
// b1 is a temporary register
.macro BICE c,a1,a2,a3,b1
    bic  \b1\().16b, \a1\().16b, \a2\().16b
    eor   \c\().16b, \a3\().16b, \b1\().16b
.endm

.macro do_Full_Theta
    THETA_CALC_C v27,v0,v5,v10,v15,v20,v30,v31 // C0
    THETA_CALC_C v28,v1,v6,v11,v16,v21,v25,v26 // C1
    THETA_CALC_C v29,v2,v7,v12,v17,v22,v30,v31 // C2
    THETA_CALC_C v30,v3,v8,v13,v18,v23,v25,v26 // C3
    THETA_CALC_C v31,v4,v9,v14,v19,v24,v25,v26 // C4

    // D0 (v25)
        str q20, [TMPS, L20] // offload
    ROR64        v25,v28,63
    eor          v25.16b,v31.16b,v25.16b
    // D3 (v26)
        str q21, [TMPS, L21] // offload
    ROR64        v26,v31,63
    eor          v26.16b,v29.16b,v26.16b
    // D1 (v31)  (contention)
        str q22, [TMPS, L22] // offload
    ROR64        v29,v29,63
    eor          v31.16b,v27.16b,v29.16b
    // D4 (v29)
        str q23, [TMPS, L23] // offload
    ROR64        v27,v27,63
    eor          v29.16b,v30.16b,v27.16b
    // D2 (v30)
        str q24, [TMPS, L24] // offload
    ROR64        v30,v30,63
    eor          v30.16b,v28.16b,v30.16b

    // D0->v25, D1->v31, D2->v30, D3->v26, D4->v29
    vD0 .req v25
    vD1 .req v31
    vD2 .req v30
    vD3 .req v26
    vD4 .req v29
    // Define also 'q' registers, so that STR/LDR can be used
    vQ0 .req q27
    vQ1 .req q28
    vQ2 .req q22
    vQ3 .req q23
    vQ4 .req q24

    // Free: v27, v28, v22, v23, v24, v20, v21
    vT0 .req v27
    vT1 .req v28
    vT2 .req v22 // offloaded
    vT3 .req v23 // offloaded
    vT4 .req v24 // offloaded
    vT5 .req v20 // offloaded
    vT6 .req v21 // offloaded

    // y = 0
    eor vT5.16b, v0.16b,vD0.16b
    eor  v0.16b, v6.16b,vD1.16b
        ROR64 vT6,v0,20
    eor v12.16b,v12.16b,vD2.16b
        ROR64 vT2,v12,21
    eor v18.16b,v18.16b,vD3.16b
        ROR64 vT3,v18,43
    eor v0.16b,v24.16b,vD4.16b
        ROR64 vT4,v0,50

    BICE vT0,vT2,vT1,vT5, v0
    BICE vT1,vT3,vT2,vT6, v6
    BICE vT2,vT4,vT3,vT2,v12
    BICE vT3,vT5,vT4,vT3,v18
    BICE vT4,vT6,vT5,vT4, v0

    // Y = 1
    eor vT3.16b,  v3.16b, vD3.16b
        ROR64 vT5,vT3,36
    eor v18.16b,  v9.16b, vD4.16b
        ROR64 vT6,v18,44
    eor v12.16b, v10.16b, vD0.16b
        ROR64 vT2,v12,61
    eor v18.16b, v16.16b, vD1.16b
        ROR64 vT3,v18,19
        ldr q3, [TMPS, L22] // v22 loaded into v3 (TODO move up)
    eor v0.16b, v3.16b,   vD2.16b
        ROR64 vT4, v0,3

    BICE vT0,vT2,vT6,vT5, v9
    BICE vT1,vT3,vT2,vT6, v6
    BICE vT2,vT4,vT3,vT2,v12
    BICE vT3,vT5,vT4,vT3,v18
    BICE vT4,vT6,vT5,vT4, v0

    // Y = 2
        ldr q3, [TMPS, L20] // v20 loaded into v3
    eor v10.16b,  v1.16b, vD1.16b
        ROR64 vT5,v10,63
    eor v18.16b,  v7.16b, vD2.16b
        ROR64 vT6,v18,58
    eor v12.16b, v13.16b, vD3.16b
        ROR64 vT2,v12,39
    eor v16.16b, v19.16b, vD4.16b
        ROR64 vT3,v16,56
    eor v0.16b,  v3.16b,  vD0.16b
        ROR64 vT4, v0,46

    BICE vT0,vT2,vT6,vT5, v6
    BICE vT1,vT3,vT2,vT6,v12
    BICE vT2,vT4,vT3,vT2,v18
    BICE vT3,vT5,vT4,vT3, v9
    BICE vT4,vT6,vT5,vT4, v0

    // Y = 3
        ldr q3, [TMPS, L23] // v23 loaded into v3
    eor v10.16b,  v4.16b, vD4.16b
        ROR64 vT5,v10,37
    eor v18.16b,  v5.16b, vD0.16b
        ROR64 vT6,v18,28
    eor v12.16b, v11.16b, vD1.16b
        ROR64 vT2,v12,54
    eor v16.16b, v17.16b, vD2.16b
        ROR64 vT3,v16,49
    eor v0.16b,  v3.16b, vD3.16b
        ROR64 vT4, v0,8

    BICE vT0,vT2,vT6,vT5, v6
    BICE vT1,vT3,vT2,vT6,v12
    BICE vT2,vT4,vT3,vT2,v18
    BICE vT3,vT5,vT4,vT3, v9
    BICE vT4,vT6,vT5,vT4, v0

    // Y = 3
        ldr q3, [TMPS, L21] // v21 loaded into v3
    eor v10.16b,  v2.16b, vD2.16b
        ROR64 vT5,v10,2
    eor v18.16b,  v8.16b, vD3.16b
        ROR64 vT6,v18,9
    eor v12.16b, v14.16b, vD4.16b
        ROR64 vT2,v12,25
    eor v16.16b, v15.16b, vD0.16b
        ROR64 vT3,v16,23
    eor v0.16b,  v3.16b,  vD1.16b
        ROR64 vT4, v0,62

    BICE vT0,vT2,vT6,vT5, v6
    BICE vT1,vT3,vT2,vT6,v12
    BICE vT2,vT4,vT3,vT2,v18
    BICE vT3,vT5,vT4,vT3, v9
    BICE vT4,vT6,vT5,vT4, v3

    mov v20.16b, vT0.16b
    mov v21.16b, vT1.16b
    mov v22.16b, vT2.16b
    mov v23.16b, vT3.16b
    mov v24.16b, vT4.16b

.endm

// Performs Iota
.macro do_Iota
    add x7, x6, x5, lsl #3
    ld1r {v25.2d}, [x7]
    eor v0.16b, v0.16b, v25.16b
.endm

// SHA3x2 core
.text

#if defined(__APPLE__)
.p2align 4,,15
.globl _keccakf1600x2_asm_3
_keccakf1600x2_asm_3:
#else
.p2align 4,,15
.globl keccakf1600x2_asm_3
.hidden keccakf1600x2_asm_3
.type keccakf1600x2_asm_3, @function
keccakf1600x2_asm_3:
#endif
    STR_PROC_REGS
    // Move pointer to the array storing state to x26
    // Store pointer to IOTA's on the stack
    do_Load_State
    // Load pointer to table storing IOTA's into x6
    ldr_iota_ptr
    // Initialize counter to 0
    mov x5, #0
    // Initialize location of B state
    add TMPS, sp, #64
.Loop:
    do_Full_Theta
    do_Iota
    add x5, x5, #1
    cmp x5, 24
    b.ne .Loop
    do_Store_State
    LDR_PROC_REGS
    blr lr
