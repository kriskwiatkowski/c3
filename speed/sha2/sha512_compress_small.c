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

// Run constants
static const uint64_t K512[] = {
    0x428A2F98D728AE22, 0x7137449123EF65CD, 0xB5C0FBCFEC4D3B2F,
    0xE9B5DBA58189DBBC, 0x3956C25BF348B538, 0x59F111F1B605D019,
    0x923F82A4AF194F9B, 0xAB1C5ED5DA6D8118, 0xD807AA98A3030242,
    0x12835B0145706FBE, 0x243185BE4EE4B28C, 0x550C7DC3D5FFB4E2,
    0x72BE5D74F27B896F, 0x80DEB1FE3B1696B1, 0x9BDC06A725C71235,
    0xC19BF174CF692694, 0xE49B69C19EF14AD2, 0xEFBE4786384F25E3,
    0x0FC19DC68B8CD5B5, 0x240CA1CC77AC9C65, 0x2DE92C6F592B0275,
    0x4A7484AA6EA6E483, 0x5CB0A9DCBD41FBD4, 0x76F988DA831153B5,
    0x983E5152EE66DFAB, 0xA831C66D2DB43210, 0xB00327C898FB213F,
    0xBF597FC7BEEF0EE4, 0xC6E00BF33DA88FC2, 0xD5A79147930AA725,
    0x06CA6351E003826F, 0x142929670A0E6E70, 0x27B70A8546D22FFC,
    0x2E1B21385C26C926, 0x4D2C6DFC5AC42AED, 0x53380D139D95B3DF,
    0x650A73548BAF63DE, 0x766A0ABB3C77B2A8, 0x81C2C92E47EDAEE6,
    0x92722C851482353B, 0xA2BFE8A14CF10364, 0xA81A664BBC423001,
    0xC24B8B70D0F89791, 0xC76C51A30654BE30, 0xD192E819D6EF5218,
    0xD69906245565A910, 0xF40E35855771202A, 0x106AA07032BBD1B8,
    0x19A4C116B8D2D0C8, 0x1E376C085141AB53, 0x2748774CDF8EEB99,
    0x34B0BCB5E19B48A8, 0x391C0CB3C5C95A63, 0x4ED8AA4AE3418ACB,
    0x5B9CCA4F7763E373, 0x682E6FF3D6B2B8A3, 0x748F82EE5DEFB2FC,
    0x78A5636F43172F60, 0x84C87814A1F0AB72, 0x8CC702081A6439EC,
    0x90BEFFFA23631E28, 0xA4506CEBDE82BDE9, 0xBEF9A3F7B2C67915,
    0xC67178F2E372532B, 0xCA273ECEEA26619C, 0xD186B8C721C0C207,
    0xEADA7DD6CDE0EB1E, 0xF57D4F7FEE6ED178, 0x06F067AA72176FBA,
    0x0A637DC5A2C898A6, 0x113F9804BEF90DAE, 0x1B710B35131C471B,
    0x28DB77F523047D84, 0x32CAAB7B40C72493, 0x3C9EBE0A15C9BEBC,
    0x431D67C49C100D4C, 0x4CC5D4BECB3E42B6, 0x597F299CFC657E2A,
    0x5FCB6FAB3AD6FAEC, 0x6C44198C4A475817};

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

static inline uint64_t rot64(uint64_t v, uint64_t s) {
    return (v << (64 - s)) | (v >> s);
}
static inline uint64_t shiftr(uint64_t v, uint64_t s) { return v >> s; }

static inline uint64_t s0(uint64_t x) {
    return rot64(x, 1) ^ rot64(x, 8) ^ shiftr(x, 7);
}
static inline uint64_t s1(uint64_t x) {
    return rot64(x, 19) ^ rot64(x, 61) ^ shiftr(x, 6);
}
static inline uint64_t S0(uint64_t x) {
    return rot64(x, 28) ^ rot64(x, 34) ^ rot64(x, 39);
}
static inline uint64_t S1(uint64_t x) {
    return rot64(x, 14) ^ rot64(x, 18) ^ rot64(x, 41);
}

void compressSHA512_small(uint64_t ctx[8], const uint8_t *in) {
    uint64_t w[16], a, b, c, d, e, f, g, h;
    uint64_t T1, T2;
    size_t i;

    a = ctx[0];
    b = ctx[1];
    c = ctx[2];
    d = ctx[3];
    e = ctx[4];
    f = ctx[5];
    g = ctx[6];
    h = ctx[7];

    for (i = 0; i < 16; i++) { L64(w[i], in + (i * 8)); }

    for (i = 0; i < 80; i++) {
        T1 = h + S1(e) + CH(e, f, g) + K512[i] + w[i % 16];
        T2 = S0(a) + MAJ(a, b, c);
        h  = g;
        g  = f;
        f  = e;
        e  = d + T1;
        d  = c;
        c  = b;
        b  = a;
        a  = T1 + T2;
        w[i % 16] +=
            s1(w[(i + 14) & 15]) + w[(i + 9) & 15] + s0(w[(i + 1) & 15]);
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
