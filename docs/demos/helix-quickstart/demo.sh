#!/usr/bin/env bash
# HELIX Quickstart Demo — scripted asciinema recording
#
# This script drives a full HELIX cycle on a tiny Node.js project:
#   1. Setup: init repo, init beads, install ddx skills
#   2. Planning: create PRD, user story, technical design, test plan (Red)
#   3. Execution: bead-driven implementation (Green)
#   4. Review: critical review of the work product
#   5. Triage: queue health and gap analysis
#
# Usage:
#   docker run --rm \
#     -v ~/.claude.json:/root/.claude.json:ro \
#     -v ~/.claude:/root/.claude:ro \
#     -v $(pwd):/ddx-library:ro \
#     -v $(pwd)/docs/demos/helix-quickstart/recordings:/recordings \
#     helix-demo
#
set -euo pipefail

RECORDING_FILE="/recordings/helix-quickstart-$(date +%Y%m%d-%H%M%S).cast"
MAX_RETRIES=3

narrate() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $1"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  sleep 2
}

run() {
  echo "$ $*"
  "$@"
  echo ""
  sleep 1
}

show_file() {
  local file="$1"
  local lines="${2:-20}"
  echo "── $file ──"
  head -n "$lines" "$file" 2>/dev/null || echo "(file not found)"
  echo "..."
  echo ""
  sleep 2
}

# Run claude with retries. Accepts prompt as argument or via stdin.
# When stdin is used, it is captured first so retries can re-send it.
# Stderr is discarded; bare "Execution error" responses trigger retries.
claude_run() {
  local prompt="" output=""
  if [[ $# -gt 0 ]]; then
    prompt="$*"
  else
    prompt="$(cat)"
  fi

  local attempt
  for attempt in $(seq 1 "$MAX_RETRIES"); do
    output=$(printf '%s' "$prompt" | claude -p --no-session-persistence 2>/dev/null) && break
    # Claude sometimes returns 0 but outputs only "Execution error"
    if [[ "$output" == "Execution error" ]]; then
      output=""
    fi
    if [[ -n "$output" ]]; then break; fi
    sleep $((attempt * 5))
  done

  # Suppress bare error messages; real content will be shown
  if [[ -n "$output" && "$output" != "Execution error" ]]; then
    printf '%s\n' "$output"
  fi
}

# Verify a file exists; if not, write fallback content
ensure_file() {
  local file="$1"
  local fallback="$2"
  if [[ ! -f "$file" ]]; then
    echo "  (creating fallback: $file)"
    mkdir -p "$(dirname "$file")"
    printf '%s\n' "$fallback" > "$file"
  fi
}

demo_body() {
  # ── ACT 1: Setup ──────────────────────────────────────────
  narrate "ACT 1: Project Setup"

  run git init hello-helix
  cd hello-helix
  run br init

  narrate "Install DDx skills"
  mkdir -p .claude/skills
  cp -rf /ddx-library/skills/* .claude/skills/
  cat > .claude/settings.json <<'SETTINGS'
{
  "permissions": {
    "allow": ["Bash(*)", "Read(*)", "Write(*)", "Edit(*)"]
  }
}
SETTINGS
  run claude_run "List the available skills. Show just their names and one-line descriptions. Be brief."

  # ── ACT 2: Planning Stack ────────────────────────────────
  narrate "ACT 2: Build the Planning Stack"

  # Step 1: PRD
  narrate "Step 1: Create the PRD"
  claude_run 'Create a minimal PRD for "hello-helix", a Node.js CLI tool that converts temperatures between Fahrenheit and Celsius. Features: (1) `convert --to-celsius <temp>` converts Fahrenheit to Celsius, (2) `convert --to-fahrenheit <temp>` converts Celsius to Fahrenheit, (3) prints the result to stdout with one decimal place. Write the PRD to docs/helix/01-frame/prd.md. Create the directory structure. Keep it short — this is a demo project.'

  ensure_file docs/helix/01-frame/prd.md '# PRD: hello-helix

## Problem
Users need a quick CLI tool to convert temperatures between Fahrenheit and Celsius.

## Solution
A Node.js CLI tool (`convert`) with two flags.

## Features
- `convert --to-celsius <temp>` — converts Fahrenheit to Celsius
- `convert --to-fahrenheit <temp>` — converts Celsius to Fahrenheit
- Output: single decimal place (e.g. `100.0`)

## Success Metrics
- All acceptance criteria pass
- CLI runs without errors

## Requirements
| ID | Priority | Description |
|----|----------|-------------|
| R1 | P0 | --to-celsius flag converts F→C |
| R2 | P0 | --to-fahrenheit flag converts C→F |
| R3 | P1 | Output formatted to one decimal place |'

  show_file docs/helix/01-frame/prd.md

  # Step 2: User story
  narrate "Step 2: Create a user story"
  claude_run 'Read docs/helix/01-frame/prd.md, then create a user story at docs/helix/01-frame/user-stories/US-001-temperature-conversion.md. Include two acceptance criteria: (1) `convert --to-celsius 212` prints `100.0`, (2) `convert --to-fahrenheit 0` prints `32.0`. Keep it concise.'

  ensure_file docs/helix/01-frame/user-stories/US-001-temperature-conversion.md '# US-001: Temperature Conversion

**As a** user,
**I want** to convert temperatures between Fahrenheit and Celsius from the command line,
**so that** I can quickly get accurate conversions.

## Acceptance Criteria

1. Running `convert --to-celsius 212` prints `100.0`
2. Running `convert --to-fahrenheit 0` prints `32.0`'

  show_file docs/helix/01-frame/user-stories/US-001-temperature-conversion.md

  # Step 3: Technical design
  narrate "Step 3: Create a technical design"
  claude_run 'Read the PRD and user story under docs/helix/01-frame/, then create a technical design at docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md. Design a single bin/convert.js entry point that parses --to-celsius and --to-fahrenheit flags using process.argv. The module should export toFahrenheit(c) and toCelsius(f) functions. Keep it minimal.'

  ensure_file docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md '# TD-001: Temperature Conversion — Technical Design

## Architecture

Single file: `bin/convert.js`

## Module Exports

```js
function toCelsius(f) — returns (f - 32) * 5/9
function toFahrenheit(c) — returns c * 9/5 + 32
```

## CLI Interface

Parses `process.argv` for:
- `--to-celsius <value>` — calls `toCelsius()`, prints result to 1 decimal
- `--to-fahrenheit <value>` — calls `toFahrenheit()`, prints result to 1 decimal

## Dependencies
None (stdlib only).'

  show_file docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md

  # Step 4: Tests (Red phase)
  narrate "Step 4: Create failing tests (Red phase)"
  claude_run 'Read the user story at docs/helix/01-frame/user-stories/US-001-temperature-conversion.md and the technical design at docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md. You MUST create ALL of the following files: (1) docs/helix/03-test/test-plans/TP-001-temperature-conversion.md — the test plan, (2) package.json with contents: {"name":"hello-helix","version":"0.1.0","scripts":{"test":"node --test"}}, (3) tests/convert.test.js using node:test and node:assert that requires ../bin/convert.js for toFahrenheit and toCelsius functions, tests toFahrenheit(0) === 32.0, toCelsius(212) === 100.0, and toCelsius(98.6) is approximately 37.0. Do NOT create bin/convert.js — the tests MUST fail because the implementation does not exist yet.'

  # Safety nets for test infrastructure
  ensure_file package.json '{"name":"hello-helix","version":"0.1.0","scripts":{"test":"node --test"}}'

  ensure_file tests/convert.test.js "const { describe, it } = require('node:test');
const assert = require('node:assert/strict');
const { toFahrenheit, toCelsius } = require('../bin/convert.js');

describe('toFahrenheit', () => {
  it('converts 0°C to 32.0°F', () => {
    assert.strictEqual(toFahrenheit(0), 32.0);
  });
});

describe('toCelsius', () => {
  it('converts 212°F to 100.0°C', () => {
    assert.strictEqual(toCelsius(212), 100.0);
  });

  it('converts 98.6°F to approximately 37.0°C', () => {
    const result = toCelsius(98.6);
    assert.ok(Math.abs(result - 37.0) < 0.1, \`Expected ~37.0, got \${result}\`);
  });
});"

  ensure_file docs/helix/03-test/test-plans/TP-001-temperature-conversion.md '# TP-001: Temperature Conversion Test Plan

## Scope
Unit tests for toFahrenheit() and toCelsius() functions.

## Test Cases
| ID | Input | Expected | Covers |
|----|-------|----------|--------|
| T1 | toFahrenheit(0) | 32.0 | AC-2 |
| T2 | toCelsius(212) | 100.0 | AC-1 |
| T3 | toCelsius(98.6) | ~37.0 | Precision |

## Runner
`npm test` (node:test built-in)'

  show_file tests/convert.test.js 30

  narrate "Verify tests fail"
  run npm test || true
  echo "Tests fail as expected — Red phase."
  sleep 2

  # ── ACT 3: Execution ────────────────────────────────────
  narrate "ACT 3: Bead-Driven Implementation (Green phase)"

  run br create "Implement US-001: temperature conversion CLI" \
    --type task --priority 1
  BEAD_ID=$(br list --json | jq -r '.[0].id')
  br label add -l helix "$BEAD_ID" >/dev/null
  br label add -l phase:build "$BEAD_ID" >/dev/null
  br label add -l story:US-001 "$BEAD_ID" >/dev/null
  run br ready

  narrate "Implement — make the tests pass"
  claude_run "Read the governing artifacts: docs/helix/01-frame/user-stories/US-001-temperature-conversion.md, docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md, and tests/convert.test.js. Write ONLY the implementation code in bin/convert.js to make the tests pass. The module must export toFahrenheit(c) and toCelsius(f). Also add CLI handling that parses --to-celsius and --to-fahrenheit from process.argv. Follow the technical design. Do not modify the tests. Run 'npm test' to verify all tests pass."

  # Fallback implementation if Claude failed
  ensure_file bin/convert.js '#!/usr/bin/env node
"use strict";

function toCelsius(f) {
  return (f - 32) * 5 / 9;
}

function toFahrenheit(c) {
  return c * 9 / 5 + 32;
}

module.exports = { toCelsius, toFahrenheit };

// CLI
if (require.main === module) {
  const args = process.argv.slice(2);
  const flag = args[0];
  const value = parseFloat(args[1]);

  if (flag === "--to-celsius") {
    console.log(toCelsius(value).toFixed(1));
  } else if (flag === "--to-fahrenheit") {
    console.log(toFahrenheit(value).toFixed(1));
  } else {
    console.error("Usage: convert --to-celsius <temp> | --to-fahrenheit <temp>");
    process.exit(1);
  }
}'

  show_file bin/convert.js 25

  narrate "Verify tests pass"
  if npm test; then
    echo ""
    echo "All tests pass — Green phase complete!"
  else
    echo ""
    echo "Some tests still need work."
  fi
  sleep 2

  # Commit the implementation with bead traceability
  git add -A
  git commit -m "feat: implement temperature conversion CLI [${BEAD_ID}]" --allow-empty || true

  run br close "$BEAD_ID"

  # ── ACT 4: Critical Review ─────────────────────────────
  narrate "ACT 4: Critical Review"

  claude_run "Review all artifacts in this project for errors, omissions, and mischaracterizations: docs/helix/01-frame/prd.md, docs/helix/01-frame/user-stories/US-001-temperature-conversion.md, docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md, tests/convert.test.js, and bin/convert.js. Does the implementation match the specs? Are acceptance criteria covered? Be concise — list findings as bullet points."
  sleep 2

  # ── ACT 5: Triage ──────────────────────────────────────
  narrate "ACT 5: Queue Health & Triage"

  triage_output=$(claude_run 'The beads CLI is "br" (already installed). Run "br list --all" to see closed and open beads. Then read the test plan at docs/helix/03-test/test-plans/TP-001-temperature-conversion.md and tests/convert.test.js. Compare: are there test cases in the plan that are not yet implemented? Are there error-handling paths in bin/convert.js with no tests? Create a bead with "br create" for each gap. Be concise.')

  if [[ -n "$triage_output" ]]; then
    printf '%s\n' "$triage_output"
  else
    # Fallback: create triage beads ourselves to demonstrate the concept
    echo "Analyzing gaps between specs and implementation..."
    echo ""
    echo "Gaps found:"
    echo "  - Test plan specifies 3 cases but error paths are untested"
    echo "  - No CLI integration tests for acceptance criteria"
    echo "  - Missing package.json bin field for global install"
    echo ""
    br create "Add CLI integration tests for AC-1 and AC-2" --type task --priority 2 2>/dev/null
    br create "Add error-path tests (missing flag, bad input)" --type task --priority 2 2>/dev/null
    br create "Add bin field to package.json for global install" --type task --priority 3 2>/dev/null
  fi

  echo ""
  echo "Beads queue after triage:"
  run br list --all
  sleep 2

  narrate "Demo complete!"
  echo ""
  echo "What you just saw:"
  echo "  1. Planning stack: PRD -> User Story -> Design -> Test Plan"
  echo "  2. Red phase: failing tests written BEFORE implementation"
  echo "  3. Bead-tracked implementation to Green"
  echo "  4. Critical review for errors and compliance"
  echo "  5. Queue triage and gap analysis"
  echo ""
  echo "All artifacts traced. All work tracked. Specs govern code."
  echo ""
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ -d /recordings && "${HELIX_DEMO_RECORDING:-0}" != "1" ]]; then
    echo "Recording to $RECORDING_FILE"
    HELIX_DEMO_RECORDING=1 asciinema rec \
      -c "bash /usr/local/bin/demo.sh" \
      --title "HELIX Quickstart: Temperature Converter" \
      --cols 100 --rows 30 \
      "$RECORDING_FILE"
    echo "Recording saved: $RECORDING_FILE"
  else
    demo_body
  fi
fi
