# research-backed-writing-kit

## Project overview

Research-anchored writing workspace — writing published under the operator's own name, tethered to a per-topic reference corpus (light graph-RAG over SQLite). Peer-review-style discipline: empirical / load-bearing claims resolve to a corpus primary where one exists, and claims the corpus *contradicts* are surfaced and addressed in the prose. Tone and voice stay the operator's job.

Multiple topics over time, one sub-folder each. Create one with `scripts/new-topic.sh <topic-slug>`.

## Stack

- **Corpus graph:** SQLite — `<topic>/graph.sqlite` (DDL in `schema.sql` at the repo root). Layout: refs → extractions → concepts / claims / relations, with `is_current` versioning and a `claims_fts` full-text index. No embeddings; LLM-asserted concepts and cross-ref edges. See `docs/GRAPH-README.md`.
- **Query it** with the system `sqlite3` CLI or `python3` stdlib `sqlite3`. Handy views: `v_current_claims`, `v_current_relations`.
- **Lint toolchain** (for `/research-lint`): `vale`, `cspell`, `markdownlint-cli2`, `prettier` — verify with `scripts/doctor.sh`.

## Research pipeline (slash commands)

Each command carries a **Settled defaults** section recording its decisions (override any line if a motion misbehaves).

| Command | Motion |
|---|---|
| `/research-capture <seed>` | gated corpus ingestion (candidate list → approve → fetch) |
| `/research-interpret [ref_id]` | extract concepts / claims / relations into `graph.sqlite` |
| `/research-factcheck <draft>` | contradiction detection against the corpus (read-only) |
| `/research-gaps [topic-or-draft]` | perspective / coverage audit (read-only) |
| `/research-tailor <draft> <target>` | render a draft to a target with a citation output mode |
| `/research-quickcheck <claim>` | lightweight corpus hit (read-only) |
| `/research-lint <file.md>` | deterministic style / format check |

Bind the writing register at drafting time via `STYLE-research.template.md` (the research-register delta on the personal-voice base, `STYLE-personal.template.md`).

## Safety rules

- **No silent capture (the load-bearing operator rule).** Any motion with side-effects beyond O(1) gates for operator approval first: capture presents a candidate list before fetching; interpret previews the first ref before batching; tailor presents an outline + claim-map before drafting prose.
- **Operator owns the prose and the angle.** Motions surface what the corpus says, where it contradicts a draft, and what is uncited — they do not auto-draft or auto-remove claims.
- **Don't cross the register boundary silently.** `/research-tailor` must declare which style guide applies.
- Do not modify `schema.sql` or the corpus graph structure without migration notes (see `docs/GRAPH-README.md`).
- A topic's `graph.sqlite` is committed by convention; don't add it to `.gitignore` without confirming with the operator.

## Operational notes

- **Use subagents** to manage context; use lower-capability agents for mechanical tasks. Curate the main feed as a high-value information channel for the operator. Don't read full papers in the main context — delegate capture, interpretation and summarisation to subagents.
