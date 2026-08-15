---
name: research-quickcheck
description: Lightweight read-only check of a single claim or short snippet against the topic corpus. Optional --web flag for opt-in web lookup. Does not spawn a folder, gate, or graph write. Use when the operator wants a fast "does the corpus say anything about this?" without invoking the full /research-factcheck pipeline.
---

# /research-quickcheck

Lightweight corpus check — the pipeline's deliberately minimal mode: no folder spawned, no gate, no graph writes.

**Status: Active** — defaults finalised 2026-07-01. The settled defaults below replace the prior operator-review TODOs; override any line if the motion misbehaves in use.

## Args

    /research-quickcheck "<claim or snippet>" [--web] [--topic <name>]

If invoked inside a topic folder, that topic's `graph.sqlite` is the default corpus. `--topic <name>` overrides. Without a topic context, only `--web` produces useful output.

## Behaviour

1. **Parse** the claim/snippet for key concepts.
2. **Corpus search.** Hit `claims_fts` + `concepts` for matches. Return:
    - Direct support: `claims.statement` rows that align (with `ref_id`, `evidence_locator`).
    - Direct contradictions: `claims.statement` rows that oppose (with `ref_id`, `evidence_locator`).
    - Adjacent material: same concepts, different framing.
3. **Optional web lookup** (`--web` only): one or two open-web queries. Return URLs + 1-line summaries. No fetch, no archive — just surfacing.
4. **Inline output.** Print directly to session as a compact report:
    - `## Direct support` (or "none in corpus")
    - `## Direct contradictions` (or "none in corpus")
    - `## Adjacent material`
    - `## Web (if --web)`
    - `## Status` — `verified | unverified | blocked | inferred`

   No outcome file. No folder spawned. No graph writes. No draft modifications.

## Constraints

- Read-only on everything. No DB writes. No file creation.
- `--web` is opt-in — never automatic. Respects the no-silent-capture rule in spirit (no silent web fetch).
- Output stays in-session. If the operator wants persistence, they ask for `/research-factcheck` against a draft.
- Never modify files outside this project.

## Settled defaults (finalised 2026-07-01)

- **`--web` result cap: 5**, surfaced as URLs + one-line summaries only (no fetch, no archive).
- **`--web` results are pre-tiered** by the source-quality hierarchy (`STYLE-research.template.md`) so a tier-1 hit is visually separable from a tier-5 one at a glance.
- **Multiple claims accepted** in one call (`/research-quickcheck "claim 1" "claim 2"`); each gets its own compact block.
- **"Adjacent material" stays in the default output** — it is the most useful part of a quick check for spotting a framing the corpus already holds. No `--verbose` gate.

## Out of scope

- Writing to corpus → `/research-capture`.
- Draft-level fact-check → `/research-factcheck`.
- Graph population → `/research-interpret`.
- Tailoring → `/research-tailor`.
