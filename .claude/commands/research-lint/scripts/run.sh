#!/usr/bin/env bash
# /research-lint orchestrator
# Runs deterministic prose/format checks on a markdown file, writes a sibling
# <input>.lint.md report. Read-only by default.
#
# Usage: run.sh <file.md> [--fix]

set -u

INPUT="${1:-}"
FIX=0
if [[ "${2:-}" == "--fix" ]]; then FIX=1; fi

if [[ -z "$INPUT" || ! -f "$INPUT" ]]; then
  echo "usage: run.sh <file.md> [--fix]" >&2
  exit 2
fi

# Resolve tool & asset paths — skill bundle lives two dirs up from this script.
SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VALE_CFG="$SKILL_DIR/vale/.vale.ini"
CSPELL_CFG="$SKILL_DIR/cspell/cspell.json"
MDLINT_CFG="$SKILL_DIR/markdownlint.jsonc"

INPUT_ABS="$(cd "$(dirname "$INPUT")" && pwd)/$(basename "$INPUT")"
REPORT="${INPUT_ABS%.md}.lint.md"

# Require tools up-front.
for t in vale cspell markdownlint-cli2 prettier; do
  command -v "$t" >/dev/null 2>&1 || { echo "missing tool: $t" >&2; exit 3; }
done

# Tmp files for each tool's output.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- Run checks --------------------------------------------------------------

# Vale: JSON output parsed into markdown table.
(cd "$SKILL_DIR/vale" && vale --config "$VALE_CFG" --output=JSON "$INPUT_ABS") \
  > "$TMP/vale.json" 2>"$TMP/vale.err" || true

# cspell: compact text output. --root pins resolution to the input's directory —
# without it, cspell silently checks 0 files when run from a cwd outside the target.
cspell --config "$CSPELL_CFG" --root "$(dirname "$INPUT_ABS")" --no-progress --no-summary --show-context \
  "$INPUT_ABS" > "$TMP/cspell.txt" 2>&1 || true

# markdownlint-cli2 invoked directly; presence on PATH is checked up-front.
markdownlint-cli2 --config "$MDLINT_CFG" "$INPUT_ABS" > "$TMP/mdlint.txt" 2>&1 || true

# prettier check: formatting deltas only (no writes in default mode).
if [[ $FIX -eq 1 ]]; then
  prettier --write --prose-wrap preserve "$INPUT_ABS" > "$TMP/prettier.txt" 2>&1 || true
else
  prettier --check --prose-wrap preserve "$INPUT_ABS" > "$TMP/prettier.txt" 2>&1 || true
fi

# --- Assemble report ---------------------------------------------------------

{
  echo "# Lint report — $(basename "$INPUT")"
  echo
  echo "**File:** \`$INPUT_ABS\`"
  echo "**Generated:** $(date +%Y-%m-%d\ %H:%M\ %Z)"
  echo "**Mode:** $([[ $FIX -eq 1 ]] && echo 'REPORT + FIX (prettier autofix applied)' || echo 'REPORT-ONLY')"
  echo
  echo "Deterministic grammar + formatting pass. Proposes edits; does not rewrite prose."
  echo "Operator reviews each finding and applies selectively."
  echo
  echo "---"
  echo
  echo "## Vale — style rules (AU English, banned vocab, hedging, quote-inside-punct)"
  echo
  python3 - "$TMP/vale.json" <<'PY'
import json, sys, os
try:
    data = json.load(open(sys.argv[1]))
except Exception as e:
    print(f"_Vale produced no parseable output ({e})._")
    sys.exit(0)
if not data:
    print("_No Vale findings._")
    sys.exit(0)
totals = {"error": 0, "warning": 0, "suggestion": 0}
rows = []
for path, alerts in data.items():
    for a in alerts:
        sev = a.get("Severity", "suggestion")
        totals[sev] = totals.get(sev, 0) + 1
        line = a.get("Line", "?")
        check = a.get("Check", "?")
        msg = a.get("Message", "?").replace("|", "\\|")
        match = (a.get("Match", "") or "").replace("|", "\\|").replace("\n", " ")
        rows.append((line, sev, check, msg, match))
print(f"**Totals:** {totals.get('error',0)} error · {totals.get('warning',0)} warning · {totals.get('suggestion',0)} suggestion")
print()
print("| Line | Severity | Rule | Message | Match |")
print("|---|---|---|---|---|")
rows.sort(key=lambda r: (r[0] if isinstance(r[0], int) else 0, r[1]))
for r in rows:
    print(f"| {r[0]} | {r[1]} | {r[2]} | {r[3]} | `{r[4]}` |")
PY
  echo
  echo "## cspell — spelling"
  echo
  if [[ -s "$TMP/cspell.txt" ]] && grep -q ":" "$TMP/cspell.txt"; then
    echo '```'
    cat "$TMP/cspell.txt"
    echo '```'
    echo
    echo "_To accept a word project-wide, add it to \`$SKILL_DIR/cspell/project-words.txt\` and also to \`$SKILL_DIR/vale/styles/config/vocabularies/Project/accept.txt\`._"
  else
    echo "_No spelling issues._"
  fi
  echo
  echo "## markdownlint — markdown structure"
  echo
  if grep -qE "MD[0-9]{3}" "$TMP/mdlint.txt" 2>/dev/null; then
    echo '```'
    cat "$TMP/mdlint.txt"
    echo '```'
  else
    echo "_No markdown structure issues._"
  fi
  echo
  echo "## prettier — whitespace / formatting"
  echo
  if [[ $FIX -eq 1 ]]; then
    echo "Autofix applied. Output:"
  fi
  echo '```'
  cat "$TMP/prettier.txt"
  echo '```'
  echo
  echo "---"
  echo
  echo "## Status"
  echo
  VERR="$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for _,a in d.items() for x in a if x.get("Severity")=="error"))' "$TMP/vale.json" 2>/dev/null || echo 0)"
  VWARN="$(python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print(sum(1 for _,a in d.items() for x in a if x.get("Severity")=="warning"))' "$TMP/vale.json" 2>/dev/null || echo 0)"
  CERR="$(grep -cE ':[0-9]+:' "$TMP/cspell.txt" 2>/dev/null | head -n1)"; CERR="${CERR:-0}"
  MERR="$(grep -cE 'MD[0-9]{3}' "$TMP/mdlint.txt" 2>/dev/null | head -n1)"; MERR="${MERR:-0}"
  echo "| Check | Count |"
  echo "|---|---|"
  echo "| Vale errors | $VERR |"
  echo "| Vale warnings | $VWARN |"
  echo "| Spelling flags | $CERR |"
  echo "| Markdown issues | $MERR |"
  echo
  echo "Operator reviews each finding individually. Rules are heuristic — some will be false positives, especially in quoted passages and proper nouns."
} > "$REPORT"

echo "report: $REPORT"
echo "  vale:  ${VERR:-?} error, ${VWARN:-?} warning"
echo "  cspell: ${CERR:-?}"
echo "  markdownlint: ${MERR:-?}"
