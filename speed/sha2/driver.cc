#include <benchmark/benchmark.h>
#include <gbench/src/cycleclock.h>
#include <gbench/src/statistics.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>

extern "C" {
void compressSHA256_small(uint32_t ctx[8], const uint8_t *in);
void compressSHA512_small(uint64_t ctx[8], const uint8_t *in);
}

// Utility for reporting cycleclocks.
static inline void add_cycleclock(benchmark::State &st, int64_t cycles) {
    if (::benchmark::cycleclock::IsCycleClockEnabled()) {
        st.counters["Cycles"] =
            benchmark::Counter(cycles, benchmark::Counter::kAvgIterations |
                                           benchmark::Counter::kResultNoFormat);
    }
}

static void comprSHA2_small(benchmark::State &st) {
    size_t t, total = 0;
    uint8_t msg[64 * 4];
    uint32_t ctx[8];
    t = benchmark::cycleclock::Now();
    for (auto _: st) {
        compressSHA256_small(ctx, msg);
        benchmark::DoNotOptimize(t);
        benchmark::DoNotOptimize(total);
        benchmark::ClobberMemory();
    }
    total += benchmark::cycleclock::Now() - t;
    add_cycleclock(st, total);
}

static void comprSHA512_small(benchmark::State &st) {
    size_t t, total = 0;
    uint8_t msg[64 * 4];
    uint64_t ctx[8];
    t = benchmark::cycleclock::Now();
    for (auto _: st) {
        compressSHA512_small(ctx, msg);
        benchmark::DoNotOptimize(t);
        benchmark::DoNotOptimize(total);
        benchmark::ClobberMemory();
    }
    total += benchmark::cycleclock::Now() - t;
    add_cycleclock(st, total);
}

BENCHMARK(comprSHA2_small)->Unit(benchmark::kNanosecond);
BENCHMARK(comprSHA512_small)->Unit(benchmark::kNanosecond);
