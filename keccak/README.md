# SHA3 implementation for aarch64

## Basic implementations (CPUs without NEON and crypto extentions)

* ``keccak_aarch_1.S``
	Tries to reduce usage of stack. Only counter is stored on stack. Causes a lot of contention on register files.

	- Result on RPi5: ``476 ns, Cycles=1.1427k``
	- Result on M2: ``191 ns``

* ``keccak_aarch_2.S``
	Uses stack to reduce contention on registers. Offloads pair of registers when computing ``D``.

	- Result on RPi5: ``453 ns, Cycles=1.08552k``
	- Result on M2: ``195 ns``

## Implementations that use NEON:

* ``keccak_f1600x2_armv8A_neon_1.S``
	Simple implementation. No stack usage. Theta, Rho+Pi, Chi, Iota.

	- Result on RPi5: ``1070 ns, Cycles=2.56713k``
	- Result on M2: ``308 ns``

* ``keccak_f1600x2_armv8A_neon_2.S``
	Tries to reduce contention from ``_1`` by reorganizing Theta.

	- Result on RPi5: ``1092 ns, Cycles=2.62076k``
	- Result on M2: ``315 ns``


