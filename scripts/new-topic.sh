#!/usr/bin/env bash
# Scaffold a new research topic: folder layout + an empty knowledge graph.
# Usage: scripts/new-topic.sh <topic-slug>     (kebab-case, e.g. future-of-education)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOPIC="${1:-}"

if [[ -z "$TOPIC" ]]; then
  echo "Usage: scripts/new-topic.sh <topic-slug>" >&2
  exit 1
fi
if [[ ! "$TOPIC" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
  echo "Topic slug must be kebab-case (lowercase letters, digits, hyphens): got '$TOPIC'" >&2
  exit 1
fi
if [[ -e "$REPO_ROOT/$TOPIC" ]]; then
  echo "Refusing to overwrite: $REPO_ROOT/$TOPIC already exists" >&2
  exit 1
fi
command -v sqlite3 >/dev/null 2>&1 || { echo "sqlite3 not found on PATH — run scripts/doctor.sh" >&2; exit 3; }

mkdir -p "$REPO_ROOT/$TOPIC"/{references/pdfs,drafts,published,.captures,.interpretations,.factchecks,.gaps}
sqlite3 "$REPO_ROOT/$TOPIC/graph.sqlite" < "$REPO_ROOT/schema.sql" >/dev/null

TABLES="$(sqlite3 "$REPO_ROOT/$TOPIC/graph.sqlite" "SELECT count(*) FROM sqlite_master WHERE type='table'")"
echo "Topic '$TOPIC' scaffolded:"
echo "  $TOPIC/references/          extracted source text (.txt) lands here"
echo "  $TOPIC/references/pdfs/     fetched PDFs land here"
echo "  $TOPIC/graph.sqlite         empty knowledge graph ($TABLES tables)"
echo "  $TOPIC/drafts/ published/   your writing"
echo
echo "Next: open Claude Code in this folder and run  /research-capture <a paper URL or DOI>"
