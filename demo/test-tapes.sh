#!/usr/bin/env bash
# test-tapes.sh — Verify all systab commands in VHS tape files run correctly.
# Greps Type "systab ..." and Type "EDITOR=... systab ..." lines from *.tape
# files and runs them in order per tape, reporting pass/fail.
#
# Run from the project root: ./demo/test-tapes.sh

set -uo pipefail

# Make ./systab callable as 'systab', matching how tapes reference it
PATH="$PWD:$PATH"
export PATH

TAPE_DIR="demo"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"

passed=0
failed=0
total=0
tape_job_ids=()

if [[ -t 1 ]]; then
  GREEN=$'\033[32m' RED=$'\033[31m' BOLD=$'\033[1m' RESET=$'\033[0m'
else
  GREEN="" RED="" BOLD="" RESET=""
fi

pass() {
  echo "${GREEN}[PASS]${RESET} $1"
  passed=$((passed + 1))
  total=$((total + 1))
}

fail() {
  echo "${RED}[FAIL]${RESET} $1 — $2"
  failed=$((failed + 1))
  total=$((total + 1))
}

# Stop, disable, and remove all unit files created during tape tests
cleanup_tape_jobs() {
  [[ ${#tape_job_ids[@]} -eq 0 ]] && return
  for id in "${tape_job_ids[@]}"; do
    [[ -z "$id" ]] && continue
    for ext in service timer; do
      local f="$SYSTEMD_USER_DIR/systab_${id}.${ext}"
      [[ -f "$f" ]] || continue
      systemctl --user stop "systab_${id}.${ext}" 2>/dev/null || true
      systemctl --user disable "systab_${id}.${ext}" 2>/dev/null || true
      rm -f "$f"
    done
  done
  systemctl --user daemon-reload 2>/dev/null || true
  tape_job_ids=()
}

trap cleanup_tape_jobs EXIT

# Collect any job IDs from command output into tape_job_ids
collect_ids() {
  local id
  while IFS= read -r id; do
    [[ -n "$id" ]] && tape_job_ids+=("$id")
  done < <(sed -n 's/^\(Job\|Service\) created: \([0-9a-f]\{6\}\).*$/\2/p' <<< "$1")
}

# Prepare a tape command for test execution:
#   - EDITOR=nano → EDITOR=cat  (non-interactive; cat exits 0, no file changes)
#   - strip trailing " | less"  (we capture stdout directly)
normalize() {
  local cmd="$1"
  cmd="${cmd//EDITOR=nano/EDITOR=cat}"
  cmd="${cmd% | less}"
  echo "$cmd"
}

# Run all systab commands from one tape file in order
run_tape() {
  local tape="$1"
  local tape_name
  tape_name=$(basename "$tape" .tape)

  echo ""
  echo "${BOLD}=== $tape_name ===${RESET}"

  cleanup_tape_jobs  # each tape starts with a clean slate

  local raw cmd output exit_code
  while IFS= read -r raw; do
    cmd=$(normalize "$raw")
    exit_code=0

    # Pipe /dev/null for commands that read stdin interactively
    if [[ "$cmd" == *"systab -C"* ]] || [[ "$cmd" == *"systab -e"* ]]; then
      output=$(eval "$cmd" < /dev/null 2>&1) || exit_code=$?
    else
      output=$(eval "$cmd" 2>&1) || exit_code=$?
    fi

    collect_ids "$output"

    if [[ $exit_code -eq 0 ]]; then
      pass "$tape_name: $raw"
    else
      fail "$tape_name: $raw" "exit $exit_code: ${output:0:120}"
    fi
  done < <(grep -E '^Type "(systab |EDITOR=)' "$tape" | sed 's/^Type "//; s/"$//')
}

echo "${BOLD}Testing systab commands from VHS tape files...${RESET}"

for tape in "$TAPE_DIR"/*.tape; do
  run_tape "$tape"
done

echo ""
echo "---"
echo "${BOLD}${total} tape commands: ${GREEN}${passed} passed${RESET}, ${RED}${failed} failed${RESET}"
[[ $failed -eq 0 ]]
