add_executable(
  sha256_driver_speed
  driver_speed.cc
  sha256_compress_small.c
  sha512_compress_small.c
  sha256_compress_asm_glue.c
)

target_include_directories(
  sha256_driver_speed
  PRIVATE
  ${GBENCH_INC_DIR}
)

target_link_directories(
  sha256_driver_speed
  PRIVATE
  ${GBENCH_LIB_DIR}
)

target_link_libraries(
  sha256_driver_speed
  PRIVATE
  benchmark
  benchmark_main
)

add_executable(
  sha256_driver_test
  driver_test.cc
  sha256_compress_small.c
  sha512_compress_small.c
  sha256_compress_asm_glue.c
)

target_link_libraries(
  sha256_driver_test
  PRIVATE
  GTest::gtest
  GTest::gtest_main
)