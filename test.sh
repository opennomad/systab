#!/usr/bin/env bash
set -euo pipefail

SYSTAB="./systab"
SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"

passed=0
failed=0
total=0

# Colors (disabled if not a terminal)
if [[ -t 1 ]]; then
    GREEN=$'\033[32m' RED=$'\033[31m' BOLD=$'\033[1m' RESET=$'\033[0m'
else
    GREEN="" RED="" BOLD="" RESET=""
fi

# --- Helpers ---

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

# Run command, expect exit 0
assert_success() {
    local desc="$1"; shift
    local output
    if output=$("$@" 2>&1); then
        _last_output="$output"
        pass "$desc"
    else
        _last_output="$output"
        fail "$desc" "expected exit 0, got $?"
    fi
}

# Run command, expect non-zero exit
assert_failure() {
    local desc="$1"; shift
    local output
    if output=$("$@" 2>&1); then
        _last_output="$output"
        fail "$desc" "expected non-zero exit, got 0"
    else
        _last_output="$output"
        pass "$desc"
    fi
}

# Run command, check stdout contains string
assert_output() {
    local desc="$1" expected="$2"; shift 2
    local output
    if output=$("$@" 2>&1); then
        _last_output="$output"
        if [[ "$output" == *"$expected"* ]]; then
            pass "$desc"
        else
            fail "$desc" "output missing \"$expected\""
        fi
    else
        _last_output="$output"
        fail "$desc" "command failed (exit $?)"
    fi
}

# Check that $_last_output contains string
assert_last_output_contains() {
    local desc="$1" expected="$2"
    if [[ "$_last_output" == *"$expected"* ]]; then
        pass "$desc"
    else
        fail "$desc" "output missing \"$expected\""
    fi
}

# Check file exists and contains pattern (grep -q)
assert_file_contains() {
    local desc="$1" file="$2" pattern="$3"
    if [[ ! -f "$file" ]]; then
        fail "$desc" "file not found: $file"
    elif grep -q -e "$pattern" "$file"; then
        pass "$desc"
    else
        fail "$desc" "pattern \"$pattern\" not in $file"
    fi
}

# Track test-created job IDs for targeted cleanup
test_job_ids=()

# Extract job ID from "Job created: <id>", "Service created: <id>", or with name suffix
# Sets _extracted_id and appends to test_job_ids for cleanup tracking
extract_id() {
    _extracted_id=$(sed -n 's/^\(Job\|Service\) created: \([0-9a-f]\{6\}\)\( .*\)\{0,1\}$/\2/p' <<< "$_last_output")
    test_job_ids+=("$_extracted_id")
}

# Remove only test-created systab units and reload
cleanup() {
    local had_units=false
    for id in "${test_job_ids[@]}"; do
        local name="systab_${id}"
        for ext in service timer; do
            local f="$SYSTEMD_USER_DIR/${name}.${ext}"
            [[ -f "$f" ]] || continue
            systemctl --user stop "${name}.${ext}" 2>/dev/null || true
            systemctl --user disable "${name}.${ext}" 2>/dev/null || true
            rm -f "$f"
            had_units=true
        done
    done
    if $had_units; then
        systemctl --user daemon-reload 2>/dev/null || true
    fi
}

# --- Setup ---

_last_output=""
trap cleanup EXIT

echo "${BOLD}Running systab tests...${RESET}"
echo ""

# ============================================================
# Job creation
# ============================================================

echo "${BOLD}--- Job creation ---${RESET}"

assert_output "create recurring job" "Job created:" $SYSTAB -t "every 5 minutes" -c "echo test_recurring"
extract_id; id_recurring=$_extracted_id

assert_output "create one-time job" "Job created:" $SYSTAB -t "in 30 minutes" -c "echo test_onetime"
extract_id; id_onetime=$_extracted_id

if [[ -z "$id_recurring" || -z "$id_onetime" ]]; then
    echo "FATAL: could not extract job IDs, aborting"
    exit 1
fi

# ============================================================
# Status
# ============================================================

echo ""
echo "${BOLD}--- Status ---${RESET}"

assert_output "show status all" "Managed Jobs Status" $SYSTAB -S
assert_last_output_contains "status contains recurring job ID" "$id_recurring"
assert_last_output_contains "status contains one-time job ID" "$id_onetime"

assert_output "show status single job" "$id_recurring" $SYSTAB -S "$id_recurring"

# ============================================================
# Logs
# ============================================================

echo ""
echo "${BOLD}--- Logs ---${RESET}"

assert_output "view logs all" "Logs for" $SYSTAB -L
assert_output "view logs single job" "$id_recurring" $SYSTAB -L "$id_recurring"

# ============================================================
# Disable / Enable
# ============================================================

echo ""
echo "${BOLD}--- Disable / Enable ---${RESET}"

assert_output "disable job" "Disabled:" $SYSTAB -D "$id_recurring"

assert_output "show disabled state" "Disabled" $SYSTAB -S "$id_recurring"

assert_output "disable already disabled" "Already disabled:" $SYSTAB -D "$id_recurring"

assert_output "enable job" "Enabled:" $SYSTAB -E "$id_recurring"

assert_output "enable already enabled" "Already enabled:" $SYSTAB -E "$id_recurring"

# ============================================================
# Notifications
# ============================================================

echo ""
echo "${BOLD}--- Notifications ---${RESET}"

assert_output "create with -i" "Job created:" $SYSTAB -t "every 10 minutes" -c "echo notify_test" -i
extract_id; id_notify=$_extracted_id
assert_file_contains "-i service has ExecStopPost" \
    "$SYSTEMD_USER_DIR/systab_${id_notify}.service" "^ExecStopPost="
assert_file_contains "-i service has notify-send" \
    "$SYSTEMD_USER_DIR/systab_${id_notify}.service" "notify-send"

assert_output "create with -i -o" "Job created:" $SYSTAB -t "every 10 minutes" -c "echo output_test" -i -o
extract_id; id_output=$_extracted_id
assert_file_contains "-i -o service has journalctl" \
    "$SYSTEMD_USER_DIR/systab_${id_output}.service" "journalctl"
assert_file_contains "-i -o service has %%s" \
    "$SYSTEMD_USER_DIR/systab_${id_output}.service" "%%s"

assert_output "create with -i -o 5" "Job created:" $SYSTAB -t "every 10 minutes" -c "echo output5_test" -i -o 5
extract_id; id_output5=$_extracted_id
assert_file_contains "-i -o 5 service has -n 5" \
    "$SYSTEMD_USER_DIR/systab_${id_output5}.service" "-n 5"

# Email notification (only if sendmail/msmtp available)
if command -v sendmail &>/dev/null || command -v msmtp &>/dev/null; then
    assert_output "create with -m" "Job created:" $SYSTAB -t "every 10 minutes" -c "echo mail_test" -m test@example.com
    extract_id; id_mail=$_extracted_id
    assert_file_contains "-m service has ExecStopPost" \
        "$SYSTEMD_USER_DIR/systab_${id_mail}.service" "^ExecStopPost="

    assert_output "create with -i -m" "Job created:" $SYSTAB -t "every 10 minutes" -c "echo both_test" -i -m test@example.com
    extract_id; id_both=$_extracted_id
    local_count=$(grep -c "^ExecStopPost=" "$SYSTEMD_USER_DIR/systab_${id_both}.service")
    if [[ "$local_count" -ge 2 ]]; then
        pass "-i -m service has two ExecStopPost lines"
    else
        fail "-i -m service has two ExecStopPost lines" "found $local_count"
    fi
else
    echo "  (skipping email notification tests — no sendmail/msmtp)"
fi

# ============================================================
# Time format parsing
# ============================================================

echo ""
echo "${BOLD}--- Time format parsing ---${RESET}"

# Source parse_time from systab (we need the function)
# We can call it by running systab in a subshell that only defines the function
parse_time_test() {
    local input="$1" expected="$2"
    # Run parse_time via bash sourcing
    local result
    if result=$(bash -c '
        source <(sed -n "/^parse_time()/,/^}/p" ./systab; sed -n "/^error()/,/^}/p" ./systab; sed -n "/^is_recurring()/,/^}/p" ./systab)
        parse_time "$1"
    ' _ "$input" 2>&1); then
        if [[ "$result" == "$expected" ]]; then
            pass "parse_time '$input' -> '$expected'"
        else
            fail "parse_time '$input'" "got '$result', expected '$expected'"
        fi
    else
        fail "parse_time '$input'" "failed: $result"
    fi
}

parse_time_test "every 5 minutes" "*:0/5"
parse_time_test "every day at 2am" "*-*-* 02:00:00"
parse_time_test "daily" "daily"
parse_time_test "hourly" "hourly"
parse_time_test "every monday at 9am" "Mon *-*-* 09:00:00"
parse_time_test "*:0/15" "*:0/15"
parse_time_test "every minute" "*:*"
parse_time_test "every hour" "hourly"
parse_time_test "weekly" "weekly"
parse_time_test "monthly" "monthly"

# "in 5 minutes" produces an absolute timestamp — just check it doesn't fail
assert_success "parse_time 'in 5 minutes' succeeds" bash -c '
    source <(sed -n "/^parse_time()/,/^}/p" ./systab; sed -n "/^error()/,/^}/p" ./systab)
    parse_time "in 5 minutes"
'

# ============================================================
# Job names (-n)
# ============================================================

echo ""
echo "${BOLD}--- Job names ---${RESET}"

assert_output "create job with name" "Job created:" $SYSTAB -t "every 10 minutes" -c "echo named_test" -n mytest
extract_id; id_named=$_extracted_id
assert_last_output_contains "name appears in creation output" "(mytest)"

assert_file_contains "service file has SYSTAB_NAME" \
    "$SYSTEMD_USER_DIR/systab_${id_named}.service" "^# SYSTAB_NAME=mytest$"

assert_output "status by name" "(mytest)" $SYSTAB -S mytest
assert_output "logs by name" "(mytest)" $SYSTAB -L mytest

assert_output "disable by name" "Disabled:" $SYSTAB -D mytest
assert_last_output_contains "disable output shows name" "(mytest)"

assert_output "enable by name" "Enabled:" $SYSTAB -E mytest
assert_last_output_contains "enable output shows name" "(mytest)"

assert_output "status shows name" "(mytest)" $SYSTAB -S

assert_failure "duplicate name rejected" $SYSTAB -t "every 10 minutes" -c "echo dup" -n mytest

assert_failure "name with whitespace rejected" $SYSTAB -t "daily" -c "echo bad" -n "my test"
assert_failure "name with pipe rejected" $SYSTAB -t "daily" -c "echo bad" -n "my|test"
assert_failure "name with colon rejected" $SYSTAB -t "daily" -c "echo bad" -n "my:test"

# ============================================================
# Error cases
# ============================================================

echo ""
echo "${BOLD}--- Error cases ---${RESET}"

assert_failure "missing -t" $SYSTAB -c "echo hello"
assert_failure "-c and -f together" $SYSTAB -t "daily" -c "echo hello" -f /nonexistent
assert_failure "invalid job ID for -D" $SYSTAB -D "zzzzzz"
assert_failure "invalid job ID for -E" $SYSTAB -E "zzzzzz"

# -o without -i or -m: should succeed (flag accepted, just no notification lines)
assert_output "-o without -i/-m creates job" "Job created:" $SYSTAB -t "every 10 minutes" -c "echo bare_output" -o
extract_id; id_bare_o=$_extracted_id
# Should have FLAGS comment but no ExecStopPost
assert_file_contains "-o without -i/-m has FLAGS comment" \
    "$SYSTEMD_USER_DIR/systab_${id_bare_o}.service" "SYSTAB_FLAGS=o"
# Should NOT have ExecStopPost
if grep -q "^ExecStopPost=" "$SYSTEMD_USER_DIR/systab_${id_bare_o}.service"; then
    fail "-o without -i/-m has no ExecStopPost" "found ExecStopPost"
else
    pass "-o without -i/-m has no ExecStopPost"
fi

# ============================================================
# Services (-s)
# ============================================================

echo ""
echo "${BOLD}--- Services ---${RESET}"

# Create a persistent service job (sleep 3600 stays running)
assert_output "create service job" "Service created:" $SYSTAB -s -c "sleep 3600"
extract_id; id_svc=$_extracted_id

if [[ -z "$id_svc" ]]; then
    echo "FATAL: could not extract service job ID, aborting"
    exit 1
fi

# Unit file checks (mirrors tape: cat the service file)
assert_file_contains "service file has SYSTAB_TYPE=service" \
    "$SYSTEMD_USER_DIR/systab_${id_svc}.service" "^# SYSTAB_TYPE=service$"
assert_file_contains "service file has Type=simple" \
    "$SYSTEMD_USER_DIR/systab_${id_svc}.service" "^Type=simple$"
assert_file_contains "service file has Restart=on-failure" \
    "$SYSTEMD_USER_DIR/systab_${id_svc}.service" "^Restart=on-failure$"
assert_file_contains "service file has WantedBy=default.target" \
    "$SYSTEMD_USER_DIR/systab_${id_svc}.service" "^WantedBy=default.target$"

# No timer file should exist (mirrors tape: no timer)
if [[ -f "$SYSTEMD_USER_DIR/systab_${id_svc}.timer" ]]; then
    fail "service job has no .timer file" "timer file unexpectedly exists"
else
    pass "service job has no .timer file"
fi

# Service should be active (mirrors tape: "Active (running)")
if systemctl --user is-active "systab_${id_svc}.service" &>/dev/null; then
    pass "service job is active"
else
    fail "service job is active" "service not running"
fi

# Status shows Type: Service and real systemd state (mirrors tape: systab -S monitor)
assert_output "status shows Type: Service" "Type: Service" $SYSTAB -S "$id_svc"
assert_output "status shows active state" "Service: active" $SYSTAB -S "$id_svc"

# Logs work for service jobs (mirrors tape: systab -L monitor)
assert_output "logs for service job" "Logs for" $SYSTAB -L "$id_svc"

# Service with a name (mirrors tape: -s -n monitor)
assert_output "create service job with name" "Service created:" $SYSTAB -s -n svctest -c "sleep 3600"
extract_id; id_svc_named=$_extracted_id
assert_last_output_contains "service name appears in creation output" "(svctest)"
assert_file_contains "service file has SYSTAB_NAME" \
    "$SYSTEMD_USER_DIR/systab_${id_svc_named}.service" "^# SYSTAB_NAME=svctest$"

# Disable stops the service (mirrors tape: systab -D monitor)
assert_output "disable service job" "Disabled:" $SYSTAB -D "$id_svc"
assert_output "disabled service shows in status" "Disabled" $SYSTAB -S "$id_svc"
assert_output "disable already disabled service" "Already disabled:" $SYSTAB -D "$id_svc"

# Enable restarts the service (mirrors tape: systab -E monitor)
assert_output "enable service job" "Enabled:" $SYSTAB -E "$id_svc"
assert_output "enable already enabled service" "Already enabled:" $SYSTAB -E "$id_svc"

# Edit mode shows service jobs with 'service' in schedule column
# (mirrors tape: EDITOR=nano systab -e shows "id:s | service | cmd")
edit_output=$(EDITOR=cat $SYSTAB -e 2>&1 || true)
if [[ "$edit_output" == *"| service |"* ]]; then
    pass "edit mode shows service job with 'service' schedule"
else
    fail "edit mode shows service job with 'service' schedule" "not found in: $edit_output"
fi

# Mutually exclusive flags (mirrors tape design: -s conflicts with -t/-i/-m/-o)
assert_failure "-s and -t are mutually exclusive" $SYSTAB -s -t daily -c "echo test"
assert_failure "-s and -i are mutually exclusive" $SYSTAB -s -i -c "echo test"
assert_failure "-s and -m are mutually exclusive" $SYSTAB -s -m user@example.com -c "echo test"
assert_failure "-s and -o are mutually exclusive" $SYSTAB -s -o -c "echo test"

# ============================================================
# Clean
# ============================================================

echo ""
echo "${BOLD}--- Clean ---${RESET}"

# No elapsed one-time jobs (our one-time is still waiting)
assert_output "clean with no elapsed jobs" "No completed" $SYSTAB -C < /dev/null

# ============================================================
# Summary
# ============================================================

echo ""
echo "---"
echo "${BOLD}${total} tests: ${GREEN}${passed} passed${RESET}, ${RED}${failed} failed${RESET}"

[[ $failed -eq 0 ]]
