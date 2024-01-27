#include <benchmark/benchmark.h>
#include <gbench/src/cycleclock.h>
#include <gbench/src/statistics.h>

#include <stdint.h>

extern "C" {
	void keccakf1600_asm_1(uint64_t *);
}

// Utility for reporting cycleclocks.
static inline void add_cycleclock(benchmark::State& st, int64_t cycles) {
        st.counters["Cycles"] =
            benchmark::Counter(cycles,
                benchmark::Counter::kAvgIterations | benchmark::Counter::kResultNoFormat);
}

static void keccakf1600_asm_1(benchmark::State &st) {
	size_t t, total = 0;
    uint64_t state[25];
    for (auto _: st) {
    	t = benchmark::cycleclock::Now();

    	keccakf1600_asm_1(state);

    	total += benchmark::cycleclock::Now() - t;
    	benchmark::DoNotOptimize(t);
    	benchmark::DoNotOptimize(total);
    	benchmark::ClobberMemory();
    }
    add_cycleclock(st, total);
}

BENCHMARK(keccakf1600_asm_1)->Unit(benchmark::kNanosecond);
