#include <benchmark/benchmark.h>
#include <gbench/src/cycleclock.h>
#include <gbench/src/statistics.h>

extern "C" {
	void func(void);
}

// Utility for reporting cycleclocks.
static inline void add_cycleclock(benchmark::State& st, int64_t cycles) {
        st.counters["Cycles"] =
            benchmark::Counter(cycles,
                benchmark::Counter::kAvgIterations | benchmark::Counter::kResultNoFormat);
}

static void t(benchmark::State &st) {
	size_t t, total = 0;
    for (auto _: st) {
    	t = benchmark::cycleclock::Now();

    	asm("nop");

    	total += benchmark::cycleclock::Now() - t;
    	benchmark::DoNotOptimize(t);
    	benchmark::DoNotOptimize(total);
    	benchmark::ClobberMemory();
    }
    add_cycleclock(st, total);
}

BENCHMARK(t)->Unit(benchmark::kNanosecond);
