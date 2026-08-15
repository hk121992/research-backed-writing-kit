# Feynman agent prompts — close-read and adaptation notes

> **Upstream attribution.** This document close-reads the agent prompts of [getcompanion-ai/feynman](https://github.com/getcompanion-ai/feynman), an open-source AI research agent by Companion AI, released under the MIT License ("MIT License, Copyright (c) 2026 Companion, Inc."). Excerpts below — verbatim where the fetch returned full text (§1, §5), machine-paraphrased where it did not (§2–§4, marked as such) — remain © their authors under that licence, whose full text is reproduced in [`THIRD-PARTY-NOTICES.md`](../THIRD-PARTY-NOTICES.md). The document records what this kit adopted from Feynman and what it deliberately inverted.

**Source:** `getcompanion-ai/feynman` repo, `.feynman/agents/*.md` (fetched via WebFetch 2026-04-14).
**Purpose:** learn what's useful from Feynman's four-agent decomposition before authoring the `/research-*` command scaffolds. Adapt to this pipeline's softened voice / citation frame — well-founded but not exhaustively cited, contradiction-focused checking. Do not copy verbatim.
**Status:** working notes — supersede when patterns harden.

## Fetch record

| File | URL | Result |
|---|---|---|
| Researcher | https://raw.githubusercontent.com/getcompanion-ai/feynman/main/.feynman/agents/researcher.md | Full text returned |
| Reviewer | https://raw.githubusercontent.com/getcompanion-ai/feynman/main/.feynman/agents/reviewer.md | WebFetch summary only — fetcher LLM returned an analysis instead of verbatim text. Working from the analysis it returned. |
| Writer | https://raw.githubusercontent.com/getcompanion-ai/feynman/main/.feynman/agents/writer.md | Summary returned (key responsibilities + output format + tools). Sufficient to extract pattern. |
| Verifier | https://raw.githubusercontent.com/getcompanion-ai/feynman/main/.feynman/agents/verifier.md | Summary returned — covers the citation/verification standards. Sufficient. |
| AGENTS.md | https://raw.githubusercontent.com/getcompanion-ai/feynman/main/AGENTS.md | Full text returned |

Where verbatim text was unavailable, the analysis is treated as a faithful paraphrase but the operator-facing softening below is anchored to this kit's own rules, not to Feynman's original phrasing — so the partial fetch does not weaken the adaptation.

## Mapping to our motions

| Feynman role | Our motion | Why the mapping |
|---|---|---|
| Researcher | `/research-capture` (+ part of `/research-quickcheck`) | Both are evidence-gathering with strict integrity |
| Reviewer | `/research-gaps` | Adversarial reading: what's missing, what would a sceptic ask |
| Writer | (out of scope — operator writes; no analogue) | Operator authors drafts; no autodraft motion |
| Verifier | `/research-factcheck` | Source–claim alignment, but **softened** (see below) |

`/research-interpret` and `/research-tailor` have no clean Feynman analogue — Feynman doesn't separate ingestion-into-graph from research-output, and doesn't pivot a draft across registers.

---

## 1. Researcher → `/research-capture`

### Verbatim excerpt (from `.feynman/agents/researcher.md`)

> **No fabrication.** Every source must be verifiable with a URL. Unverified claims are excluded entirely.
>
> **Verification first.** Projects, papers, and datasets must be confirmed to exist before citation. Zero search results = does not exist.
>
> **Read before claiming.** Source contents, metrics, and findings require direct inspection. Titles and abstracts do not constitute reading.
>
> **URL requirement.** Evidence without direct, checkable URLs is not included.
>
> **Honest status marking.** Claims are labeled as directly read, inferred from multiple sources, or unresolved.

> **Source Hierarchy** — Preferred: Academic papers, official documentation, primary datasets, verified benchmarks, government filings, reputable journalism, expert technical blogs, official vendor pages. Acceptable with caveats: Well-cited secondary sources, established trade publications. Deprioritized: SEO-optimized content, undated blogs, aggregators, unsourced social media. Rejected: Unsigned, undated content; apparent AI-generated material without primary backing.

> Numbered evidence table with stable IDs linking claims to sources … Coverage Status section noting what was checked, what remains uncertain, and incomplete tasks. Progressive file writing; lightweight summary returned to parent.

### Adopt

1. **No-fabrication / URL-required / read-before-claiming** — direct fit for capture's gate point. Candidate-list rows must include a resolvable URL or be dropped.
2. **Honest status marking (read / inferred / unresolved)** — adopt as the `Status` column on `/research-capture`'s candidate-list table (vocabulary `verified / unverified / inferred / blocked`) and as the status vocabulary in every motion's outcome file.
3. **Source hierarchy as advisory** — already encoded in this kit as five tiers (see `STYLE-research.template.md`); Feynman's three-band cut is coarser. Keep our five-tier; their "rejected" band maps to our tier-5 + a hard-fail flag for unsigned/undated.
4. **Coverage Status section** — adopt as the candidate-list outcome file footer: "what was searched, what was kept, what was dropped, what remains uncertain."
5. **Progressive file writing + lightweight summary to parent** — exact match for our outcome-file convention; reinforces it.

### Reject

1. **"Verification first … Zero search results = does not exist."** — too strict for our register. The operator may capture a working paper that's only on the author's homepage; absence from web search is not proof of non-existence. Soften to: "If a primary cannot be located after reasonable search, mark `unresolved` and surface — do not silently drop."
2. **2–4 simultaneous broad queries** — implementation detail not relevant to a slash command body. Skip.

### How our softened frame changes the role

The pipeline distinguishes empirical/load-bearing claims (cite where possible) from observation/opinion/analogy (no citation needed) from contradicted claims (must be addressed). Capture's job is **only the first class** — building the corpus that load-bearing claims will resolve into. The role narrows: capture is not a universal evidence-gatherer for every sentence the operator might write; it is the curator of primaries the operator wants reachable. The candidate-list gate (no silent capture) is structurally heavier than Feynman's because the consequence of bulk-fetch without approval is not just bad sources — it's an operator-trust failure.

---

## 2. Reviewer → `/research-gaps`

### Paraphrase (from fetcher summary — verbatim text not returned)

*Machine paraphrase of `reviewer.md`, not Feynman's own wording:* Evaluates novelty, clarity, rigor, reproducibility, and likely pushback. Flags missing baselines, weak ablations, unclear claims, and unsupported statements. Distinguishes fatal issues from major concerns from minor polish problems. Produces both structured reviews and inline annotations with specific evidence. The reviewer must anchor every claim to concrete evidence in the paper; vague praise or unsupported critiques are forbidden.

### Adopt

1. **Severity tiers (fatal / major / minor)** — adopt directly for `/research-gaps` output. Maps cleanly to operator decision-making: fatal blocks publication, major needs addressing in prose, minor is optional polish.
2. **Anchor every critique to concrete evidence** — adopt as a hard rule: every gap reported must cite either a draft passage (line/section) or a corpus ref the draft missed. No vague "the piece feels under-supported."
3. **Inline annotations + structured summary** — adopt the dual-output shape: structured top-level table + inline notes pointing at specific draft locations.

### Reject

1. **"Novelty, ablations, baselines"** — peer-review-of-a-paper vocabulary. Our drafts are essays/posts/decks, not experimental papers. Replace with: missing perspectives, unaddressed counter-arguments, empirical gaps, register mismatches.
2. **"Likely pushback"** as a category — too adversarial for the operator's voice. Reframe as "what a thoughtful peer reader would ask" (the "smart colleague" test).

### How our softened frame changes the role

Feynman's reviewer is a paper-reviewer adversary. Ours is closer to STORM's perspective-asker: the goal is to surface counter-perspectives the operator should engage with, not to grade the draft. The output is a list of *productive interventions* — "you don't address X; the corpus has Y on it" — not a verdict. The softened frame makes the motion read-only and non-blocking; the operator decides what to act on.

---

## 3. Writer → (no direct analogue)

### Paraphrase (from fetcher summary — verbatim text not returned)

*Machine paraphrase of `writer.md`, not Feynman's own wording:* Evidence-only writing — claims must derive from supplied input files. Preserve uncertainty — retain caveats and conflicting findings without smoothing. Explicit gaps — surface unresolved questions directly. Tentative labeling — mark inferences and pending verification. No cosmetic enhancement — keep visuals proportional to underlying evidence quality. No inline citations (handled separately by verifier); no sources section (built by verifier).

### Adopt

1. **Preserve uncertainty / no smoothing** — informs `/research-tailor`: when pivoting a draft to a shorter target, do not quietly drop calibrated-confidence language (rule M5 in `STYLE-research.template.md`).
2. **Tentative labelling for inferences** — maps to the kit's `⟨UNCITED⟩` marker and to the four-value status vocabulary (verified / unverified / inferred / blocked) Feynman uses elsewhere — adopt that vocabulary in `/research-tailor` outcome files.
3. **Separation of writing from citation** — Feynman's writer doesn't cite; verifier does. We separate similarly: the operator writes prose with `[ref_id]` tokens; `/research-tailor` renders citation modes; `/research-factcheck` checks contradictions. Three roles, three motions.

### Reject

1. **Auto-drafting from research notes** — the operator writes. The pipeline does not produce drafts. This is a deliberate non-feature: the operator's framing is part of the artefact.
2. **Cosmetic-output guardrails (charts, Mermaid)** — not relevant to our prose register.

### How our softened frame changes the role

There is no writer agent in our pipeline. The operator is the writer. This is the load-bearing difference between Feynman (research → draft) and this kit (research-anchored writing where the operator owns the angle). All Feynman's writer-side guardrails get re-housed in `STYLE-research.template.md` and in `/research-tailor`, not in an autonomous writer motion.

---

## 4. Verifier → `/research-factcheck` — biggest divergence

### Paraphrase (from fetcher summary — verbatim text not returned)

*Machine paraphrase of `verifier.md`, not Feynman's own wording:* Add inline citations `[1]`, `[2]` after every factual claim in drafts. Verify all source URLs resolve and support claimed content. Build a deduplicated, numbered Sources section matching all inline citations. Remove or flag unsourced factual claims — no orphan citations or sources allowed. Validate that sources actually support specific claims, not just related topics. Its citation standard: every factual statement requires at least one citation; hedged/opinion statements are exempt.

### Adopt

1. **URL liveness check** — adopt: `/research-factcheck` resolves every `[ref_id]` to a live row and verifies `refs.url` returns 200 (or has a recorded archive fallback).
2. **Source-supports-claim validation, not just topical match** — adopt: where the corpus contains a primary cited by `[ref_id]`, factcheck checks the surrounding sentence is consistent with `claims.statement` rows from that primary. Not just "the URL exists."
3. **Hedged/opinion exemption** — adopt directly. Aligns with the kit's exemption for observation/opinion/analogy (no citation required).
4. **Dead-link recovery: archive/mirror or remove** — adopt as a softer warning ("link is dead; archive available at X — replace?") rather than auto-remove.

### Reject — this is the load-bearing rejection

> **Every factual statement requires at least one citation; remove or flag unsourced factual claims.** *(as rendered by the fetcher summary)*

This is the exact failure mode this kit is built to avoid. Its first rule: "Well-founded in research, **not exhaustively cited.** The writing can include observation, opinion, analogy, and narrative without a footnote on every sentence." The load-bearing class is intentionally narrower than Feynman's "every factual statement" — "the argument falls over if this is wrong" is a much smaller set than "any factual claim."

A `/research-factcheck` that flags every uncited factual statement would produce a wall of false positives and train the operator to ignore the tool. That kills it.

### How our softened frame changes the role

`/research-factcheck` does **three** things, in this order of importance:

1. **Contradiction detection** (the load-bearing job): scan the draft for claims the corpus *contradicts* or significantly complicates. Report each with the counter-source (`ref_id`, `evidence_locator`). The operator must address each in the prose — acknowledge, rebut, or adjust the claim. This is the single discipline the project exists to enforce.
2. **Citation resolution**: for sentences the operator *did* mark with `[ref_id]`, confirm the ref exists, the URL resolves, and (where extractable) the cited primary supports the surrounding claim — not just that it's on the topic.
3. **Tier warnings**: where a load-bearing claim is anchored only on a tier-4/5 source, emit a warning. Operator decides.

What it does **not** do:

- Demand a citation on every sentence.
- Auto-remove claims.
- Flag opinion, analogy, or narrative as "unsourced."
- Block publication — output is an outcome file the operator reviews, never a hard fail.

This is the inversion of Feynman's verifier. Feynman's question is "is everything cited?" Ours is "is anything contradicted?" Different question, different tool, different relationship to the writer.

---

## 5. Cross-cutting from AGENTS.md

### Adopt

1. **`.provenance.md` sidecar** — adopt as the rendered output of every `/research-tailor` run.
2. **Status vocabulary (`verified | unverified | blocked | inferred`)** — adopt across all motions' outcome files.
3. **Slug-prefixed file naming** — adopt for any per-run intermediate files (e.g. `<slug>-candidate-list.md` from `/research-capture`).
4. **File-based handoffs over context-dumping** — already native here (motion outcome files). Reinforces.
5. **"Subagents may not silently skip assigned tasks"** — adopted as the pipeline's no-silent-skipping rule: every motion records skipped or failed items in its outcome file rather than moving on quietly.
6. **Lab-notebook `CHANGELOG.md`** — adopt **per topic folder**, not per repo. Each topic gets a `notebook.md` capturing what was searched, what was captured, what was rejected, what's blocked.

### Reject

1. **`outputs/`, `papers/`, `notes/` global folders** — Feynman is a generic research workspace; this kit is per-topic. Outputs live inside the topic folder, `<topic>/`.
2. **Pi subagent runtime** — the kit runs as Claude Code slash commands in the operator's session.

---

## Net adaptation summary

Feynman gives us four shapes (gather, review, write, verify) and a workspace contract (provenance, file-handoffs, status vocabulary, no-silent-skip). We adopt the shapes, the contract, and the integrity standards — but invert the verifier's question (contradiction not coverage), drop the writer entirely (operator owns prose), and add two motions Feynman doesn't have (`/research-interpret` graph-population, `/research-tailor` register pivot). The result is a smaller, narrower, operator-collaborative pipeline — closer in spirit to Feynman's integrity standards than to its workflow shape.
