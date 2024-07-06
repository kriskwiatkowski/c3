# Implementation of SHA2 compression function

## Small implementations (generic C)

* ``sha256_compress_small.c``
	Tries to reduce binary size and stack stack.

	- Result on AMD Ryzen 9 5950X @ 2.2GhZ, gcc 13.2.0, -O3: ``4KB, 424 ns, Cycles=1.44231k``
    - Result on AMD Ryzen 9 5950X @ 2.2GhZ, gcc 13.2.0, -Os: ``4KB, 542 ns, Cycles=1.84383k``
	- Result on AMD Ryzen 9 5950X @ 2.2GhZ, clang-17, -O3: ``4KB, 450 ns, Cycles=1.52918k``
    - Result on AMD Ryzen 9 5950X @ 2.2GhZ, clang-17, -Os: ``4KB, 593 ns, Cycles=2.01461k``

* ``sha512_compress_small.c``
	Tries to reduce binary size and stack stack.

	- Result on AMD Ryzen 9 5950X @ 2.2GhZ, gcc 13.2.0, -O3: ``4KB, 424 ns, Cycles=1.44231k``
    - Result on AMD Ryzen 9 5950X @ 2.2GhZ, gcc 13.2.0, -Os: ``4KB, 566 ns, Cycles=1.92558k``
	- Result on AMD Ryzen 9 5950X @ 2.2GhZ, clang-17, -O3: ``4KB, 424 ns, Cycles=1.44231k``
    - Result on AMD Ryzen 9 5950X @ 2.2GhZ, clang-17, -Os: ``4KB, 592 ns, Cycles=2.01443k``
