#!/bin/bash
# Fixture-based smoke tests for code-reviewer-stop.js.
# Run: bash plugins/super-agent-skills/hooks/code-reviewer-stop.test.sh
# Exits 0 on success, 1 on first failure.

set -u

SCRIPT="$(dirname "$0")/code-reviewer-stop.js"
SENTINEL='[AWAITING_USER_CHOICE]'
FAILED=0

run() {
  # run "label" "expected_stdout_pattern" "expected_exit" "stdin_json"
  local label="$1" pattern="$2" expected_exit="$3" payload="$4"
  local out rc
  out="$(printf '%s' "$payload" | node "$SCRIPT")"
  rc=$?

  if [ "$rc" -ne "$expected_exit" ]; then
    echo "FAIL [$label] exit=$rc expected=$expected_exit"
    FAILED=1
    return
  fi

  if [ -z "$pattern" ]; then
    if [ -n "$out" ]; then
      echo "FAIL [$label] expected empty stdout, got: $out"
      FAILED=1
      return
    fi
  else
    if ! printf '%s' "$out" | grep -q "$pattern"; then
      echo "FAIL [$label] stdout missing pattern=$pattern got=$out"
      FAILED=1
      return
    fi
  fi

  echo "PASS [$label]"
}

run "malformed JSON exits silent" \
    "" 0 \
    "not json"

run "empty stdin exits silent" \
    "" 0 \
    ""

run "stop_hook_active=true exits silent" \
    "" 0 \
    '{"stop_hook_active":true,"last_assistant_message":"anything"}'

run "sentinel present exits silent" \
    "" 0 \
    "{\"stop_hook_active\":false,\"last_assistant_message\":\"Review done. $SENTINEL (A) Wrap up (B) Ship it (C) Keep going\"}"

run "sentinel absent emits decision:block" \
    '"decision":"block"' 0 \
    '{"stop_hook_active":false,"last_assistant_message":"All done, no menu."}'

run "incidental A) B) C) without sentinel still blocks" \
    '"decision":"block"' 0 \
    '{"stop_hook_active":false,"last_assistant_message":"Affected: A) foo.ts, B) bar.ts, C) baz.ts"}'

run "missing last_assistant_message field still blocks" \
    '"decision":"block"' 0 \
    '{"stop_hook_active":false}'

if [ "$FAILED" -ne 0 ]; then
  echo "--- SOME TESTS FAILED ---"
  exit 1
fi
echo "--- all tests passed ---"
exit 0
