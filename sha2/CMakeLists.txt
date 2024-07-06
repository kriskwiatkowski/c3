add_executable(
  sha256_driver_1
  driver.cc
  sha256_compress_small.c
  sha512_compress_small.c
)

target_include_directories(
  sha256_driver_1
  PRIVATE
  ${GBENCH_INC_DIR}
)

target_link_directories(
  sha256_driver_1
  PRIVATE
  ${GBENCH_LIB_DIR}
)

target_link_libraries(
  sha256_driver_1
  PRIVATE
  benchmark
  benchmark_main
)

add_executable(
  sha256_driver_test_1
  driver_test.cc
  sha256_compress_small.c
  sha512_compress_small.c
)

target_link_libraries(
  sha256_driver_test_1
  PRIVATE
  GTest::gtest
  GTest::gtest_main
)