---
name: research-interpret
description: Read captured primaries in a topic's references/ folder, produce per-ref synthesis notes (refNN-*.md), and assert concepts/claims/relations into the topic's graph.sqlite. Use after /research-capture, when the operator says "interpret these refs", "extract from the corpus", or wants the graph layer populated for a draft.
---

# /research-interpret

Graph-RAG ingestion for a research topic's captured primaries. Implements the pipeline's **Interpret** motion.

**Status: Active** — defaults finalised 2026-07-01. The settled defaults below replace the prior operator-review TODOs; override any line if the motion misbehaves in use.

## Args

    /research-interpret              # all uninterpreted refs in current topic
    /research-interpret <ref_id>     # single ref by id

## Behaviour

1. **Discover.** List `refs` rows in `<topic>/graph.sqlite` with no current `extractions` row at `(ref_id, source_sha256, extractor_model)`.
2. **Per ref:**
   - Read the primary's text from `references/<slug>.txt` (or extracted PDF text).
   - Author a synthesis note `refNN-<slug>.md` with YAML front-matter: `ref_id`, list of `concept_ids` asserted. Body free-form.
   - Insert exactly one `extractions` row keyed by `(ref_id, source_sha256, extractor_model)`. Idempotent — skip if a current row exists at that key.
   - Emit concepts: `kind ∈ {concept, mechanism, finding, framework}`, `confidence ∈ {EXTRACTED, INFERRED, AMBIGUOUS}`.
   - Emit claims as atomic propositions phrased as the primary states them (not operator paraphrase). Include `evidence_locator` (page / section) where extractable.
   - Emit relations: `type ∈ {cites, extends, contradicts, shares_concept_with, evidence_for, background_for}`.
   - On re-run with newer extractor model: flip prior extraction's `is_current = 0`.
3. **GATE POINT — pause after first ref if batch > 5 (no silent capture).** Show the operator the first ref's synthesis note and the first set of inserted rows. Wait for:
    - `continue` — proceed with the rest of the batch using the same pattern
    - `adjust: <change>` — operator describes a change to the extraction style; restart on first ref
    - `stop` — abort, write outcome file
4. **Outcome file.** Write `<topic>/.interpretations/<YYYY-MM-DD>-<slug>-interpret-outcome.md`: refs interpreted, rows inserted per table, refs skipped (with reason), refs failed (with reason). Status: verified / unverified / blocked / inferred.

## Constraints

- One `extractions` row per `(ref_id, source_sha256, extractor_model)` — uniqueness key in `schema.sql`. Re-dispatch is idempotent.
- Claims must be extractable from the primary, not asserted from operator framing.
- Never modify `refs` rows (those are owned by `/research-capture`).
- Never write outside `<topic>/`.
- No silent skipping: if a ref fails, record it in the outcome file with reason — do not move on quietly (Feynman convention, see [`provenance-feynman.md`](../../docs/provenance-feynman.md) §5).

## Settled defaults (finalised 2026-07-01)

- **Batch gate threshold: > 5 refs** — pause after the first ref, preview, then batch the rest.
- **Synthesis-note naming:** `refNN-<slug>.md`, matching the topic-folder convention.
- **`confidence: AMBIGUOUS` claims ARE asserted**, tagged `AMBIGUOUS` in the graph rather than dropped — the graph-RAG output contract emits all three confidence levels, and holding them back would be silent skipping.
- **`extractor_model` identifier:** the running model's ID string (a capable current model). Keep it stable across re-runs so the `(ref_id, source_sha256, extractor_model)` uniqueness key stays clean; bump it only for a genuine model change (per the [`GRAPH-README`](../../docs/GRAPH-README.md) re-extraction flow).

## Out of scope for this skill

- Capturing new primaries → `/research-capture`.
- Resolving contradictions across refs → surfaced via relations; resolution is operator's job during drafting.
- Drafting prose from concepts → operator owns prose.
