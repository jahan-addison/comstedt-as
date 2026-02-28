cmake_minimum_required(VERSION 3.16)
project(aslc86k C)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
  message(
    FATAL_ERROR
      "In-source builds are not allowed.\n"
      "Run cmake from a separate build directory:\n"
      "  cmake -B build && cmake --build build")
endif()

set(CMAKE_C_STANDARD 99)

# hashsize.h
add_executable(sieve src/sieve.c)

set(HASHSIZE_INPUT 12000)
set(HASHSIZE_H "${CMAKE_BINARY_DIR}/hashsize.h")

add_custom_command(
  OUTPUT "${HASHSIZE_H}"
  COMMAND
    ${CMAKE_COMMAND} -D SIEVE_EXE=$<TARGET_FILE:sieve> -D
    HASHSIZE_INPUT=${HASHSIZE_INPUT} -D HASHSIZE_H=${HASHSIZE_H} -P
    "${CMAKE_SOURCE_DIR}/cmake/gen_hashsize.cmake"
  DEPENDS sieve
  COMMENT "Generating hashsize.h via sieve ${HASHSIZE_INPUT}"
  VERBATIM)
add_custom_target(gen_hashsize DEPENDS "${HASHSIZE_H}")

# gram.c / gram.h – by bison (required)
find_package(BISON REQUIRED)
find_package(FLEX REQUIRED)

bison_target(
  Grammar src/gram.y "${CMAKE_BINARY_DIR}/gram.c"
  DEFINES_FILE "${CMAKE_BINARY_DIR}/gram.h"
  COMPILE_FLAGS "-y -d -v")
set(GRAM_C "${CMAKE_BINARY_DIR}/gram.c")

# lexer.c – by flex (required)
flex_target(Lexer src/lexer.l "${CMAKE_BINARY_DIR}/lexer.c")
set(LEXER_C "${CMAKE_BINARY_DIR}/lexer.c")

add_flex_bison_dependency(Lexer Grammar)

# Main target
set(SRCS
    src/main.c
    src/file.c
    src/symbol.c
    src/storage.c
    src/macro.c
    src/smach.c
    src/backend.c
    src/dmalloc.c
    src/getopt.c
    "${LEXER_C}"
    "${GRAM_C}")

add_executable(aslc86k ${SRCS})

add_dependencies(aslc86k gen_hashsize)

target_include_directories(
  aslc86k
  PRIVATE "${CMAKE_BINARY_DIR}" # generated hashsize.h / gram.h take precedence
          "${CMAKE_SOURCE_DIR}/include" # static headers + fallback gram.h /
                                        # hashsize.h
)

target_compile_definitions(aslc86k PRIVATE DEBUG DEBUG_MALLOC)
target_compile_options(aslc86k PRIVATE -g)
