---
name: research-capture
description: Ingest a seed (URL/DOI/path) into a research topic's corpus. Follow one-hop references, triage by tier, present a candidate list for operator approval, then on approval bulk-fetch, OCR/extract, and populate references/ + the refs table. Use when the operator says "capture this paper", "add to corpus", or starts a new topic with a seed source.
---

# /research-capture

Corpus capture for a research topic. Implements the pipeline's **Capture** motion.

**Status: Active** — defaults finalised 2026-07-01. The settled defaults below replace the prior operator-review TODOs; override any line if the motion misbehaves in use.

## Args

    /research-capture <seed-url-or-doi-or-path> [--seed-only]

Seed is a single URL, DOI, file path, or arXiv ID. Operator must be inside a `<topic>/` folder (or specify `--topic <name>`).

## Behaviour

1. **Resolve the seed.** Fetch metadata (title, authors, year, venue). For PDFs, store under `references/pdfs/`. For HTML, archive verbatim.
2. **One-hop discovery.** Extract the seed's reference list. Find each cited primary's open-access URL where one exists. Tier each per the source-quality hierarchy in `STYLE-research.template.md` (tier 1 = peer-reviewed; tier 5 = vendor marketing).
3. **Triage.** Compose a candidate-list table:

   | # | Author / Year | Title | Tier | URL | Status |
   |---|---|---|---|---|---|

   `Status` ∈ `{verified, unverified, inferred, blocked}` — Feynman vocabulary (see [`provenance-feynman.md`](../../docs/provenance-feynman.md) §5).
4. **GATE POINT — operator approval (no silent capture).** Present the table inline. Wait for operator response. Accepted forms:
    - `yes` — fetch all
    - `drop 3,7,12` — fetch all except listed rows
    - `drop tier-4` — fetch all except a tier
    - `keep 1,2,5` — fetch only listed rows
    - `stop` — abort, write outcome file with what was triaged

   **Do not bulk-fetch before approval.** A capture run that fetches without operator OK is a contract violation.
5. **Fetch the approved set.** For each kept candidate: download primary, OCR/extract to plain text, write `references/pdfs/<slug>.pdf` + `references/<slug>.txt`, insert row to `refs` (ref_id, source_path, authors, year, title, venue, tier, url).
6. **Outcome file.** Write `<topic>/.captures/<YYYY-MM-DD>-<slug>-capture-outcome.md` summarising: candidates triaged, kept, dropped (with reason), fetched (with sha256), failed-to-fetch (with reason). Status vocabulary: verified / unverified / blocked / inferred. Lightweight summary returned to session.

## Constraints

- Read-before-claiming: do not insert a `refs` row for a primary that was not actually downloaded and at least metadata-inspected.
- URL required for tier 1–4 (open-access where possible; archive link acceptable). Tier 5 (vendor marketing) may have only the vendor's own URL.
- No fabrication. If a cited reference cannot be located, mark `unresolved` in the outcome file. Do not invent a URL.
- Never write outside `<topic>/`.
- Never modify files outside this project.

## Settled defaults (finalised 2026-07-01)

- **Candidate-list reply grammar:** `yes` / `drop N,M` / `drop tier-N` / `keep N,M` / `stop`.
- **One-hop discovery is on by default** (the Capture motion includes one-hop). It only builds the candidate list; nothing is fetched before the approval gate, so default-on does not breach the no-silent-capture rule. Pass `--seed-only` to skip one-hop for an incremental single-source add.
- **Tier-5 sources appear in the candidate list**, flagged as tier 5, rather than filtered out — the operator drops them with `drop tier-5` if unwanted (advisory-tier principle; vendor marketing is legitimately captured when the piece critiques it).
- **Outcome file** lives in `<topic>/.captures/` under the dated convention `<YYYY-MM-DD>-<slug>-capture-outcome.md`.

## Out of scope for this skill

- Interpretation / synthesis-note authoring → use `/research-interpret` after capture.
- Drafting → operator owns prose.
- Fact-checking a draft → `/research-factcheck`.
