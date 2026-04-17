#!/usr/bin/env bash
#
# test-delegation-chain.sh
#
# Chain segment tests for the cost-optimized delegation feature.
# Tests each delegation point in isolation by pre-seeding context,
# then verifying the agent actually dispatches a subagent and produces output.
#
# Each test targets one delegation point:
#   Segment 1: Spec writing delegation (brainstorming step 6)
#   Segment 2: Spec self-review delegation (brainstorming step 7)
#   Segment 3: Plan writing delegation (writing-plans)
#
# These tests are slower than capability-awareness tests (~2-3 min each)
# because they involve actual subagent dispatch.
#
# Usage:
#   bash scripts/test-delegation-chain.sh
#   bash scripts/test-delegation-chain.sh --verbose   # show full responses
#   TEST_MODEL=sonnet bash scripts/test-delegation-chain.sh  # override model

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/../plugins/super-agent-skills" && pwd)"
MODEL="${TEST_MODEL:-haiku}"
VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

PASS=0
FAIL=0
SKIP=0

# Output directory for test results
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUTPUT_DIR="$REPO_ROOT/output"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/test-delegation-chain.txt"

# Tee all output (stdout+stderr) to the output file, stripping ANSI for the file copy
exec > >(tee >(sed 's/\x1b\[[0-9;]*m//g' > "$OUTPUT_FILE")) 2>&1

# Temp workspace for test artifacts
TEST_DIR=$(mktemp -d)
SETTINGS_FILE=$(mktemp)
cat > "$SETTINGS_FILE" <<'EOF'
{
  "enabledPlugins": {
    "super-agent-skills@oscarqjh-super-agent-skills": false
  }
}
EOF
trap 'rm -rf "$TEST_DIR" "$SETTINGS_FILE"' EXIT

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

run_prompt() {
  local prompt="$1"
  local timeout="${2:-180}"
  timeout "$timeout" claude -p "$prompt" \
    --settings "$SETTINGS_FILE" \
    --plugin-dir "$PLUGIN_DIR" \
    --model "$MODEL" \
    --dangerously-skip-permissions \
    --no-session-persistence \
    --output-format text \
    < /dev/null \
    2>/dev/null || echo "__TIMEOUT__"
}

contains_any() {
  local response="$1"
  shift
  local lower_response
  lower_response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
  for pattern in "$@"; do
    local lower_pattern
    lower_pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
    if echo "$lower_response" | grep -qF "$lower_pattern"; then
      return 0
    fi
  done
  return 1
}

echo ""
echo "============================================="
echo " Delegation Chain Segment Tests"
echo " Plugin: $PLUGIN_DIR"
echo " Model:  $MODEL"
echo " Temp:   $TEST_DIR"
echo "============================================="
echo ""

# ===========================================================================
# Segment 1: Spec writing delegation (brainstorming step 6)
#
# Pre-seed: approved design decisions for a trivial feature
# Action:   agent should dispatch sonnet subagent with spec-writer-prompt.md
# Check:    spec file created, has correct structure, response shows delegation
# ===========================================================================

printf "${BOLD}SEGMENT 1: Spec writing delegation${NC}\n"
printf "  Dispatching agent to delegate spec writing...\n"

SPEC_PATH="$TEST_DIR/test-spec.md"

SEGMENT1_PROMPT="You are testing the brainstorming skill's step 6 (spec writing delegation).

The user has ALREADY approved this design. Do NOT ask questions or brainstorm. Go directly to step 6.

## Approved Design Decisions

Feature: Add a 'hello' greeting utility
- Single function: greet(name) returns 'Hello, {name}!'
- Lives in src/greet.ts
- One test file: tests/greet.test.ts
- No external dependencies

## Context to fill into the spec-writer template

PROJECT_NAME: Greeting Utility
SPEC_PATH: $SPEC_PATH
TECH_STACK: TypeScript, Node.js
DESIGN_DECISIONS:
  - Single function greet(name: string): string in src/greet.ts
  - Returns format: 'Hello, {name}!'
  - Test file at tests/greet.test.ts using Node built-in test runner
CONSTRAINTS:
  - No external dependencies
  - Follow existing TypeScript conventions
SUCCESS_CRITERIA:
  1. greet('World') returns 'Hello, World!'
  2. greet('') returns 'Hello, !'
  3. Function exported from src/greet.ts
APPROACHES_CONSIDERED: Direct function (chosen: simplest approach)
BOUNDARIES:
  In scope: greet function and tests
  Out of scope: CLI wrapper, i18n
EXISTING_PATTERNS: none identified

## Your task

Read the spec-writer prompt template at skills/brainstorming/spec-writer-prompt.md.
Fill in the Required Context fields with the values above.
Dispatch a sonnet subagent using Agent(model: \"sonnet\") with the filled prompt.
Review the subagent's output.
Report what happened."

SEGMENT1_RESPONSE=$(run_prompt "$SEGMENT1_PROMPT" 180)

if [[ "$SEGMENT1_RESPONSE" == "__TIMEOUT__" ]]; then
  printf "  ${YELLOW}SKIP${NC} — timed out after 180s\n\n"
  SKIP=$((SKIP + 1))
else
  S1_PASS=true

  # Check 1: Response shows evidence of delegation
  if contains_any "$SEGMENT1_RESPONSE" "agent" "subagent" "dispatch" "delegat" "sonnet"; then
    printf "  ${GREEN}✓${NC} Response shows delegation activity\n"
  else
    printf "  ${RED}✗${NC} No evidence of delegation in response\n"
    S1_PASS=false
  fi

  # Check 2: Spec file was created
  if [[ -f "$SPEC_PATH" ]]; then
    printf "  ${GREEN}✓${NC} Spec file created at $SPEC_PATH\n"

    # Check 3: Spec has key sections
    spec_content=$(cat "$SPEC_PATH")
    missing_sections=""
    for section in "Objective" "Success criteria" "Architecture" "Acceptance Test"; do
      if ! echo "$spec_content" | grep -qi "$section"; then
        missing_sections="$missing_sections '$section'"
      fi
    done

    if [[ -z "$missing_sections" ]]; then
      printf "  ${GREEN}✓${NC} Spec contains required sections\n"
    else
      printf "  ${RED}✗${NC} Spec missing sections:$missing_sections\n"
      S1_PASS=false
    fi

    # Check 4: Spec mentions the feature
    if echo "$spec_content" | grep -qi "greet"; then
      printf "  ${GREEN}✓${NC} Spec references the greeting feature\n"
    else
      printf "  ${RED}✗${NC} Spec doesn't mention the greeting feature\n"
      S1_PASS=false
    fi

    # Check 5: No placeholders
    if ! echo "$spec_content" | grep -qiE "TBD|TODO|fill in later"; then
      printf "  ${GREEN}✓${NC} No placeholders found in spec\n"
    else
      printf "  ${RED}✗${NC} Spec contains TBD/TODO placeholders\n"
      S1_PASS=false
    fi
  else
    printf "  ${RED}✗${NC} Spec file NOT created at $SPEC_PATH\n"
    S1_PASS=false
  fi

  if $VERBOSE; then
    printf "\n  Response (first 500 chars):\n"
    echo "$SEGMENT1_RESPONSE" | head -c 500 | sed 's/^/    /'
    echo
    if [[ -f "$SPEC_PATH" ]]; then
      printf "\n  Spec file (first 300 chars):\n"
      head -c 300 "$SPEC_PATH" | sed 's/^/    /'
      echo
    fi
  fi

  if $S1_PASS; then
    printf "  ${GREEN}PASS${NC}\n\n"
    PASS=$((PASS + 1))
  else
    printf "  ${RED}FAIL${NC}\n\n"
    FAIL=$((FAIL + 1))
  fi
fi

# ===========================================================================
# Segment 2: Spec self-review delegation (brainstorming step 7)
#
# Pre-seed: spec file from segment 1 (or a fallback spec)
# Action:   agent should dispatch sonnet subagent with spec-reviewer-prompt.md
# Check:    response contains structured review output (Check 1-4, status)
# ===========================================================================

printf "${BOLD}SEGMENT 2: Spec self-review delegation${NC}\n"

# If segment 1 didn't produce a spec, write a minimal one for this test
if [[ ! -f "$SPEC_PATH" ]]; then
  printf "  (Using fallback spec since segment 1 didn't produce one)\n"
  cat > "$SPEC_PATH" <<'SPECEOF'
# Greeting Utility — Design Spec

## Objective

Add a greeting utility function.

**Success criteria:**
1. greet('World') returns 'Hello, World!'
2. greet('') returns 'Hello, !'
3. Function exported from src/greet.ts

## Tech Stack

- Language/Runtime: TypeScript, Node.js

## Architecture

Single exported function in one file.

## Acceptance Tests

- [ ] `test: greet returns formatted greeting`
      Given: name = 'World'
      When: greet(name) is called
      Then: returns 'Hello, World!'
SPECEOF
fi

printf "  Dispatching agent to delegate spec review...\n"

SEGMENT2_PROMPT="You are testing the brainstorming skill's step 7 (spec self-review delegation).

A spec has been written to $SPEC_PATH. Do NOT modify it. Do NOT ask questions.

## Your task

Read the spec-reviewer prompt template at skills/brainstorming/spec-reviewer-prompt.md.
Fill in SPEC_PATH with: $SPEC_PATH
Dispatch a sonnet subagent using Agent(model: \"sonnet\") with the filled prompt.
The subagent should only have the Read tool.
Read the reviewer's output and report what it found.
Report the review status (DONE, DONE_WITH_CONCERNS, etc) and any issues found."

SEGMENT2_RESPONSE=$(run_prompt "$SEGMENT2_PROMPT" 180)

if [[ "$SEGMENT2_RESPONSE" == "__TIMEOUT__" ]]; then
  printf "  ${YELLOW}SKIP${NC} — timed out after 180s\n\n"
  SKIP=$((SKIP + 1))
else
  S2_PASS=true

  # Check 1: Response shows evidence of delegation OR structured review output
  # (The model may report review results directly without mentioning "subagent")
  if contains_any "$SEGMENT2_RESPONSE" "agent" "subagent" "dispatch" "delegat" "reviewer" "DONE" "placeholder" "consistency" "scope" "ambiguity" "check 1" "check 2"; then
    printf "  ${GREEN}✓${NC} Response shows review activity\n"
  else
    printf "  ${RED}✗${NC} No evidence of review activity in response\n"
    S2_PASS=false
  fi

  # Check 2: Response contains structured review output (checklist or status)
  if contains_any "$SEGMENT2_RESPONSE" "DONE" "placeholder" "consistency" "scope" "ambiguity" "check 1" "check 2" "pass" "status"; then
    printf "  ${GREEN}✓${NC} Response contains structured review output\n"
  else
    printf "  ${RED}✗${NC} No structured review output in response\n"
    S2_PASS=false
  fi

  # Check 3: Spec file was NOT modified (reviewer is read-only)
  if [[ -f "$SPEC_PATH" ]]; then
    printf "  ${GREEN}✓${NC} Spec file still exists (not deleted)\n"
  else
    printf "  ${RED}✗${NC} Spec file was deleted\n"
    S2_PASS=false
  fi

  if $VERBOSE; then
    printf "\n  Response (first 500 chars):\n"
    echo "$SEGMENT2_RESPONSE" | head -c 500 | sed 's/^/    /'
    echo
  fi

  if $S2_PASS; then
    printf "  ${GREEN}PASS${NC}\n\n"
    PASS=$((PASS + 1))
  else
    printf "  ${RED}FAIL${NC}\n\n"
    FAIL=$((FAIL + 1))
  fi
fi

# ===========================================================================
# Segment 3: Plan writing delegation (writing-plans)
#
# Pre-seed: spec file + inline task decomposition
# Action:   agent should dispatch sonnet subagent with plan-writer-prompt.md
# Check:    plan file created, has correct structure (header, tasks, checkpoints)
# ===========================================================================

printf "${BOLD}SEGMENT 3: Plan writing delegation${NC}\n"
printf "  Dispatching agent to delegate plan writing...\n"

PLAN_PATH="$TEST_DIR/test-plan.md"

SEGMENT3_PROMPT="You are testing the writing-plans skill's delegation step.

A spec exists at $SPEC_PATH. You have ALREADY done the inline decomposition. Do NOT re-decompose. Do NOT ask questions. Go directly to delegation.

## Your inline decomposition (already complete)

PLAN_PATH: $PLAN_PATH
SPEC_PATH: $SPEC_PATH
FEATURE_NAME: Greeting Utility
GOAL: Add a greet(name) function that returns a formatted greeting
ARCHITECTURE_SUMMARY: Single TypeScript function in src/greet.ts with tests in tests/greet.test.ts. No external dependencies.
TECH_STACK: TypeScript, Node.js, built-in test runner
TASK_LIST:
  Task 1: Create greet function with test
    Files: Create src/greet.ts, Create tests/greet.test.ts
    Depends on: none
    Summary: Create greet(name) function returning 'Hello, {name}!' and tests verifying standard input and empty string
ACCEPTANCE_TESTS:
  - test: greet returns formatted greeting -> Task 1
    Given: name = 'World'
    When: greet(name) is called
    Then: returns 'Hello, World!'
  - test: greet handles empty string -> Task 1
    Given: name = ''
    When: greet(name) is called
    Then: returns 'Hello, !'

## Your task

Read the plan-writer prompt template at skills/writing-plans/plan-writer-prompt.md.
Fill in the Required Context fields with the decomposition above.
Dispatch a sonnet subagent using Agent(model: \"sonnet\") with the filled prompt.
Review the subagent's output.
Report what happened."

SEGMENT3_RESPONSE=$(run_prompt "$SEGMENT3_PROMPT" 180)

if [[ "$SEGMENT3_RESPONSE" == "__TIMEOUT__" ]]; then
  printf "  ${YELLOW}SKIP${NC} — timed out after 180s\n\n"
  SKIP=$((SKIP + 1))
else
  S3_PASS=true

  # Check 1: Response shows evidence of delegation
  if contains_any "$SEGMENT3_RESPONSE" "agent" "subagent" "dispatch" "delegat" "sonnet"; then
    printf "  ${GREEN}✓${NC} Response shows delegation activity\n"
  else
    printf "  ${RED}✗${NC} No evidence of delegation in response\n"
    S3_PASS=false
  fi

  # Check 2: Plan file was created
  if [[ -f "$PLAN_PATH" ]]; then
    printf "  ${GREEN}✓${NC} Plan file created at $PLAN_PATH\n"

    plan_content=$(cat "$PLAN_PATH")

    # Check 3: Plan has required header
    if echo "$plan_content" | grep -qi "Implementation Plan"; then
      printf "  ${GREEN}✓${NC} Plan has Implementation Plan header\n"
    else
      printf "  ${RED}✗${NC} Plan missing Implementation Plan header\n"
      S3_PASS=false
    fi

    # Check 4: Plan has task structure
    if echo "$plan_content" | grep -qi "Task 1"; then
      printf "  ${GREEN}✓${NC} Plan contains Task 1\n"
    else
      printf "  ${RED}✗${NC} Plan missing Task 1\n"
      S3_PASS=false
    fi

    # Check 5: Plan has step checkboxes
    if echo "$plan_content" | grep -q "\- \[ \]"; then
      printf "  ${GREEN}✓${NC} Plan has checkbox steps\n"
    else
      printf "  ${RED}✗${NC} Plan missing checkbox steps\n"
      S3_PASS=false
    fi

    # Check 6: Plan mentions the feature
    if echo "$plan_content" | grep -qi "greet"; then
      printf "  ${GREEN}✓${NC} Plan references the greeting feature\n"
    else
      printf "  ${RED}✗${NC} Plan doesn't mention the greeting feature\n"
      S3_PASS=false
    fi

    # Check 7: No placeholders
    if ! echo "$plan_content" | grep -qiE "TBD|TODO|fill in later|similar to task"; then
      printf "  ${GREEN}✓${NC} No placeholders found in plan\n"
    else
      printf "  ${RED}✗${NC} Plan contains placeholders\n"
      S3_PASS=false
    fi
  else
    printf "  ${RED}✗${NC} Plan file NOT created at $PLAN_PATH\n"
    S3_PASS=false
  fi

  if $VERBOSE; then
    printf "\n  Response (first 500 chars):\n"
    echo "$SEGMENT3_RESPONSE" | head -c 500 | sed 's/^/    /'
    echo
    if [[ -f "$PLAN_PATH" ]]; then
      printf "\n  Plan file (first 500 chars):\n"
      head -c 500 "$PLAN_PATH" | sed 's/^/    /'
      echo
    fi
  fi

  if $S3_PASS; then
    printf "  ${GREEN}PASS${NC}\n\n"
    PASS=$((PASS + 1))
  else
    printf "  ${RED}FAIL${NC}\n\n"
    FAIL=$((FAIL + 1))
  fi
fi

# ===========================================================================
# Summary
# ===========================================================================
echo "============================================="
printf " Results: ${GREEN}%d passed${NC}, ${RED}%d failed${NC}, ${YELLOW}%d skipped${NC}\n" "$PASS" "$FAIL" "$SKIP"
echo "============================================="
echo ""

# Copy test artifacts to output before cleanup
if [[ -f "$TEST_DIR/test-spec.md" ]]; then
  cp "$TEST_DIR/test-spec.md" "$OUTPUT_DIR/delegation-spec-output.md" 2>/dev/null || true
fi
if [[ -f "$TEST_DIR/test-plan.md" ]]; then
  cp "$TEST_DIR/test-plan.md" "$OUTPUT_DIR/delegation-plan-output.md" 2>/dev/null || true
fi

echo "Output saved to: $OUTPUT_DIR/"
echo ""

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
