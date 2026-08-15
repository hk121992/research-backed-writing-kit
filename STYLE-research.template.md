# Research Writing Guide

**This file is the research-register delta applied on top of `STYLE-personal.template.md` when drafting corpus-anchored pieces.**

**Purpose.** The rules to follow when drafting research pieces from a topic corpus in this kit.

**Scope.** Applies to long-form essays, research pieces, decks, and any prose published from a topic corpus — across all topics. Does **not** apply to personal-register writing (short-form social posts, personal essays in your native voice) — use `STYLE-personal.template.md` directly for those.

**Relationship to `STYLE-personal.template.md`.** That file is the base. This guide is a delta on top of it.

| Status | What |
|---|---|
| **Carry over wholesale** | Australian English, banned patterns, specificity, first person, sentence-rhythm, em dashes, understatement, the One Rule, drafting-via-questions (C1–C10 below). |
| **Modified for research register** | Opening, limits-phrasing, analogy, self-deprecation, hedging, artificial balance, structure, closing (M1–M8 below). |
| **New here** | Citation discipline, citation output modes, claim-attribution style, source-quality hierarchy, graph-RAG anchor conventions, extended self-check (§ Citation onward). |

Use this guide at drafting time. The full base rules live in `STYLE-personal.template.md`; this file tells you where the research register diverges and what the extra disciplines are.

---

## Voice register

Write as the serious, thoughtful variant of your personal voice. Compelling, opinionated, narrative when the material calls for it. Keep specificity, directness, Australian English, first person, storytelling, analogy, argument. Drop the confessional hook-lead and the "figuring it out in real time" register. Not dry. Not academic.

**The test:** would a thoughtful reader — a peer, not a peer-reviewer — find this interesting, trust the argument, and not catch the pipeline asleep on something the literature already refutes?

---

## Carried-over rules (C1–C10)

These apply from `STYLE-personal.template.md` unchanged. Read them there; don't re-derive.

| # | Rule | Why it still applies |
|---|---|---|
| C1 | Australian English throughout (-ise, -our, -re, *programme*, *analyse*) — or whichever variant you configured. See STYLE-personal.template.md §Australian English Conventions. | Author identity; consistent across registers. |
| C2 | Banned patterns: uniform sentence length, hedges, filler transitions, overrepresented AI vocabulary (*delve*, *leverage*, etc.), artificial balance, generic metaphors, over-structured output, closing summaries. See STYLE-personal.template.md §Banned Patterns. **Bans are stronger here, not weaker** — generic AI tells are worse in serious writing. | Credibility. |
| C3 | Specific over abstract — use real numbers, named tools, dates. | Central to credibility. |
| C4 | First person. | You are the author, not a neutral narrator. |
| C5 | Close by completing the circle back to the opener. | Essay structure still benefits. |
| C6 | Vary sentence length; use fragments for rhythm. | Prose quality, register-agnostic. |
| C7 | Em dashes sparingly — ≤ 2–3 per piece. | Same. |
| C8 | Understated over emphatic (ABC / SMH convention). | Same. |
| C9 | The One Rule — "would you say this out loud to a smart colleague?" Here "smart colleague" is a *subject-matter* peer. | Still the test. |
| C10 | Drafting process — ask questions, don't fabricate. **Hard rule here, not a guideline.** See STYLE-personal.template.md §Drafting Process. | Fabrication is the worst failure mode of research writing. |

---

## Modified rules (M1–M8)

Where the research register overrides or extends the base rule.

| # | Pattern | Personal register (base) | Research register (follow this) |
|---|---|---|---|
| M1 | **Opening** | Opens mid-thought — provocation / realisation, no context-setting. | Provocation and realisation still welcome. Also make the stakes visible — why this argument matters — either explicitly or through the story it leads with. |
| M2 | **Stating limits** | Confessional disclaimer ("I'm not a developer…"). | Express limits as **scope**, not **credentials**. Write "This piece does not address X," not "I'm not a specialist in X." |
| M3 | **Analogy as argument** | Lived analogies carry persuasion on their own. | Analogy is welcome and can carry whole pieces. When an analogy is doing the persuasion on a *factual* claim the literature has studied, back it with at least one cited primary — the analogy is the vehicle, not the sole warrant. |
| M4 | **Self-deprecation** | One precise moment, placed for effect. | Same. One precise moment, placed for effect. Not the default opener. |
| M5 | **Hedging** | Banned ("commit to the position"). | Still banned. Where evidence is weak or mixed, use **calibrated confidence** — explicit epistemic status, not woolly hedging. Examples: *"Evidence here is strong."* / *"This is a working-paper result; treat as provisional."* / *"The consensus position is X; I'm arguing Y."* |
| M6 | **Artificial balance** | Banned. | Still banned. But when the corpus *contradicts* a load-bearing claim in the draft, acknowledge the counter-source in the piece and explain why the line still stands — or adjust it. The fact-check pipeline surfaces these; the writing addresses them. |
| M7 | **Structure** | Default to prose; structure only when the idea calls for it. | Prose remains default. Section headers permitted for pieces > 2000 words. |
| M8 | **Closing** | Most interesting line, circles back to opener. | Same. The closing can assert or interpret — it does not need a citation. It must **not** introduce a factual claim the rest of the piece hasn't grounded. |

---

## Citation discipline

Three classes of sentence, each handled differently:

1. **Empirical / load-bearing claims** (the argument falls over if this is wrong): cite where a corpus primary exists. Use an inline `[ref_id]` footnote matching `refs.ref_id` in `graph.sqlite`. Example: *"… a pattern observed across team-based science [wuchty-2007-teams]."*
2. **Observation, opinion, analogy, narrative:** no citation required. These are the storytelling and argument tissue — the voice relies on them.
3. **Contradicted claims:** if the corpus contains evidence that refutes or significantly complicates a draft claim, `/research-factcheck` flags it. Acknowledge and address the counter-evidence in the prose, adjust the claim, or drop it. This is the kit's core discipline.

**Quoting primaries.** Verbatim quotes require `evidence_locator` (page / section). Prefer paraphrase unless the exact phrasing is doing work.

**Optional tethers.** You may mark a load-bearing sentence with an inline tether even when no counter-evidence exists — aids later reuse and review. Not required.

**`⟨UNCITED⟩` marker.** Optional. Flag a sentence as a deliberate uncited assertion the pipeline should not try to match against the corpus. Useful for strong opinions.

---

## Citation output modes

Draft in stable `[ref_id]` tokens throughout — machine-resolvable against `refs.ref_id` in `graph.sqlite`. At render time, `/research-tailor` transforms those tokens into one of three modes, per the target's convention:

| Mode | Where tokens become | Reference list | Typical use |
|---|---|---|---|
| **Inline hyperlinks** | `[claim text](url)` — linked to the primary's canonical URL (DOI, arXiv, publisher page, open-access PDF). | None, or a compact *Sources* block at the end. | LinkedIn articles, Substack posts, web essays, newsletters. |
| **Academic** | Superscripts or `[n]` markers, resolved in a numbered reference list at the end. | Full formatted refs (Author, Year, Title, Venue, URL). | PDF prints, long-form essays for print-style reading, deck appendix. |
| **Hybrid** | Inline hyperlinks in prose + formatted reference list at the end for completeness. | Yes. | Long web essays where readers want both skim-and-click and a tidy bibliography. |

**Rendering rules:**

- The draft is the single source of truth. `[ref_id]` never appears in a published deliverable.
- `refs.url` is required for inline-hyperlink mode. If a primary has no public URL, `/research-tailor` flags it and offers: (a) archive link (Wayback, author-hosted PDF), (b) downgrade the whole piece to academic mode, or (c) leave the sentence uncited.
- Mode is selected per target. `/research-tailor <draft> li-post` defaults to inline hyperlinks; `/research-tailor <draft> essay-pdf` defaults to academic. Override with `--mode <inline|academic|hybrid>`.
- The reference list, when present, is machine-generated from the `refs` rows actually cited. Never hand-curate.

---

## Claim-attribution style

Use:

- **"Farrell and colleagues argue that…"** — preferred for load-bearing synthesis.
- **"The Google Agentic AI paper notes…"** — acceptable for institutional sources.
- **"One recent empirical study (Dell'Acqua et al. 2023) found…"** — paired with the `ref_id` footnote, gives both the named hook and the machine-resolvable anchor.

Avoid:

- **"many researchers believe" / "studies have shown"** — vague attribution is banned (STYLE-personal.template.md §Banned Patterns, row 7).

---

## Source-quality hierarchy

Advisory ordering, not a blocker. `/research-factcheck` emits *warnings* (not failures) when a load-bearing claim is anchored only to tier-4 or tier-5; you decide.

| Tier | Examples | Weight for load-bearing claims |
|---|---|---|
| 1 | Peer-reviewed journal article (Science, PNAS, top CS venues). | Strongest — prefer as anchor for empirical claims. |
| 2 | Working paper / preprint / NBER / reputable arXiv. | Strong; note "working paper" epistemic status in prose. |
| 3 | Institutional report (research labs, industry research groups). | Adequate for practitioner / frontier claims; verify authorship track record. |
| 4 | Practitioner essay (named, reputable authors). | Adequate for *framing* and *observation*; never the sole anchor for an empirical fact. |
| 5 | Marketing / vendor content. | Cite only when the piece *is* the subject (e.g. critiquing vendor claims); never as evidence. |

Write `refs.tier` on capture so the pipeline can warn you.

---

## Graph-RAG anchor conventions

Drafts and `graph.sqlite` are linked via `ref_id`, `concept_id`, and `claim_id`.

- **In drafts (human-readable):** inline `[ref_id]` footnotes; introduce concepts in small caps or as `**concept-id**`. Example: *"**jagged-frontier** [dellacqua-2023]"*.
- **In synthesis notes (`ref0N-*.md`):** YAML front-matter with `ref_id:` and a list of `concept_ids:` asserted. Body free-form.
- **In the graph:** phrase every `claims.statement` row as an atomic proposition extractable from the primary — not your paraphrase. Use `ref_concepts.role` only from: `defines | uses | extends | critiques`.
- **Pre-publication check:** run `/research-factcheck`. It (a) resolves each inline `[ref_id]` to a live `refs` row, (b) scans for claims the corpus *contradicts* and reports them with the counter-source, and (c) emits source-tier warnings. Failures and flags go to an outcome file — review it before publishing.

---

## Self-check before publishing

Run all eleven. Items 1–7 are the base checks from `STYLE-personal.template.md` §Self-check (titles below as reminder — read there for detail). Items 8–11 are research-register additions.

1. **Sentence rhythm** — variety; at least one fragment and one longer complex sentence.
2. **Transitions** — no filler; restructure if the flow breaks without them.
3. **Vocabulary** — no banned AI-tell words; use natural alternatives.
4. **Opening** — starts mid-thought, not with context-setting.
5. **Closing** — links back to the opener; most interesting line of the piece; not a restatement.
6. **Specificity** — at least one concrete detail only you would know: a real number, named tool, date, honest admission.
7. **Balance** — clear position, not hedged.
8. **Contradiction audit.** Has `/research-factcheck` run, and has every contradiction it flagged been addressed in the prose — acknowledged, rebutted, or the claim adjusted?
9. **Load-bearing citations.** For empirical claims the argument depends on, is there a `[ref_id]` where a corpus primary exists?
10. **Epistemic status.** Where evidence is weak / mixed / working-paper-only, is that stated in the prose?
11. **Voice check.** Does the piece still read as writing — compelling, opinionated, narrative — rather than a citation-dense review?
