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

# Show first N lines of a file with a header
show_file() {
  local file="$1"
  local lines="${2:-20}"
  echo "── $file ──"
  head -n "$lines" "$file" 2>/dev/null || echo "(file not found)"
  echo "..."
  echo ""
  sleep 2
}

claude_run() {
  local output rc
  output=$(claude -p --no-session-persistence "$@" 2>&1)
  rc=$?
  if [[ $rc -ne 0 ]]; then
    sleep 5
    output=$(claude -p --no-session-persistence "$@" 2>&1) || true
  fi
  printf '%s\n' "$output"
}

demo_body() {
  # ── ACT 1: Setup ──────────────────────────────────────────
  narrate "ACT 1: Project Setup"

  run git init hello-helix
  cd hello-helix
  run br init

  narrate "Install DDx skills"
  mkdir -p .claude/skills .claude
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

  narrate "Step 1: Create the PRD"
  claude_run <<'PROMPT'
Create a minimal PRD for "hello-helix", a Node.js CLI tool that converts
temperatures between Fahrenheit and Celsius.

Features:
- `convert --to-celsius <temp>` converts Fahrenheit to Celsius
- `convert --to-fahrenheit <temp>` converts Celsius to Fahrenheit
- Prints the result to stdout with one decimal place

Write the PRD to docs/helix/01-frame/prd.md. Create the directory structure.
Keep it short — this is a demo project.
PROMPT
  show_file docs/helix/01-frame/prd.md

  narrate "Step 2: Create a user story"
  claude_run <<'PROMPT'
Read docs/helix/01-frame/prd.md, then create a user story at
docs/helix/01-frame/user-stories/US-001-temperature-conversion.md.

Include two acceptance criteria:
1. `convert --to-celsius 212` prints `100.0`
2. `convert --to-fahrenheit 0` prints `32.0`

Keep it concise.
PROMPT
  show_file docs/helix/01-frame/user-stories/US-001-temperature-conversion.md

  narrate "Step 3: Create a technical design"
  claude_run <<'PROMPT'
Read the PRD and user story under docs/helix/01-frame/, then create a
technical design at docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md.

Design a single bin/convert.js entry point that parses --to-celsius and
--to-fahrenheit flags using process.argv. Keep it minimal.
PROMPT
  show_file docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md

  narrate "Step 4: Create failing tests (Red phase)"
  claude_run <<'PROMPT'
Read the user story at docs/helix/01-frame/user-stories/US-001-temperature-conversion.md
and the technical design at docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md.

You MUST create ALL of the following files:

1. docs/helix/03-test/test-plans/TP-001-temperature-conversion.md
2. package.json with: {"name":"hello-helix","version":"0.1.0","scripts":{"test":"node --test"}}
3. tests/convert.test.js using node:test and node:assert that:
   - require('../bin/convert.js') for the conversion functions
   - Test toFahrenheit(0) === 32.0
   - Test toCelsius(212) === 100.0
   - Test toCelsius(98.6) is approximately 37.0

Do NOT create bin/convert.js — tests MUST fail.
Verify all three files exist.
PROMPT

  # Safety net
  [[ -f package.json ]] || echo '{"name":"hello-helix","version":"0.1.0","scripts":{"test":"node --test"}}' > package.json

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
  claude_run <<PROMPT
Read the governing artifacts:
- docs/helix/01-frame/user-stories/US-001-temperature-conversion.md
- docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md
- tests/convert.test.js

Write ONLY the implementation code to make the tests pass.
Follow the technical design. Do not modify the tests.
Run "npm test" to verify. Commit with bead ID: $BEAD_ID
PROMPT

  show_file bin/convert.js 25

  narrate "Verify tests pass"
  if npm test; then
    echo ""
    echo "All tests pass — Green phase complete."
  else
    echo ""
    echo "Some tests still need work."
  fi
  sleep 2

  run br close "$BEAD_ID"

  # ── ACT 4: Critical Review ─────────────────────────────
  narrate "ACT 4: Critical Review"

  claude_run <<'PROMPT'
Review all artifacts in this project for errors, omissions, and
mischaracterizations:

- docs/helix/01-frame/prd.md
- docs/helix/01-frame/user-stories/US-001-temperature-conversion.md
- docs/helix/02-design/technical-designs/TD-001-temperature-conversion.md
- tests/convert.test.js
- bin/convert.js

Does the implementation match the specs? Are acceptance criteria covered?
Be concise — list findings as bullet points.
PROMPT
  sleep 2

  # ── ACT 5: Triage ──────────────────────────────────────
  narrate "ACT 5: Queue Health & Triage"

  claude_run <<'PROMPT'
The beads CLI is "br". Run "br list" and "br ready" to see the queue.
Review the queue against the repo state. Are there gaps between specs
and implementation? Create beads for any gaps. Be concise.
PROMPT

  run br list
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
