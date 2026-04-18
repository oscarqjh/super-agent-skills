#!/usr/bin/env bash
# Test: code-explorer and code-architect agent integration
# Validates agent files exist with correct structure and skill files reference them properly.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PLUGIN_DIR="$REPO_ROOT/plugins/super-agent-skills"
PASS=0
FAIL=0

print_header() {
  echo ""
  echo "============================================="
  echo " Agent Integration Structural Tests"
  echo " Plugin: $PLUGIN_DIR"
  echo "============================================="
  echo ""
}

assert_file_exists() {
  local file="$1" label="$2"
  printf "TEST: %s\n" "$label"
  if [[ -f "$file" ]]; then
    echo "  PASS"
    PASS=$((PASS + 1))
  else
    echo "  FAIL — file not found: $file"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_contains() {
  local file="$1" pattern="$2" label="$3"
  printf "TEST: %s\n" "$label"
  if grep -qE "$pattern" "$file" 2>/dev/null; then
    echo "  PASS"
    PASS=$((PASS + 1))
  else
    echo "  FAIL — pattern not found: $pattern"
    FAIL=$((FAIL + 1))
  fi
}

assert_file_not_contains() {
  local file="$1" pattern="$2" label="$3"
  printf "TEST: %s\n" "$label"
  if grep -qP "$pattern" "$file" 2>/dev/null; then
    echo "  FAIL — found rejected pattern: $pattern"
    FAIL=$((FAIL + 1))
  else
    echo "  PASS"
    PASS=$((PASS + 1))
  fi
}

print_header

EXPLORER="$PLUGIN_DIR/agents/code-explorer.md"
ARCHITECT="$PLUGIN_DIR/agents/code-architect.md"
BRAINSTORMING="$PLUGIN_DIR/skills/brainstorming/SKILL.md"
WRITING_PLANS="$PLUGIN_DIR/skills/writing-plans/SKILL.md"

echo "---------------------------------------------"
echo " code-explorer Agent"
echo "---------------------------------------------"
echo ""

# Test 1
assert_file_exists "$EXPLORER" "code-explorer agent file exists"

# Test 2
assert_file_contains "$EXPLORER" "^name: code-explorer" \
  "code-explorer: has correct name in frontmatter"

# Test 3
assert_file_contains "$EXPLORER" "^model: sonnet" \
  "code-explorer: uses sonnet model"

# Test 4
assert_file_contains "$EXPLORER" "^color: yellow" \
  "code-explorer: has yellow color"

# Test 5
assert_file_contains "$EXPLORER" "^tools:.*Glob.*Grep.*Read" \
  "code-explorer: has read-only tools (Glob, Grep, Read)"

# Test 6 — no write tools (word boundaries to avoid matching BashOutput/TodoWrite)
assert_file_not_contains "$EXPLORER" "^tools:.*\b(Bash|Edit|Write)\b" \
  "code-explorer: no write tools (Bash, Edit, Write)"

# Test 7
assert_file_contains "$EXPLORER" "Feature Discovery" \
  "code-explorer: has Feature Discovery step"

# Test 8
assert_file_contains "$EXPLORER" "Code Flow Tracing" \
  "code-explorer: has Code Flow Tracing step"

# Test 9
assert_file_contains "$EXPLORER" "Architecture Analysis" \
  "code-explorer: has Architecture Analysis step"

# Test 10
assert_file_contains "$EXPLORER" "Implementation Details" \
  "code-explorer: has Implementation Details step"

# Test 11
assert_file_contains "$EXPLORER" "Essential Files" \
  "code-explorer: output format includes Essential Files"

# Test 12
assert_file_contains "$EXPLORER" "Entry Points" \
  "code-explorer: output format includes Entry Points"

echo ""
echo "---------------------------------------------"
echo " code-architect Agent"
echo "---------------------------------------------"
echo ""

# Test 13
assert_file_exists "$ARCHITECT" "code-architect agent file exists"

# Test 14
assert_file_contains "$ARCHITECT" "^name: code-architect" \
  "code-architect: has correct name in frontmatter"

# Test 15
assert_file_contains "$ARCHITECT" "^model: sonnet" \
  "code-architect: uses sonnet model"

# Test 16
assert_file_contains "$ARCHITECT" "^color: green" \
  "code-architect: has green color"

# Test 17
assert_file_contains "$ARCHITECT" "^tools:.*Glob.*Grep.*Read" \
  "code-architect: has read-only tools (Glob, Grep, Read)"

# Test 18 — no write tools (word boundaries to avoid matching BashOutput/TodoWrite)
assert_file_not_contains "$ARCHITECT" "^tools:.*\b(Bash|Edit|Write)\b" \
  "code-architect: no write tools (Bash, Edit, Write)"

# Test 19
assert_file_contains "$ARCHITECT" "Codebase Pattern Analysis" \
  "code-architect: has Codebase Pattern Analysis step"

# Test 20
assert_file_contains "$ARCHITECT" "Architecture Design" \
  "code-architect: has Architecture Design step"

# Test 21
assert_file_contains "$ARCHITECT" "Implementation Blueprint" \
  "code-architect: has Implementation Blueprint step"

# Test 22
assert_file_contains "$ARCHITECT" "Build Sequence" \
  "code-architect: output format includes Build Sequence"

# Test 23
assert_file_contains "$ARCHITECT" "Component Design" \
  "code-architect: output format includes Component Design"

# Test 24
assert_file_contains "$ARCHITECT" "Data Flow" \
  "code-architect: output format includes Data Flow"

echo ""
echo "---------------------------------------------"
echo " Brainstorming Skill Integration"
echo "---------------------------------------------"
echo ""

# Test 25
assert_file_contains "$BRAINSTORMING" "code-explorer" \
  "brainstorming SKILL.md references code-explorer"

# Test 26
assert_file_contains "$BRAINSTORMING" "Codebase exploration" \
  "brainstorming SKILL.md has exploration decision point in diagram"

# Test 27
assert_file_contains "$BRAINSTORMING" "judgment call" \
  "brainstorming SKILL.md uses non-mandatory language (judgment call)"

# Test 28
assert_file_contains "$BRAINSTORMING" "When to skip" \
  "brainstorming SKILL.md documents when to skip exploration"

# Test 29
assert_file_contains "$BRAINSTORMING" "Max 3 explorers" \
  "brainstorming SKILL.md caps explorer count at 3"

echo ""
echo "---------------------------------------------"
echo " Writing-plans Skill Integration"
echo "---------------------------------------------"
echo ""

# Test 30
assert_file_contains "$WRITING_PLANS" "code-architect" \
  "writing-plans SKILL.md references code-architect"

# Test 31
assert_file_contains "$WRITING_PLANS" "Codebase Architecture Analysis" \
  "writing-plans SKILL.md has Codebase Architecture Analysis section"

# Test 32 — verify section ordering: Scope Check < Architecture Analysis < Dependency Graph
SCOPE_LINE=$(grep -n "## Scope Check" "$WRITING_PLANS" | head -1 | cut -d: -f1)
ARCH_LINE=$(grep -n "## Codebase Architecture" "$WRITING_PLANS" | head -1 | cut -d: -f1)
DEP_LINE=$(grep -n "## Dependency Graph" "$WRITING_PLANS" | head -1 | cut -d: -f1)
printf "TEST: writing-plans section order: Scope Check < Architecture Analysis < Dependency Graph\n"
if [[ -n "$SCOPE_LINE" && -n "$ARCH_LINE" && -n "$DEP_LINE" ]] && \
   (( SCOPE_LINE < ARCH_LINE && ARCH_LINE < DEP_LINE )); then
  echo "  PASS"
  PASS=$((PASS + 1))
else
  echo "  FAIL — sections not in expected order (Scope=$SCOPE_LINE, Arch=$ARCH_LINE, Dep=$DEP_LINE)"
  FAIL=$((FAIL + 1))
fi

# Test 33
assert_file_contains "$WRITING_PLANS" "not as the final plan" \
  "writing-plans treats architect output as input, not gospel"

# Test 34
assert_file_contains "$WRITING_PLANS" "orchestrator retains" \
  "writing-plans confirms orchestrator retains final authority"

echo ""
echo "============================================="
echo " Results: $PASS passed, $FAIL failed"
echo "============================================="

exit "$FAIL"
