# Knowledge graph

A light graph-RAG over a topic's research corpus. No embeddings; LLM-asserted
concepts and cross-ref edges, stored in SQLite. Inspired by
[Graphify](https://github.com/safishamsi/graphify).

## Files

- `schema.sql` (repo root) — the DDL, shared by every topic.
- `<topic>/graph.sqlite` — the knowledge base, one per topic. Committed by
  convention; don't gitignore it without deciding that deliberately.
- `<topic>/references/*.txt` — the source corpus as extracted text; original
  PDFs live under `<topic>/references/pdfs/`. Extraction processes only
  `.txt`.

## Bootstrap

Scaffold a full topic (folder layout + empty graph):

```bash
scripts/new-topic.sh <topic>
```

Or create just the database:

```bash
sqlite3 <topic>/graph.sqlite < schema.sql
```

## Extraction

Extraction is performed by the `/research-interpret` command. The agent
session is the LLM: it reads each source file, asserts concepts / claims /
cross-ref edges, and inserts rows into `graph.sqlite`. There is no standalone
extractor script — the command file
([`research-interpret.md`](../.claude/commands/research-interpret.md)) is the
extraction spec and the binding output contract.

## Adding a new reference

1. Drop the new source as `<topic>/references/<author>-<year>-<slug>.txt`
   (converted from PDF — the PDF itself goes under
   `<topic>/references/pdfs/`). Keep the naming convention — `ref_id` is the
   file stem. In normal use `/research-capture` does the fetching,
   conversion, and naming for you.
2. Re-run `/research-interpret`. It skips files already extracted at their
   current sha256 and only processes new ones.

## Updating an existing reference

If a source file changes (better OCR, a new version), its sha256 changes and
extraction re-runs on the next `/research-interpret` pass. The prior
extraction is marked `is_current = 0` automatically; history is preserved. No
manual cleanup needed.

## Re-extraction with a newer model

Re-run `/research-interpret` with a newer extractor model (the model name is
recorded per run as `extractor_model`). The uniqueness key
`(ref_id, source_sha256, extractor_model)` means the new run doesn't collide
with the old one — they coexist, and the newer run wins `is_current = 1`.

## Querying the graph

Use the system `sqlite3` CLI or `python3` stdlib `sqlite3`. The
`v_current_claims` / `v_current_relations` views pre-filter to the current
extraction of each ref. IDs below are placeholders — substitute your own
topic's concept and ref slugs.

```sql
-- All current claims mentioning a concept
SELECT c.ref_id, c.statement
FROM v_current_claims c
JOIN claim_concepts cc ON cc.claim_id = c.claim_id
WHERE cc.concept_id = 'example-concept';

-- Full-text search across claims
SELECT ref_id, statement
FROM claims
WHERE claim_id IN (SELECT rowid FROM claims_fts WHERE claims_fts MATCH 'hierarchy');

-- Cross-ref edges from one reference
SELECT source_ref, type, target_ref, confidence, score
FROM v_current_relations
WHERE source_ref = 'example-2024-topic-paper';

-- Glossary
SELECT concept_id, label, kind FROM concepts ORDER BY concept_id;
```

## Convention

**Schema changes require migration notes.** Do not modify `schema.sql` without
recording what changed, why, and how existing topic databases migrate.

## Migration notes

- **2026-08-15 — `refs.url`.** Added a nullable `url` column to `refs`: the
  canonical public URL (DOI / arXiv / publisher / archive) that inline and
  hybrid citation rendering reads. Existing topic databases migrate with
  `ALTER TABLE refs ADD COLUMN url TEXT;`. New graphs created from
  `schema.sql` include it already.
