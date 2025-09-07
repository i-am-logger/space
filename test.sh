#!/usr/bin/env bash
set -e

run_test() {
  local name=$1
  local cmd=$2
  
  printf "  %-20s" "$name"
  
  # Run command in background
  $cmd > /dev/null 2>&1 &
  local pid=$!
  
  # Spinner animation
  local spin='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
  local i=0
  while kill -0 $pid 2>/dev/null; do
    i=$(( (i+1) %10 ))
    printf "\r  %-20s %s" "$name" "${spin:$i:1}"  # Fixed: removed ''
    sleep 0.1
  done
  
  # Check exit status
  wait $pid
  if [ $? -eq 0 ]; then
    printf "\r  %-20s \033[0;32m✓\033[0m\n" "$name"
  else
    printf "\r  %-20s \033[0;31m✗\033[0m\n" "$name"
    return 1
  fi
}

echo
echo "Running test suite..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_test "Format check" "cargo fmt --check"
run_test "Clippy lints" "cargo clippy --quiet"
run_test "Type check" "cargo check --quiet"
run_test "Unit tests" "cargo test --quiet"

echo
