project(corecryptocomponents)

include(ExternalProject)
include(FetchContent)

# Gtest Directories
set(GTEST_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/3rd/gtest)
set(GTEST_INC_DIR ${GTEST_BASE_DIR}/src/googletest/googletest/include)
set(GTEST_LIB_DIR ${GTEST_BASE_DIR}/src/googletest-build/lib)

# Gtest flags
if(MSVC)
set(gtest_force_shared_crt ON CACHE BOOL "Always use msvcrt.dll" FORCE)
endif()
set(gtest_disable_pthreads ON CACHE BOOL "Disable usage of pthreads" FORCE)
set(BUILD_GMOCK OFF CACHE BOOL "Don't build GMock" FORCE)
FetchContent_Declare(
  googletest
  GIT_REPOSITORY https://github.com/google/googletest.git
  GIT_TAG        a3460d1aeeaa43fdf137a6adefef10ba0b59fe4b
  INSTALL_COMMAND "" # don't install when "make install" is called on main project
  PREFIX         ${GTEST_BASE_DIR}
)
FetchContent_MakeAvailable(googletest)

set(GBENCH_BASE_DIR ${CMAKE_CURRENT_BINARY_DIR}/3rd/gbench)
set(GBENCH_INC_DIR
  ${GBENCH_BASE_DIR}/src/gbench/include
  ${GBENCH_BASE_DIR}/src
  ${CMAKE_CURRENT_BINARY_DIR}/3rd/gbench/src/gbench-build/include)
set(GBENCH_LIB_DIR ${GBENCH_BASE_DIR}/src/gbench-build/src)
# Gbench Flags
if(NOT ${CMAKE_TOOLCHAIN_FILE} STREQUAL "")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DCMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE} ")
endif()
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} ")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DBENCHMARK_ENABLE_GTEST_TESTS=ON ")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DBENCHMARK_ENABLE_TESTING=OFF ")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DBENCHMARK_ENABLE_INSTALL=ON ")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DHAVE_POSIX_REGEX:BOOL=OFF ")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DHAVE_STEADY_CLOCK:BOOL=OFF ")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DBUILD_SHARED_LIBS:BOOL=OFF ")
set(GBENCH_EXTRA_FLAGS ${GBENCH_EXTRA_FLAGS} "-DBENCHMARK_DOWNLOAD_DEPENDENCIES=ON")
ExternalProject_Add(
	gbench
	PREFIX         ${GBENCH_BASE_DIR}
	INSTALL_COMMAND "" # don't install when "make install" is called on main project
	GIT_REPOSITORY https://github.com/kriskwiatkowski/benchmark.git
	GIT_TAG        v2.0.1-hdc
	CMAKE_ARGS     ${GBENCH_EXTRA_FLAGS}
)

if (CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
add_subdirectory(keccak)
endif()

add_subdirectory(sha2)

cmake_minimum_required(VERSION 3.24)
set(CMAKE_CXX_STANDARD 17)

enable_language(C)
enable_language(CXX)
enable_language(ASM)
