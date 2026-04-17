#!/usr/bin/env bash
#
# test-capability-awareness.sh
#
# End-to-end tests for the super-agent-skills plugin:
# - Capability awareness: routing, companion discovery
# - Cost-optimized delegation: prompt templates, skill modifications, model selection
#
# Two test types:
# - Structural validation (fast, no LLM) — file existence, content checks
# - LLM awareness (slower, uses Claude CLI) — prompt-based behavior checks
#
# Uses haiku for speed and cost.
#
# Usage:
#   bash scripts/test-capability-awareness.sh
#   bash scripts/test-capability-awareness.sh --verbose   # show full responses

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MODEL="${TEST_MODEL:-haiku}"
VERBOSE=false
[[ "${1:-}" == "--verbose" ]] && VERBOSE=true

PASS=0
FAIL=0
SKIP=0

# Output directory for test results
OUTPUT_DIR="$PLUGIN_DIR/output"
mkdir -p "$OUTPUT_DIR"
OUTPUT_FILE="$OUTPUT_DIR/test-capability-awareness.txt"

# Tee all output (stdout+stderr) to the output file, stripping ANSI for the file copy
exec > >(tee >(sed 's/\x1b\[[0-9;]*m//g' > "$OUTPUT_FILE")) 2>&1

# Temp settings file that disables the marketplace-installed version
# so only the local --plugin-dir copy is loaded
SETTINGS_FILE=$(mktemp)
cat > "$SETTINGS_FILE" <<'EOF'
{
  "enabledPlugins": {
    "super-agent-skills@oscarqjh-super-agent-skills": false
  }
}
EOF
trap 'rm -f "$SETTINGS_FILE"' EXIT

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m'

run_prompt() {
  local prompt="$1"
  local timeout="${2:-90}"
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

# Check if response contains ANY of the given patterns (case-insensitive)
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

# Check if response does NOT contain any of the given patterns (case-insensitive)
not_contains_any() {
  local response="$1"
  shift
  local lower_response
  lower_response=$(echo "$response" | tr '[:upper:]' '[:lower:]')
  for pattern in "$@"; do
    local lower_pattern
    lower_pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
    if echo "$lower_response" | grep -qF "$lower_pattern"; then
      return 1
    fi
  done
  return 0
}

run_test() {
  local name="$1"
  local prompt="$2"
  local timeout="${3:-60}"
  # remaining args: expect_patterns... then "---" then reject_patterns...
  shift 3

  local expect_patterns=()
  local reject_patterns=()
  local in_reject=false

  for arg in "$@"; do
    if [[ "$arg" == "---" ]]; then
      in_reject=true
      continue
    fi
    if $in_reject; then
      reject_patterns+=("$arg")
    else
      expect_patterns+=("$arg")
    fi
  done

  printf "${BOLD}TEST: %s${NC}\n" "$name"
  if $VERBOSE; then
    printf "  Prompt: %s\n" "$prompt"
  fi

  local response
  response=$(run_prompt "$prompt" "$timeout")

  if [[ "$response" == "__TIMEOUT__" ]]; then
    printf "  ${YELLOW}SKIP${NC} — timed out after ${timeout}s\n\n"
    SKIP=$((SKIP + 1))
    return
  fi

  if $VERBOSE; then
    printf "  Response (first 500 chars):\n"
    echo "$response" | head -c 500 | sed 's/^/    /'
    echo
  fi

  local passed=true

  # Check expected patterns
  if [[ ${#expect_patterns[@]} -gt 0 ]]; then
    if contains_any "$response" "${expect_patterns[@]}"; then
      if $VERBOSE; then
        printf "  ${GREEN}✓${NC} Found expected pattern\n"
      fi
    else
      printf "  ${RED}✗${NC} Expected one of: %s\n" "${expect_patterns[*]}"
      if ! $VERBOSE; then
        printf "  Response (first 300 chars):\n"
        echo "$response" | head -c 300 | sed 's/^/    /'
        echo
      fi
      passed=false
    fi
  fi

  # Check rejected patterns
  if [[ ${#reject_patterns[@]} -gt 0 ]]; then
    if not_contains_any "$response" "${reject_patterns[@]}"; then
      if $VERBOSE; then
        printf "  ${GREEN}✓${NC} No rejected patterns found\n"
      fi
    else
      printf "  ${RED}✗${NC} Found rejected pattern (one of: %s)\n" "${reject_patterns[*]}"
      passed=false
    fi
  fi

  if $passed; then
    printf "  ${GREEN}PASS${NC}\n\n"
    PASS=$((PASS + 1))
  else
    printf "  ${RED}FAIL${NC}\n\n"
    FAIL=$((FAIL + 1))
  fi
}

echo ""
echo "============================================="
echo " Capability Awareness Spike Tests"
echo " Plugin: $PLUGIN_DIR"
echo " Model:  $MODEL"
echo "============================================="
echo ""

# ---------------------------------------------------------------------------
# Test 1: /superthink BUILD route — visual companion surfaced
#
# The root cause problem: agent used to say "I can't render visuals" because
# the visual companion was buried deep in brainstorming skill body. Now
# /superthink should route to brainstorming AND surface the visual companion.
# ---------------------------------------------------------------------------
run_test \
  "superthink BUILD: routes to brainstorming with visual companion" \
  "/super-agent-skills:superthink I want to design a visual dashboard for monitoring API health. Don't start working — just tell me which skill you'd route to and what companion tools are available." \
  90 \
  "brainstorming" \
  --- \
  "i can't render" "i cannot render" "i'm unable to" "text-based"

# ---------------------------------------------------------------------------
# Test 2: /superthink FIX route — routes to systematic-debugging
# ---------------------------------------------------------------------------
run_test \
  "superthink FIX: routes to systematic-debugging" \
  "/super-agent-skills:superthink My API endpoint returns 500 errors intermittently after deploying a new Redis cache layer. Don't start working — just tell me which skill you'd route to." \
  90 \
  "systematic-debugging" "debugging" \
  ---

# ---------------------------------------------------------------------------
# Test 3: /superthink REVIEW route — routes to requesting-code-review
# ---------------------------------------------------------------------------
run_test \
  "superthink REVIEW: routes to requesting-code-review" \
  "/super-agent-skills:superthink I just finished implementing a feature and want someone to review my code before merging. Don't start working — just tell me which skill you'd route to." \
  90 \
  "requesting-code-review" "code-review" "code review" \
  ---

# ---------------------------------------------------------------------------
# Test 4: /superthink SIMPLIFY route — routes to code-simplification
# ---------------------------------------------------------------------------
run_test \
  "superthink SIMPLIFY: routes to code-simplification" \
  "/super-agent-skills:superthink This module has grown to 800 lines and is hard to follow. I want to refactor it for clarity without changing behavior. Don't start working — just tell me which skill you'd route to." \
  90 \
  "code-simplification" "simplif" \
  ---

# ---------------------------------------------------------------------------
# Test 5: /superthink TEST route — routes to test-driven-development
# ---------------------------------------------------------------------------
run_test \
  "superthink TEST: routes to test-driven-development" \
  "/super-agent-skills:superthink I need to add unit tests for our authentication module. Don't start working — just tell me which skill you'd route to." \
  90 \
  "test-driven-development" "tdd" "test-driven" \
  ---

# ---------------------------------------------------------------------------
# Test 6: /superthink SHIP route — routes to finishing-a-development-branch
# ---------------------------------------------------------------------------
run_test \
  "superthink SHIP: routes to finishing-a-development-branch" \
  "/super-agent-skills:superthink All tests pass, code review is done, I want to merge this branch and create a PR. Don't start working — just tell me which skill you'd route to." \
  90 \
  "finishing-a-development-branch" "finishing" "ship" \
  ---

# ---------------------------------------------------------------------------
# Test 7: Visual companion NOT claimed unavailable (the critical regression test)
#
# Directly ask "can you show me mockups?" — the agent must NOT deny the
# capability now that the companion table is injected at session start.
# ---------------------------------------------------------------------------
run_test \
  "Companion awareness: agent does not deny visual capability" \
  "Can you render visual mockups and wireframes in a browser for me? Yes or no, one sentence." \
  90 \
  "yes" "can" "visual" "mockup" "browser" "companion" \
  --- \
  "i can't" "i cannot" "i'm unable" "no," "not able" "text-only" "text-based"

# ---------------------------------------------------------------------------
# Test 8: Companion table — all 3 companions known
# ---------------------------------------------------------------------------
run_test \
  "Companion table: agent lists all 3 companions" \
  "List every companion tool available in the super-agent-skills plugin. Be brief — just name, type, and which skill uses it." \
  90 \
  "visual-companion" "chrome-devtools" "context7" \
  ---

# ===========================================================================
# Structural Validation Tests (no LLM calls — fast, deterministic)
# ===========================================================================

echo ""
echo "---------------------------------------------"
echo " Structural Validation"
echo "---------------------------------------------"
echo ""

run_structural_test() {
  local name="$1"
  local result="$2"  # 0 = pass, non-zero = fail
  local detail="$3"

  printf "${BOLD}TEST: %s${NC}\n" "$name"
  if [[ "$result" -eq 0 ]]; then
    printf "  ${GREEN}PASS${NC}\n\n"
    PASS=$((PASS + 1))
  else
    printf "  ${RED}FAIL${NC} — %s\n\n" "$detail"
    FAIL=$((FAIL + 1))
  fi
}

# ---------------------------------------------------------------------------
# Test 9: Prompt templates exist
# ---------------------------------------------------------------------------
missing_templates=""
for f in \
  skills/brainstorming/spec-writer-prompt.md \
  skills/brainstorming/spec-reviewer-prompt.md \
  skills/writing-plans/plan-writer-prompt.md; do
  [[ -f "$PLUGIN_DIR/$f" ]] || missing_templates="$missing_templates $f"
done
run_structural_test \
  "Delegation templates: all 3 prompt templates exist" \
  "$([ -z "$missing_templates" ] && echo 0 || echo 1)" \
  "Missing:$missing_templates"

# ---------------------------------------------------------------------------
# Test 10: Prompt templates have required sections
# ---------------------------------------------------------------------------
template_sections_ok=0
for f in \
  skills/brainstorming/spec-writer-prompt.md \
  skills/brainstorming/spec-reviewer-prompt.md \
  skills/writing-plans/plan-writer-prompt.md; do
  for section in "# Role" "# Required Context" "# Rules" "# Status"; do
    if ! grep -q "$section" "$PLUGIN_DIR/$f" 2>/dev/null; then
      template_sections_ok=1
      break 2
    fi
  done
done
run_structural_test \
  "Delegation templates: all contain Role, Required Context, Rules, Status" \
  "$template_sections_ok" \
  "One or more templates missing required sections"

# ---------------------------------------------------------------------------
# Test 11: Brainstorming steps 6-7 describe delegation
# ---------------------------------------------------------------------------
delegation_count=$(grep -c "delegate to sonnet subagent" "$PLUGIN_DIR/skills/brainstorming/SKILL.md" 2>/dev/null || echo 0)
run_structural_test \
  "Brainstorming SKILL.md: steps 6-7 describe delegation" \
  "$([ "$delegation_count" -ge 2 ] && echo 0 || echo 1)" \
  "Expected 2+ matches for 'delegate to sonnet subagent', found $delegation_count"

# ---------------------------------------------------------------------------
# Test 12: Brainstorming spec self-review references subagent dispatch
# ---------------------------------------------------------------------------
selfreview_ok=$(grep -c "spec-reviewer-prompt.md" "$PLUGIN_DIR/skills/brainstorming/SKILL.md" 2>/dev/null || echo 0)
run_structural_test \
  "Brainstorming SKILL.md: spec self-review references spec-reviewer-prompt.md" \
  "$([ "$selfreview_ok" -ge 1 ] && echo 0 || echo 1)" \
  "No reference to spec-reviewer-prompt.md found in brainstorming SKILL.md"

# ---------------------------------------------------------------------------
# Test 13: Writing-plans has inline vs delegated section
# ---------------------------------------------------------------------------
inline_section=$(grep -c "## Inline vs Delegated Steps" "$PLUGIN_DIR/skills/writing-plans/SKILL.md" 2>/dev/null || echo 0)
run_structural_test \
  "Writing-plans SKILL.md: has Inline vs Delegated Steps section" \
  "$([ "$inline_section" -ge 1 ] && echo 0 || echo 1)" \
  "Missing '## Inline vs Delegated Steps' section"

# ---------------------------------------------------------------------------
# Test 14: Writing-plans references plan-writer-prompt.md
# ---------------------------------------------------------------------------
plan_writer_ref=$(grep -c "plan-writer-prompt.md" "$PLUGIN_DIR/skills/writing-plans/SKILL.md" 2>/dev/null || echo 0)
run_structural_test \
  "Writing-plans SKILL.md: references plan-writer-prompt.md" \
  "$([ "$plan_writer_ref" -ge 1 ] && echo 0 || echo 1)" \
  "No reference to plan-writer-prompt.md found in writing-plans SKILL.md"

# ---------------------------------------------------------------------------
# Test 15: Subagent-driven-dev has explicit model table with sonnet
# ---------------------------------------------------------------------------
sonnet_count=$(grep -c '"sonnet"' "$PLUGIN_DIR/skills/subagent-driven-development/SKILL.md" 2>/dev/null || echo 0)
run_structural_test \
  "Subagent-driven-dev SKILL.md: model table has sonnet for all roles" \
  "$([ "$sonnet_count" -ge 4 ] && echo 0 || echo 1)" \
  "Expected 4+ '\"sonnet\"' entries in model table, found $sonnet_count"

# ---------------------------------------------------------------------------
# Test 16: Workflow chain preserved — brainstorming chains to writing-plans
# ---------------------------------------------------------------------------
chain_ok=$(grep -A1 "chainsTo:" "$PLUGIN_DIR/skills/brainstorming/SKILL.md" | grep -c "writing-plans" 2>/dev/null || echo 0)
run_structural_test \
  "Workflow chain: brainstorming chainsTo writing-plans" \
  "$([ "$chain_ok" -ge 1 ] && echo 0 || echo 1)" \
  "brainstorming frontmatter missing chainsTo writing-plans"

# ---------------------------------------------------------------------------
# Test 17: Workflow chain preserved — writing-plans chains to subagent-driven-dev
# ---------------------------------------------------------------------------
chain2_ok=$(grep -A2 "chainsTo:" "$PLUGIN_DIR/skills/writing-plans/SKILL.md" | grep -c "subagent-driven-development" 2>/dev/null || echo 0)
run_structural_test \
  "Workflow chain: writing-plans chainsTo subagent-driven-development" \
  "$([ "$chain2_ok" -ge 1 ] && echo 0 || echo 1)" \
  "writing-plans frontmatter missing chainsTo subagent-driven-development"

# ---------------------------------------------------------------------------
# Test 18: Spec-reviewer is read-only (only grants Read tool)
# ---------------------------------------------------------------------------
reviewer_tools=$(grep -i "tools to grant" "$PLUGIN_DIR/skills/brainstorming/spec-reviewer-prompt.md" 2>/dev/null || echo "")
reviewer_readonly=1
if echo "$reviewer_tools" | grep -qi "Read" && ! echo "$reviewer_tools" | grep -qi "Write"; then
  reviewer_readonly=0
fi
run_structural_test \
  "Spec reviewer template: grants Read only (no Write)" \
  "$reviewer_readonly" \
  "Spec reviewer should only have Read tool, found: $reviewer_tools"

# ===========================================================================
# LLM-Based Delegation Awareness Tests
# ===========================================================================

echo ""
echo "---------------------------------------------"
echo " Delegation Awareness (LLM)"
echo "---------------------------------------------"
echo ""

# ---------------------------------------------------------------------------
# Test 19: Agent knows spec writing is delegated
# ---------------------------------------------------------------------------
run_test \
  "Delegation awareness: agent knows spec writing is delegated to subagent" \
  "When using the brainstorming skill, is spec writing done inline or delegated to a subagent? Answer in one sentence." \
  90 \
  "delegat" "subagent" "sonnet" \
  --- \
  "inline" "yourself"

# ---------------------------------------------------------------------------
# Test 20: Agent knows plan writing is delegated
# ---------------------------------------------------------------------------
run_test \
  "Delegation awareness: agent knows plan writing is delegated to subagent" \
  "When using the writing-plans skill, is the plan document written inline or delegated to a subagent? Answer in one sentence." \
  90 \
  "delegat" "subagent" "sonnet" \
  ---

# ---------------------------------------------------------------------------
# Test 21: Agent knows dependency graph stays inline
# ---------------------------------------------------------------------------
run_test \
  "Inline awareness: dependency graph and task ordering stay inline" \
  "When using the writing-plans skill, what work stays inline on the main model vs what gets delegated? Answer in 2 sentences max." \
  90 \
  "inline" "dependency" "task" \
  ---

# ---------------------------------------------------------------------------
# Test 22: Agent knows implementer model is sonnet
# ---------------------------------------------------------------------------
run_test \
  "Model selection: agent knows implementer uses sonnet" \
  "In subagent-driven-development, what model does the implementer subagent use? Answer in one sentence." \
  90 \
  "sonnet" \
  ---

# ===========================================================================
# Execution Route Structural Tests (no LLM — fast, deterministic)
# ===========================================================================

echo ""
echo "---------------------------------------------"
echo " Execution Route Structure"
echo "---------------------------------------------"
echo ""

# ---------------------------------------------------------------------------
# Test 29: Superthink has HARD-GATE chain enforcement
# ---------------------------------------------------------------------------
hardgate_count=$(grep -c "HARD-GATE" "$PLUGIN_DIR/commands/superthink.md" 2>/dev/null || echo 0)
run_structural_test \
  "Superthink: has HARD-GATE chain enforcement block" \
  "$([ "$hardgate_count" -ge 1 ] && echo 0 || echo 1)" \
  "No HARD-GATE block found in superthink.md"

# ---------------------------------------------------------------------------
# Test 30: Superthink has all 14 intent routes
# ---------------------------------------------------------------------------
route_count=0
for intent in "BUILD" "FIX" "TEST" "REVIEW" "SIMPLIFY" "SHIP" "PLAN" "OPTIMIZE" "SECURE" "DOCUMENT" "SETUP" "AUDIT" "CONTEXT" "THREAT-MODEL"; do
  if grep -q "$intent" "$PLUGIN_DIR/commands/superthink.md" 2>/dev/null; then
    route_count=$((route_count + 1))
  fi
done
run_structural_test \
  "Superthink: has all 14 intent routes" \
  "$([ "$route_count" -ge 14 ] && echo 0 || echo 1)" \
  "Expected 14 intent routes, found $route_count"

# ---------------------------------------------------------------------------
# Test 31: Superthink has CHECK BACKLOG terminal step
# ---------------------------------------------------------------------------
backlog_count=$(grep -c "CHECK BACKLOG" "$PLUGIN_DIR/commands/superthink.md" 2>/dev/null || echo 0)
run_structural_test \
  "Superthink: has CHECK BACKLOG terminal step" \
  "$([ "$backlog_count" -ge 1 ] && echo 0 || echo 1)" \
  "No CHECK BACKLOG section found in superthink.md"

# ---------------------------------------------------------------------------
# Test 32: Superthink has chain graph for route expansion
# ---------------------------------------------------------------------------
chains_ok=0
for skill in "brainstorming" "writing-plans" "subagent-driven-development" "requesting-code-review" "systematic-debugging" "test-driven-development"; do
  if ! grep -q "$skill" "$PLUGIN_DIR/commands/superthink.md" 2>/dev/null; then
    chains_ok=1
    break
  fi
done
run_structural_test \
  "Superthink: has chain graph with all chain skills referenced" \
  "$chains_ok" \
  "One or more chain skills missing from superthink.md"

# ---------------------------------------------------------------------------
# Test 33: Superthink has multi-intent decompose stage
# ---------------------------------------------------------------------------
decompose_count=$(grep -ci "decompose" "$PLUGIN_DIR/commands/superthink.md" 2>/dev/null || echo 0)
run_structural_test \
  "Superthink: has DECOMPOSE stage for multi-intent parsing" \
  "$([ "$decompose_count" -ge 1 ] && echo 0 || echo 1)" \
  "No DECOMPOSE stage found in superthink.md"

# ---------------------------------------------------------------------------
# Test 34: Superthink has route modification rules
# ---------------------------------------------------------------------------
mod_count=$(grep -ci "route modification\|modify.*route\|ROUTE.*task" "$PLUGIN_DIR/commands/superthink.md" 2>/dev/null || echo 0)
run_structural_test \
  "Superthink: has route modification rules" \
  "$([ "$mod_count" -ge 1 ] && echo 0 || echo 1)" \
  "No route modification rules found in superthink.md"

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "============================================="
printf " Results: ${GREEN}%d passed${NC}, ${RED}%d failed${NC}, ${YELLOW}%d skipped${NC}\n" "$PASS" "$FAIL" "$SKIP"
echo "============================================="
echo ""
echo "Output saved to: $OUTPUT_FILE"
echo ""

if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
