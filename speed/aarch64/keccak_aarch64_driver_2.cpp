#include <benchmark/benchmark.h>
#include <gbench/src/cycleclock.h>
#include <gbench/src/statistics.h>
#include <stdint.h>
#include <string.h>

extern "C" {
void keccakf1600x2_asm_1(uint64_t *);
void keccakf1600x2_asm_2(uint64_t *);
}

// Utility for reporting cycleclocks.
static inline void add_cycleclock(benchmark::State &st, int64_t cycles) {
    if (benchmark::cycleclock::IsCycleClockEnabled()) {
        st.counters["Cycles"] =
            benchmark::Counter(cycles, benchmark::Counter::kAvgIterations |
                                           benchmark::Counter::kResultNoFormat);
    }
}

static void keccakf1600x2_1(benchmark::State &st) {
    size_t t, total = 0;
    uint64_t state[25 * 2], s2[25 * 2];
    t = benchmark::cycleclock::Now();
    for (auto _: st) {
        keccakf1600x2_asm_1(state);
        benchmark::DoNotOptimize(state);
        benchmark::DoNotOptimize(t);
        benchmark::DoNotOptimize(total);
        benchmark::ClobberMemory();
    }
    add_cycleclock(st, total);
}

static void keccakf1600x2_2(benchmark::State &st) {
    size_t t, total = 0;
    uint64_t state[25 * 2], s2[25 * 2];
    t = benchmark::cycleclock::Now();
    for (auto _: st) {
        keccakf1600x2_asm_2(state);
        benchmark::DoNotOptimize(state);
        benchmark::DoNotOptimize(t);
        benchmark::DoNotOptimize(total);
        benchmark::ClobberMemory();
    }
    total += benchmark::cycleclock::Now() - t;
    add_cycleclock(st, total);
}

BENCHMARK(keccakf1600x2_1)->Unit(benchmark::kNanosecond);
BENCHMARK(keccakf1600x2_2)->Unit(benchmark::kNanosecond);
