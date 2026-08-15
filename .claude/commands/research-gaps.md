---
name: research-gaps
description: Read-only perspective-and-coverage audit. Given a topic corpus and (optionally) a draft, identifies missing adjacent canon, unaddressed counter-arguments, and empirical gaps. Generates "what a thoughtful peer reader would ask" — productive interventions, not a verdict. Use when the operator says "what am I missing?" or "what would a sceptic ask?".
---

# /research-gaps

Perspective-and-coverage audit. Implements the pipeline's **Supplement** motion, with STORM-borrowed perspective-asking.

**Status: Active** — defaults finalised 2026-07-01. The settled defaults below replace the prior operator-review TODOs; override any line if the motion misbehaves in use.

## Args

    /research-gaps                    # topic-wide audit
    /research-gaps <draft-path>       # draft-anchored audit

## Behaviour

1. **Build claim-map.** From `graph.sqlite`: list current concepts, claims, relations. If draft passed: extract its central claims (sentences with `[ref_id]` tokens + headline assertions).
2. **Generate counter-perspectives** (STORM-borrowed): for the topic or draft thesis, generate 3–5 hostile-but-thoughtful framings — "a researcher in adjacent field X would argue...", "the historical analogue to this is Y, which went...", "the strongest empirical objection is Z."
2a. **Apply the temporal weight heuristic:** do not grade foundational theory (pre-2000) as "major" counter-evidence against contemporary AI-deployment claims. Cite historical sources as *lineage* — the claim they contest was already known to be provisional at the time it was made. For a counter-perspective to be rated major or fatal, it must be both on-topic AND in-epoch (or show why older evidence still applies).
3. **Coverage audit:** for each counter-perspective, check whether the corpus contains primaries addressing it. Flag perspectives the corpus does not engage.
4. **Adjacent canon:** identify obvious canonical works the corpus is missing (named authors, named papers operator should consider capturing).
5. **Empirical gaps:** flag claims in the draft (or central topic claims) that are framed as empirical but have no `evidence_locator` in the corpus.
6. **Outcome file.** Write `<topic>/.gaps/<run-slug>-gaps-outcome.md`:
    - `## Counter-perspectives` (severity: fatal / major / minor — Feynman convention)
    - `## Missing adjacent canon` (suggested refs to capture, with URLs and tier guesses — operator decides via `/research-capture`)
    - `## Empirical gaps`
    - `## Status` — `verified | unverified | blocked | inferred`

   Every entry must be anchored to either a draft passage (line/section) or a corpus ref. No vague "the piece feels under-supported." (Feynman reviewer convention — see [`provenance-feynman.md`](../../docs/provenance-feynman.md) §2.)

## Constraints

- Read-only. Never edits the draft, the graph, or the refs.
- Never auto-captures. Suggested refs are a list for operator review — the operator runs `/research-capture` if they want any of them.
- No silent skipping: if a perspective can't be evaluated (e.g. corpus is empty in that direction), say so explicitly.

## Settled defaults (finalised 2026-07-01)

- **Counter-perspectives: generate 3–5** (STORM-borrowed). Fewer reads shallow; more reads as noise.
- **Adjacent canon is split into `needed` vs `tangential`:** `needed` = a named work the corpus should engage to hold its thesis; `tangential` = interesting but optional. Only `needed` items carry a severity; tangential ones are a plain list.
- **Severity tiers `fatal / major / minor` are kept** (not a flatter consider/suggest pair) — they align with `/research-factcheck`'s vocabulary so a gaps finding and a factcheck finding read on the same scale. Non-blocking regardless.

## Out of scope

- Verifying citations → `/research-factcheck`.
- Capturing the suggested refs → `/research-capture`.
- Drafting / rewriting prose.
