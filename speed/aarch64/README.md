# SHA3 implementation for aarch64

## Basic implementations (CPUs without NEON and crypto extentions)

* ``keccak_aarch_1.S``
	Tries to reduce usage of stack. Only counter is stored on stack. Causes a lot of contention on register files.

	Result on RPi5:

* ``keccak_aarch_2.S``
	Uses stack to reduce contention on registers. Offloads pair of registers when computing ``D``. Does Rho+Pi and

	Result on RPi5:

## Implementations that use NEON:

* ``keccak_f1600x2_armv8A_neon_1.S``
	Simple implementation. No stack usage. Theta, Rho+Pi, Chi, Iota.

* ``keccak_f1600x2_armv8A_neon_2.S``
	Tries to reduce contention from ``_1`` by reorganizing Theta.

