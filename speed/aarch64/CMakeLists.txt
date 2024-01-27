add_executable(
  keccak_aarch64_driver_1
  keccak_aarch64_driver_1.cpp
  keccak_aarch64_1.S
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
