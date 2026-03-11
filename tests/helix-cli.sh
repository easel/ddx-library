#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
test_count=0

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"
  if [[ "$expected" != "$actual" ]]; then
    printf 'expected:\n%s\nactual:\n%s\n' "$expected" "$actual" >&2
    fail "$message"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    printf 'missing substring: %s\nin:\n%s\n' "$needle" "$haystack" >&2
    fail "$message"
  fi
}

make_mock_bin() {
  local root="$1"
  mkdir -p "$root/bin" "$root/state"

  cat >"$root/bin/bd" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

state_root="${MOCK_STATE_ROOT:?}"
command="${1:-}"
shift || true

pop_first_line() {
  local file="$1"
  if [[ ! -s "$file" ]]; then
    return 1
  fi
  head -n1 "$file"
  tail -n +2 "$file" > "$file.tmp" || true
  mv "$file.tmp" "$file"
}

emit_ready_json() {
  local count="$1"
  printf '['
  local i
  for ((i = 0; i < count; i++)); do
    [[ "$i" -gt 0 ]] && printf ','
    printf '{"id":"bd-mock-%d"}' "$i"
  done
  printf ']\n'
}

case "$command" in
  init)
    mkdir -p .beads
    ;;
  ready)
    count="$(pop_first_line "$state_root/ready-seq" || echo 0)"
    emit_ready_json "$count"
    ;;
  *)
    echo "unsupported mock bd command: $command" >&2
    exit 1
    ;;
esac
EOF

  cat >"$root/bin/codex" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

state_root="${MOCK_STATE_ROOT:?}"
payload="$*"

record() {
  printf '%s\n' "$1" >> "$state_root/calls.log"
}

next_action() {
  local file="$state_root/next-actions"
  if [[ ! -s "$file" ]]; then
    echo STOP
    return
  fi
  head -n1 "$file"
  tail -n +2 "$file" > "$file.tmp" || true
  mv "$file.tmp" "$file"
}

case "$payload" in
  *"implementation action"*)
    record implement
    echo "implementation complete"
    ;;
  *"check action"*)
    record check
    action="$(next_action)"
    printf 'NEXT_ACTION: %s\n' "$action"
    echo "Recommended Command: mock"
    ;;
  *"alignment action"*)
    record align
    echo "alignment complete"
    ;;
  *"backfill action"*)
    record backfill
    echo "backfill complete"
    ;;
  *)
    record other
    echo "mock codex"
    ;;
esac
EOF

  cat >"$root/bin/claude" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'claude mock %s\n' "$*"
EOF

  chmod +x "$root/bin/bd" "$root/bin/codex" "$root/bin/claude"
}

make_workspace() {
  local root
  root="$(mktemp -d)"
  mkdir -p "$root/work"
  make_mock_bin "$root"
  (
    cd "$root/work"
    git init -q
  )
  echo "$root"
}

run_helix() {
  local root="$1"
  shift
  (
    cd "$root/work"
    HOME="$root/home" \
    PATH="$root/bin:$PATH" \
    MOCK_STATE_ROOT="$root/state" \
    HELIX_LIBRARY_ROOT="$repo_root/workflows/helix" \
    bash "$repo_root/scripts/helix" "$@"
  )
}

test_help() {
  local root
  root="$(make_workspace)"
  local output
  output="$(run_helix "$root" help)"
  assert_contains "$output" "helix run" "help should list run command"
  assert_contains "$output" "--review-every" "help should list review option"
  rm -rf "$root"
}

test_check_dry_run() {
  local root
  root="$(make_workspace)"
  local output
  output="$(run_helix "$root" check --dry-run repo)"
  assert_contains "$output" "codex -a never -s danger-full-access exec" "dry-run should print codex command"
  assert_contains "$output" "actions/check.md" "dry-run should reference check action"
  rm -rf "$root"
}

test_run_stops_after_queue_drains() {
  local root
  root="$(make_workspace)"
  printf '1\n1\n0\n' > "$root/state/ready-seq"
  printf 'STOP\n' > "$root/state/next-actions"

  run_helix "$root" run >/dev/null

  local calls
  calls="$(cat "$root/state/calls.log")"
  assert_eq $'implement\nimplement\ncheck' "$calls" "run should implement until drained, then check once"
  rm -rf "$root"
}

test_run_periodic_alignment() {
  local root
  root="$(make_workspace)"
  printf '1\n1\n0\n' > "$root/state/ready-seq"
  printf 'STOP\n' > "$root/state/next-actions"

  run_helix "$root" run --review-every 2 >/dev/null

  local calls
  calls="$(cat "$root/state/calls.log")"
  assert_eq $'implement\nimplement\nalign\ncheck' "$calls" "periodic alignment should run after configured cycles"
  rm -rf "$root"
}

test_run_auto_aligns_once() {
  local root
  root="$(make_workspace)"
  printf '0\n0\n' > "$root/state/ready-seq"
  printf 'ALIGN\nSTOP\n' > "$root/state/next-actions"

  run_helix "$root" run >/dev/null

  local calls
  calls="$(cat "$root/state/calls.log")"
  assert_eq $'check\nalign\ncheck' "$calls" "run should auto-align once when check returns ALIGN"
  rm -rf "$root"
}

test_installer_creates_launcher() {
  local root
  root="$(make_workspace)"
  (
    cd "$repo_root"
    HOME="$root/home" \
    CODEX_HOME="$root/codex-home" \
    CLAUDE_HOME="$root/claude-home" \
    bash scripts/install-local-skills.sh >/dev/null
  )

  [[ -x "$root/home/.local/bin/helix" ]] || fail "installer should create helix launcher"
  local launcher
  launcher="$(cat "$root/home/.local/bin/helix")"
  assert_contains "$launcher" 'exec bash "'$repo_root'/scripts/helix"' "launcher should invoke repo helix script through bash"
  rm -rf "$root"
}

run_test() {
  local name="$1"
  shift
  "$@"
  test_count=$((test_count + 1))
  echo "ok - $name"
}

run_test "help" test_help
run_test "check dry-run" test_check_dry_run
run_test "run stops after drain" test_run_stops_after_queue_drains
run_test "periodic alignment" test_run_periodic_alignment
run_test "auto-align" test_run_auto_aligns_once
run_test "installer launcher" test_installer_creates_launcher

echo "PASS: ${test_count} helix wrapper tests"
