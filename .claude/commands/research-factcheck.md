---
name: research-factcheck
description: Read-only fact-check of a research draft against its topic corpus. Detects claims the corpus CONTRADICTS and reports them with counter-source. Resolves [ref_id] tokens to live refs rows. Warns on tier-4/5-only load-bearing claims. Does NOT demand a citation on every sentence — opinion, observation, analogy, and narrative are exempt. Use when the operator says "fact-check this draft" or before publishing.
---

# /research-factcheck

Contradiction-focused fact-check. Implements the pipeline's **Interrogate** motion.

**Status: Active** — defaults finalised 2026-07-01. The settled defaults below replace the prior operator-review TODOs; override any line if the motion misbehaves in use.

## What this skill is — and what it is NOT

This skill is the inversion of a conventional citation-completeness checker.

**It does:**
1. **Contradiction detection** (the load-bearing job): scan the draft for claims the corpus *contradicts* or significantly complicates. Report each with the counter-source (`ref_id`, `evidence_locator`, the contradicting `claims.statement`).
2. **Citation resolution:** for every `[ref_id]` token in the draft, confirm the row exists in `refs`, the URL resolves (HTTP 200 or recorded archive fallback), and where extractable claims exist, the cited primary supports the surrounding sentence — not just that the URL is on-topic.
3. **Tier warnings:** where a load-bearing claim is anchored only on a tier-4/5 source (per the source-quality hierarchy in `STYLE-research.template.md`), emit a warning. Operator decides whether to address.
3a. **Temporal weighting:** weight contradictions by the ratio of draft-era to counter-era. A 1937 paper contradicting a 2026 AI-deployment claim is not load-bearing; a 2025 paper contradicting the same claim is. For fast-moving technology claims, treat pre-2023 empirical results on model capability as historical context, not current evidence. Foundational theory (Coase, Mintzberg, Galbraith) is background, not decisive counter.
4. **`⟨UNCITED⟩` acknowledgement:** list deliberately-uncited claims the operator has marked. No action — just receipt.

**It does NOT:**
- Demand a citation on every factual sentence. The pipeline's first rule of the house bans this: well-founded in research, not exhaustively cited. Observation, opinion, analogy, and narrative are exempt by design.
- Auto-remove claims. Output is a report; the operator decides.
- Block publication. The motion is read-only and non-blocking.
- Rewrite the draft.

The question this skill answers is **"is anything in the draft contradicted by the corpus?"** — *not* "is everything cited?" See [`provenance-feynman.md`](../../docs/provenance-feynman.md) §4 for the rationale (load-bearing rejection of Feynman's verifier framing).

## Args

    /research-factcheck <draft-path>

Operator must be inside (or pass `--topic <name>` for) a topic folder with a populated `graph.sqlite`.

## Behaviour

1. **Parse draft** for `[ref_id]` tokens, `⟨UNCITED⟩` markers, and structural sections.
2. **Resolve every `[ref_id]`** to a row in `refs`. Flag misses (token has no matching row).
3. **URL liveness check** for each cited `refs.url`. Suggest archive fallback for dead links — never auto-replace.
4. **Claim-corpus alignment** (the main pass): for each load-bearing claim in the draft, run a corpus search (`claims_fts` virtual table) for `type = contradicts` or for atomic claims that cover the same topic with opposing direction. Report each finding as a contradiction entry.
5. **Tier audit** of cited refs supporting load-bearing claims; warn on tier-4/5-only.
6. **`⟨UNCITED⟩` audit:** list and acknowledge — no action.
7. **Outcome file.** Write `<topic>/.factchecks/<draft-slug>-factcheck-outcome.md`:
    - `## Contradictions` (severity: fatal / major / minor)
    - `## Citation resolution` (resolved / dead / missing-row)
    - `## Tier warnings`
    - `## Acknowledged ⟨UNCITED⟩`
    - `## Status` — `verified | unverified | blocked | inferred`
   Lightweight summary returned to session. Read-only motion — no gate point, no draft modifications.

## Constraints

- Read-only on the draft. Never edit.
- Read-only on `refs` and `claims`. Never insert/update.
- No web calls except URL liveness HEAD requests.
- Never block — emit report and exit.
- Never modify files outside this project.

## Settled defaults (finalised 2026-07-01)

- **"Load-bearing" claim heuristic:** any sentence carrying an inline `[ref_id]` token, or any sentence making a numeric/empirical assertion outside the opinion/analogy/narrative registers. Observation and opinion are exempt.
- **Paywalled-source liveness:** a 200 to a paywall/landing page is reported as `resolved-paywalled`, distinct from `resolved-open` — never auto-replaced, and never treated as content verification.
- **Contradiction severity:** `fatal` = corpus holds a `relations.type = contradicts` edge directly against the cited `ref_id`; `major` = same topic, opposing direction, different primary; `minor` = complicates but does not refute. Weight every one by the temporal heuristic in §3a.
- **Tier warnings** appear in both the session summary (count) and the outcome file (detail) — a tier-4/5-only load-bearing claim is worth surfacing immediately.

## Out of scope

- Drafting / rewriting prose.
- Suggesting new refs to capture → that's `/research-gaps`.
- External-text critique → deferred to v2 (`--external` flag).
