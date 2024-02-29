add_executable(
  keccak_aarch64_driver_1
  keccak_aarch64_driver_1.cpp
  keccak_aarch64_1.S
  keccak_aarch64_2.S
)

target_include_directories(
  keccak_aarch64_driver_1
  PRIVATE
  ${GBENCH_INC_DIR}
)

target_link_directories(
  keccak_aarch64_driver_1
  PRIVATE
  ${GBENCH_LIB_DIR}
)

target_link_libraries(
  keccak_aarch64_driver_1
  PRIVATE
  benchmark
  benchmark_main
)

add_executable(
  keccak_aarch64_driver_2
  keccak_aarch64_driver_2.cpp
  keccak_f1600x2_armv8A_neon_1.S
  keccak_f1600x2_armv8A_neon_2.S
  keccak_f1600x2_armv8A_neon_3.S
)

target_include_directories(
  keccak_aarch64_driver_2
  PRIVATE
  ${GBENCH_INC_DIR}
)

target_link_directories(
  keccak_aarch64_driver_2
  PRIVATE
  ${GBENCH_LIB_DIR}
)

target_link_libraries(
  keccak_aarch64_driver_2
  PRIVATE
  benchmark
  benchmark_main
)

add_executable(
  keccak_interop
  keccak_interop.cpp
  keccak_aarch64_1.S
  keccak_aarch64_2.S
  keccak_f1600x2_armv8A_neon_1.S
  keccak_f1600x2_armv8A_neon_2.S
  keccak_f1600x2_armv8A_neon_3.S
)

target_include_directories(
  keccak_interop
  PRIVATE
  ${GBENCH_INC_DIR}
)
