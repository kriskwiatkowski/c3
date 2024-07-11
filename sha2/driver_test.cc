#include <gtest/gtest.h>
#include <stddef.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern "C" {
void compressSHA256_small(uint32_t ctx[8], const uint8_t *in);
void compressSHA512_small(uint64_t ctx[8], const uint8_t *in);
void compressSHA256_asm_glue(uint32_t ctx[8], const uint8_t *in);
}

TEST(Cmp, SHA256) {
    static const uint32_t exp[8] = {0xAF275F6B, 0x5BF0BB70, 0xF029F30D,
                                    0x4126AF13, 0x99D97817, 0x2698AA1D,
                                    0x9DE88817, 0xC0D7449A};
    size_t t, total = 0;
    uint8_t msg1[64 * 4];
    uint32_t ctx1[8];
    ::memset(ctx1, 0, 4 * 8);
    ::memset(msg1, 0, 64 * 4);

    compressSHA256_small(ctx1, msg1);
    compressSHA256_small(ctx1, msg1);
    compressSHA256_small(ctx1, msg1);

    ASSERT_EQ(memcmp(ctx1, exp, 4 * 8), 0);
}

TEST(Cmp, SHA512) {
    static const uint64_t exp[8] = {0x49580642A21FCAC1, 0x7833EC1B30C1BE6C,
                                    0x5AC0E028B88042BC, 0xB86013E56F2EDDED,
                                    0x1A8EE903023043A1, 0xC8C6C2094734A456,
                                    0x6B679187F59D1EB3, 0x187B3A2847136526};
    size_t t, total = 0;
    uint8_t msg1[64 * 4];
    uint64_t ctx1[8];
    ::memset(ctx1, 0, 8 * 8);
    ::memset(msg1, 0, 64 * 4);

    compressSHA512_small(ctx1, msg1);
    compressSHA512_small(ctx1, msg1);
    compressSHA512_small(ctx1, msg1);

    ASSERT_EQ(memcmp(ctx1, exp, 8 * 8), 0);
}

TEST(Cmp, SHA256_GLUE) {
    static const uint32_t exp[8] = {0xAF275F6B, 0x5BF0BB70, 0xF029F30D,
                                    0x4126AF13, 0x99D97817, 0x2698AA1D,
                                    0x9DE88817, 0xC0D7449A};
    size_t t, total = 0;
    uint8_t msg1[64 * 4];
    uint32_t ctx1[8];
    ::memset(ctx1, 0, 4 * 8);
    ::memset(msg1, 0, 64 * 4);

    compressSHA256_asm_glue(ctx1, msg1);
    compressSHA256_asm_glue(ctx1, msg1);
    compressSHA256_asm_glue(ctx1, msg1);

    ASSERT_EQ(memcmp(ctx1, exp, 4 * 8), 0);
}
