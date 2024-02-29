#include <assert.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>

extern "C" {
void keccakf1600_asm_1(uint64_t *);
void keccakf1600_asm_2(uint64_t *);
void keccakf1600x2_asm_1(uint64_t *);
void keccakf1600x2_asm_2(uint64_t *);
void keccakf1600x2_asm_3(uint64_t *);
}

int main() {
    uint64_t s1[25], s2[25], s3[2 * 25], s4[2 * 25];
    for (size_t i = 0; i < 25; i++) {
        s1[i] = s2[i] = i;
        s3[i] = s3[25 + i] = s4[i] = s4[25 + i] = i;
    }

    //keccakf1600_asm_1(s1);
    //keccakf1600_asm_2(s2);
    //for (size_t i = 0; i < 5; i++) { printf("%016lx ", s2[i]); }
    keccakf1600x2_asm_1(s3);
    //keccakf1600x2_asm_2(s4);
    for (size_t i = 20; i < 25; i++) { printf("%016lx ", s3[i]); }
    printf("\n");
    keccakf1600x2_asm_3(s4);
    for (size_t i = 20; i < 25; i++) { printf("%016lx ", s4[i]); }
    printf("\n");

    /*
    for (size_t i = 0; i < 25; i++) {
        if (s1[i] != s2[i]) {
            printf("bug scalar %lu\n", i);
            break;
        }

        if (s3[i] != s3[i + 25]) {
            printf("bug both context different %lu %lX %lX\n", i, s3[i],
                   s3[i + 25]);
        }

        if (s1[i] != s3[i]) {
            printf("bug neon1 %lu %lX %lX\n", i, s1[i], s3[i]);
        }

        if (s1[i] != s4[i]) {
            printf("bug neon2 %lu %lX %lX\n", i, s1[i], s3[i]);
        }
    }
    */
}