#!/usr/bin/env bash
# Tiny assertion helpers shared by the test scripts. Source this file.

TESTS_RUN=0
TESTS_FAILED=0

fail() {
  printf '    %s\n' "$*" >&2
  return 1
}

assert_eq() {
  if [[ $1 != "$2" ]]; then
    fail "expected [$2], got [$1]"
  fi
}

assert_file() {
  if [[ ! -f $1 || -L $1 ]]; then
    fail "expected a regular file: $1"
  fi
}

assert_dir() {
  if [[ ! -d $1 || -L $1 ]]; then
    fail "expected a real directory: $1"
  fi
}

assert_missing() {
  if [[ -e $1 || -L $1 ]]; then
    fail "expected nothing at: $1"
  fi
}

assert_link_to() {
  if [[ ! -L $1 ]]; then
    fail "expected a symlink: $1"
    return 1
  fi
  if [[ "$(realpath "$1" 2>/dev/null)" != "$(realpath "$2")" ]]; then
    fail "expected $1 -> $2, got $(readlink "$1")"
  fi
}

assert_mode() {
  local mode
  mode=$(stat -c %a "$1" 2>/dev/null || stat -f %Lp "$1")
  assert_eq "$mode" "$2"
}

# check DESC CMD...: run CMD as one named check and record the result.
check() {
  local desc=$1
  shift
  TESTS_RUN=$((TESTS_RUN + 1))
  if "$@" >/dev/null; then
    printf 'PASS %s\n' "$desc"
  else
    printf 'FAIL %s\n' "$desc"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

finish() {
  printf '\n%d checks, %d failed\n' "$TESTS_RUN" "$TESTS_FAILED"
  [[ $TESTS_FAILED -eq 0 ]]
}
