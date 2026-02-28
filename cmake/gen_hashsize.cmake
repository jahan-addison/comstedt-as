# Invoked by add_custom_command in CMakeLists.txt. Variables passed in via -D:
# SIEVE_EXE       – path to the built sieve executable HASHSIZE_INPUT  – numeric
# argument for sieve HASHSIZE_H      – output file path

execute_process(
  COMMAND "${SIEVE_EXE}" "${HASHSIZE_INPUT}"
  OUTPUT_VARIABLE HASHSIZE_VALUE
  OUTPUT_STRIP_TRAILING_WHITESPACE)
file(WRITE "${HASHSIZE_H}" "#define HASHSIZE ${HASHSIZE_VALUE}\n")
