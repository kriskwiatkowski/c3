#include <assert.h>
#include <benchmark/benchmark.h>
#include <gbench/src/cycleclock.h>
#include <gbench/src/statistics.h>
#include <stdint.h>
#include <string.h>

extern "C" {
void keccakf1600x2_asm_1(uint64_t *);
}

// Utility for reporting cycleclocks.
static inline void add_cycleclock(benchmark::State &st, int64_t cycles) {
    if (::benchmark::cycleclock::IsCycleClockEnabled()) {
        st.counters["Cycles"] =
            benchmark::Counter(cycles, benchmark::Counter::kAvgIterations |
                                           benchmark::Counter::kResultNoFormat);
    }
}

static void keccakf1600x2(benchmark::State &st) {
    size_t t, total = 0;
    uint64_t state[25 * 2], s2[25 * 2];
    for (size_t i = 0; i < 25; i++) { state[i] = 1; }
    for (size_t i = 25; i < 50; i++) { state[i] = 2; }
    memcpy(s2, state, sizeof(uint64_t) * 50);
    for (auto _: st) {
        t = benchmark::cycleclock::Now();

        keccakf1600x2_asm_1(state);

        total += benchmark::cycleclock::Now() - t;
        benchmark::DoNotOptimize(t);
        benchmark::DoNotOptimize(total);
        benchmark::ClobberMemory();
    }
    //for (size_t i = 0; i < 50; i++) { assert(state[i] == s2[i]); }
    add_cycleclock(st, total);
}

BENCHMARK(keccakf1600x2)->Unit(benchmark::kNanosecond);
