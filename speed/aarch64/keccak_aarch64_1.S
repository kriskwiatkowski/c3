#ifdef __APPLE__
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
#else /* !__APPLE__ */
.align 8
.type IOTA24,%object
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
.size   IOTA24,.-IOTA24
#endif

// Stores callee-saved registers
.macro STR_PROC_REGS
    stp x19, x20, [sp, #-16]!
    stp x21, x22, [sp, #-16]!
    stp x23, x24, [sp, #-16]!
    stp x25, x26, [sp, #-16]!
    stp x27, x28, [sp, #-16]!
    stp x29, x30, [sp, #-16]! // LR and SP
.endm

// Load callee-saved registers
.macro LDR_PROC_REGS
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
    ldp x16,x17,[x26,#16*8] // don't use x18 (platform reg.)
    ldp x25,x19,[x26,#16*9]
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
    ror  x5,  x5, #(64 - 36)
    ror x10, x10, #(64 -  3)
    ror x15, x15, #(64 - 41)
    ror x20, x20, #(64 - 18)
    ror  x1,  x1, #(64 -  1)
    ror  x6,  x6, #(64 - 44)
    ror x11, x11, #(64 - 10)
    ror x16, x16, #(64 - 45)
    ror x21, x21, #(64 - 2)
    ror  x2,  x2, #(64 - 62)
    ror  x7,  x7, #(64 -  6)
    ror x12, x12, #(64 - 43)
    ror x17, x17, #(64 - 15)
    ror x22, x22, #(64 - 61)
    ror  x3,  x3, #(64 - 28)
    ror  x8,  x8, #(64 - 55)
    ror x13, x13, #(64 - 25)
    ror x25, x25, #(64 - 21)
    ror x23, x23, #(64 - 56)
    ror  x4,  x4, #(64 - 27)
    ror  x9,  x9, #(64 - 20)
    ror x14, x14, #(64 - 39)
    ror x19, x19, #(64 -  8)
    ror x24, x24, #(64 - 14)

    /* Pi-Chi. Those transformations are a result
       of applying Chi(Pi(A)) at the same time. So
       for example:
       Pi(A[0,0]) = A[0,0]
       Pi(A[1,0]) = A[1 + 3*0, 1] = A[1,1]
       Pi(A[2,0]) = A[2 + 3*0, 2] = A[2,2]
       Chi(A[0,0])= A[0,0] XOR ~A[1,0] & A[2,0]
       ... taking transformation Pi into account ...
                  = A[0,0] XOR ~A[1,1] & A[2,2]

       Additionally we apply lane-complementing transform
       to reduce number of NOT operations. */
    orr x27,  x6, x12
    orn x28, x25, x12
    and x29, x25, x24
    orr x30, x24,  x0
    eor x25, x25, x30 // A[18]
    and x30,  x0,  x6 // kt
    eor  x0,  x0, x27 // A[0]
    eor  x6,  x6, x28 // A[6]
    eor x12, x12, x29 // A[12]
    eor x24, x24, x30

    orr x27, x9,x10 // c0
    and x28,x10,x16 // c1
    orn x29,x16,x22 // c2
    orr x30,x22, x3 // c3
    eor x16,x16,x30 // --
    and x30, x3, x9
    eor  x3, x3,x27
    eor  x9, x9,x28
    eor x10,x10,x29
    eor x22,x22,x30

    orr x27, x7,x13
    and x28,x13,x19
    bic x29,x20,x19
    orr x30,x20, x1
    eon x19,x30,x19 // release x30, so it can be reused
    and x30, x1, x7
    eor  x1, x1,x27
    eor  x7, x7,x28
    eor x13,x13,x29
    eor x20,x20,x30

    and x27, x5,x11 // c0
    orr x28,x11,x17 // c1
    orn x29,x23,x17 // c2
    eor x11,x11,x29 // release x29
    and x30,x23, x4 // c3
    orr x29, x4, x5 // c4
    eor  x4, x4,x27
    eor  x5, x5,x28
    eon x17,x17,x30
    eor x23,x23,x29

    bic x27,x14, x8 // c0
    orr x28,x14,x15 // c1
    and x29,x15,x21 // c2
    orr x30,x21, x2 // c3
    eor x14,x14,x29
    and x29, x2, x8 // c4
    eor x15,x15,x30
    eor  x2, x2,x27
    eon  x8,x28, x8
    eor x21,x21,x29

    STRST
    LDR_PROC_REGS

    blr lr
