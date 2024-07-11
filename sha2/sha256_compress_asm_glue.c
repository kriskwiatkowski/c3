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

#include <stddef.h>
#include <stdint.h>

// Round constants
static const uint32_t K256[] = {
    0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1,
    0x923F82A4, 0xAB1C5ED5, 0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3,
    0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174, 0xE49B69C1, 0xEFBE4786,
    0x0FC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
    0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147,
    0x06CA6351, 0x14292967, 0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13,
    0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85, 0xA2BFE8A1, 0xA81A664B,
    0xC24B8B70, 0xC76C51A3, 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
    0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3, 0x4ED8AA4A,
    0x5B9CCA4F, 0x682E6FF3, 0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208,
    0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2};

#define L16_(x) ((((uint16_t)(x)[0]) << 8) | (((uint16_t)(x)[1]) << 0))
#define L32_(x) \
    (((uint32_t)L16_(&(x)[0])) << 16) | ((uint32_t)L16_(&(x)[2])) << 0
#define L64_(x) \
    (((uint64_t)L32_(&(x)[0])) << 32) | ((uint64_t)L32_(&(x)[4])) << 0

#define L32(x, y) \
    do { (x) = L32_(y); } while (0)
#define L64(x, y) \
    do { (x) = L64_(y); } while (0)

#define CH(m, a, b) ((((a) ^ (b)) & (m)) ^ (b))
#define MAJ(x, y, z) CH(y ^ z, x, y)

static inline uint32_t rot32(uint32_t v, uint32_t s) {
    return (v << (32 - s)) | (v >> s);
}
static inline uint32_t shiftr(uint32_t v, uint32_t s) { return v >> s; }
static inline uint32_t s0(uint32_t x) {
    return rot32(x, 7) ^ rot32(x, 18) ^ shiftr(x, 3);
}
static inline uint32_t s1(uint32_t x) {
    return rot32(x, 17) ^ rot32(x, 19) ^ shiftr(x, 10);
}
static inline uint32_t S0(uint32_t x) {
    return rot32(x, 2) ^ rot32(x, 13) ^ rot32(x, 22);
}
static inline uint32_t S1(uint32_t x) {
    return rot32(x, 6) ^ rot32(x, 11) ^ rot32(x, 25);
}

void compressSHA256_asm_glue(uint32_t ctx[8], const uint8_t *in) {
    uint32_t w[64], a, b, c, d, e, f, g, h;
    uint32_t T1, T2;
    size_t i;

    // Init
    // movdqu xmm[0-3]
    for (i = 0; i < 16; i++) { L32(w[i], in + (i * 4)); }

    // Step 1
    // uses xmm[4-8]
    for (i = 16; i < 32; i++) {
        w[i] = s1(w[i - 2]) + w[i - 7] + s0(w[i - 15]) + w[i-16];
    }

    // movdqu xmm0, xmm1
    a = ctx[0];
    b = ctx[1];
    c = ctx[2];
    d = ctx[3];
    e = ctx[4];
    f = ctx[5];
    g = ctx[6];
    h = ctx[7];
    for (i = 0; i < 32; i++) {
        T1 = h + S1(e) + CH(e, f, g) + K256[i] + w[i];
        T2 = S0(a) + MAJ(a, b, c);
        h  = g;
        g  = f;
        f  = e;
        e  = d + T1;
        d  = c;
        c  = b;
        b  = a;
        a  = T1 + T2;
    }

    // Finish off
    for (i = 32; i < 64; i++) {
        w[i] = s1(w[i - 2]) + w[i - 7] + s0(w[i - 15]) + w[i-16];
    }
    // movdqu xmm[2-9]

    for (i = 32; i < 64; i++) {
        T1 = h + S1(e) + CH(e, f, g) + K256[i] + w[i];
        T2 = S0(a) + MAJ(a, b, c);
        h  = g;
        g  = f;
        f  = e;
        e  = d + T1;
        d  = c;
        c  = b;
        b  = a;
        a  = T1 + T2;
    }

    ctx[0] += a;
    ctx[1] += b;
    ctx[2] += c;
    ctx[3] += d;
    ctx[4] += e;
    ctx[5] += f;
    ctx[6] += g;
    ctx[7] += h;
}
