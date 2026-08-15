#!/usr/bin/env bash
# Check that everything the pipeline needs is on PATH.
set -uo pipefail

ok=0
missing=0

check() {
  local cmd="$1" why="$2" hint="$3"
  if command -v "$cmd" >/dev/null 2>&1; then
    printf '  ok       %-20s %s\n' "$cmd" "$("$cmd" --version 2>/dev/null | head -1)"
    ok=$((ok + 1))
  else
    printf '  MISSING  %-20s %s\n           install: %s\n' "$cmd" "$why" "$hint"
    missing=$((missing + 1))
  fi
}

echo "Required (corpus + graph):"
check sqlite3 "stores each topic's knowledge graph" "apt install sqlite3  |  brew install sqlite"
check python3 "used by the lint runner; handy for graph queries" "apt/brew install python3"
echo
echo "Required only for /research-lint:"
check vale "prose style rules (ProseAU)" "brew install vale  |  https://vale.sh"
check cspell "spell check" "npm i -g cspell"
check markdownlint-cli2 "markdown structure" "npm i -g markdownlint-cli2"
check prettier "formatting" "npm i -g prettier"
echo
echo "Claude Code itself: https://claude.com/claude-code — the commands in .claude/commands/ load automatically when you open this folder."

if [[ $missing -gt 0 ]]; then
  echo
  echo "$missing tool(s) missing."
  exit 1
fi
echo
echo "All $ok tools present."
